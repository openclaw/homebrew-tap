from __future__ import annotations

import hashlib
import http.server
import importlib.util
import os
import pathlib
import ssl
import subprocess
import tempfile
import threading
import unittest
import urllib.error
from unittest import mock


SCRIPT = pathlib.Path(__file__).resolve().parents[1] / ".github/scripts/update_formula.py"
SPEC = importlib.util.spec_from_file_location("redirect_updater", SCRIPT)
assert SPEC and SPEC.loader
update_formula = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(update_formula)


class DownloadRedirectTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        temporary = tempfile.TemporaryDirectory()
        cls.addClassCleanup(temporary.cleanup)
        root = pathlib.Path(temporary.name)
        cls.certificate = root / "certificate.pem"
        key = root / "key.pem"
        config = root / "openssl.cnf"
        config.write_text(
            "[req]\nprompt = no\ndistinguished_name = dn\nx509_extensions = extensions\n"
            "[dn]\nCN = localhost\n[extensions]\n"
            "subjectAltName = DNS:localhost,IP:127.0.0.1\n"
            "basicConstraints = critical,CA:TRUE\n"
        )
        subprocess.run(
            ["openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes", "-sha256",
             "-days", "1", "-config", str(config), "-keyout", str(key),
             "-out", str(cls.certificate)],
            check=True, capture_output=True, timeout=30,
        )
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cls.certificate, key)
        cls.payload = b"release archive through verified TLS\n"
        cls.requests: list[tuple[str, str]] = []
        cls.routes: dict[str, tuple[int, str]] = {}

        class Handler(http.server.BaseHTTPRequestHandler):
            def do_GET(self) -> None:
                cls.requests.append((self.server.scheme, self.path))
                if self.path == "/asset":
                    self.send_response(200)
                    self.end_headers()
                    self.wfile.write(cls.payload)
                else:
                    code, location = cls.routes[self.path]
                    self.send_response(code)
                    self.send_header("Location", location)
                    self.end_headers()

            def log_message(self, format: str, *args: object) -> None:
                pass

        for scheme in ("http", "https"):
            server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler)
            cls.addClassCleanup(server.server_close)
            server.scheme = scheme
            if scheme == "https":
                server.socket = context.wrap_socket(server.socket, server_side=True)
            thread = threading.Thread(target=server.serve_forever, kwargs={"poll_interval": 0.01}, daemon=True)
            thread.start()
            cls.addClassCleanup(thread.join, 5)
            cls.addClassCleanup(server.shutdown)
            setattr(cls, scheme, f"{scheme}://127.0.0.1:{server.server_port}")

    def setUp(self) -> None:
        self.requests.clear()
        self.routes.clear()
        # Trust only the fixture certificate for this run; TLS verification stays enabled.
        environment = mock.patch.dict(os.environ, {"SSL_CERT_FILE": str(self.certificate), "no_proxy": "*"})
        environment.start()
        self.addCleanup(environment.stop)

    def test_allowed_relative_and_cross_host_https_redirects_hash_body(self) -> None:
        for code in (301, 302, 303, 307, 308):
            with self.subTest(code=code):
                self.requests.clear()
                self.routes.update({
                    "/start": (code, "/next"),
                    "/next": (code, self.https.replace("127.0.0.1", "localhost") + "/asset"),
                })
                self.assertEqual(update_formula.sha256(self.https + "/start"), hashlib.sha256(self.payload).hexdigest())
                self.assertEqual(self.requests, [("https", "/start"), ("https", "/next"), ("https", "/asset")])

    def test_https_http_https_chain_never_requests_http_hop(self) -> None:
        for code in (301, 302, 303, 307, 308):
            with self.subTest(code=code):
                self.requests.clear()
                self.routes.update({
                    "/start": (code, self.http + "/back-to-https"),
                    "/back-to-https": (302, self.https + "/asset"),
                })
                with self.assertRaisesRegex(SystemExit, "invalid redirected download URL"):
                    update_formula.sha256(self.https + "/start")
                self.assertEqual(self.requests, [("https", "/start")])

    def test_forbidden_location_after_allowed_hop_is_never_requested(self) -> None:
        for location in (
            self.http + "/asset",
            "ftp://127.0.0.1/asset",
            self.https.replace("https://", "https://user:password@") + "/asset",
            self.https + "/asset#fragment",
            "/asset#fragment",
        ):
            with self.subTest(location=location):
                self.requests.clear()
                self.routes.update({"/start": (302, "/next"), "/next": (302, location)})
                with self.assertRaisesRegex(SystemExit, "invalid redirected download URL"):
                    update_formula.sha256(self.https + "/start")
                self.assertEqual(self.requests, [("https", "/start"), ("https", "/next")])

    def test_redirects_keep_certificate_verification_enabled(self) -> None:
        # 127.1 reaches the same server but is not covered by its certificate.
        self.routes["/start"] = (302, self.https.replace("127.0.0.1", "127.1") + "/asset")
        with self.assertRaises(urllib.error.URLError) as error:
            update_formula.sha256(self.https + "/start")
        self.assertIsInstance(error.exception.reason, ssl.SSLCertVerificationError)
        self.assertEqual(self.requests, [("https", "/start")])

    def test_private_and_numeric_hosts_keep_existing_url_contract(self) -> None:
        # Public-only sources and DNS/IP restrictions are a separate policy decision.
        for host in ("localhost", "127.0.0.1", "[::1]", "192.168.1.1", "2130706433", "127.1", "0x7f000001"):
            with self.subTest(host=host):
                url = f"https://{host}/asset"
                self.assertEqual(update_formula.validate_url(url, "download URL"), url)


if __name__ == "__main__":
    unittest.main()
