# api/server.py
from http.server import HTTPServer, BaseHTTPRequestHandler
import json, base64
from pathlib import Path

DATA_FILE = Path(__file__).parent.parent / 'transactions.json'
USERNAME = 'admin'
PASSWORD = 'password'

def load_data():
    if DATA_FILE.exists():
        with open(DATA_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def save_data(data):
    with open(DATA_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def check_auth(header_value: str) -> bool:
    if not header_value or not header_value.startswith('Basic '):
        return False
    try:
        decoded = base64.b64decode(header_value.split(' ', 1)[1]).decode('utf-8')
        user, pwd = decoded.split(':', 1)
        return user == USERNAME and pwd == PASSWORD
    except Exception:
        return False

class Handler(BaseHTTPRequestHandler):
    server_version = "MoMoSMSHTTP/1.0"

    def _path_parts(self):
        return [p for p in self.path.split('?')[0].split('/') if p]

    def _auth_or_401(self) -> bool:
        if not check_auth(self.headers.get('Authorization', '')):
            self.send_response(401)
            self.send_header('WWW-Authenticate', 'Basic realm="MoMo API"')
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"error":"unauthorized"}')
            return False
        return True

    def _send_json(self, obj, status=200):
        payload = json.dumps(obj).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        if not self._auth_or_401():
            return
        parts = self._path_parts()

        if parts == ['transactions']:
            return self._send_json(load_data())

        if len(parts) == 2 and parts[0] == 'transactions':
            txid = parts[1]
            for t in load_data():
                if str(t.get('id')) == str(txid):
                    return self._send_json(t)
            return self._send_json({'error':'not found'}, status=404)

        return self._send_json({'error':'endpoint not found'}, status=404)

    def do_POST(self):
        if not self._auth_or_401():
            return
        parts = self._path_parts()
        if parts == ['transactions']:
            try:
                length = int(self.headers.get('Content-Length', 0))
                obj = json.loads(self.rfile.read(length).decode('utf-8'))
            except Exception:
                return self._send_json({'error':'invalid json'}, status=400)
            txs = load_data()
            max_id = 0
            for t in txs:
                try: max_id = max(max_id, int(str(t.get('id', 0))))
                except: pass
            obj['id'] = str(max_id + 1)
            txs.append(obj)
            save_data(txs)
            return self._send_json(obj, status=201)
        return self._send_json({'error':'endpoint not found'}, status=404)

    def do_PUT(self):
        if not self._auth_or_401():
            return
        parts = self._path_parts()
        if len(parts) == 2 and parts[0] == 'transactions':
            txid = parts[1]
            try:
                length = int(self.headers.get('Content-Length', 0))
                obj = json.loads(self.rfile.read(length).decode('utf-8'))
            except Exception:
                return self._send_json({'error':'invalid json'}, status=400)
            txs = load_data()
            for i, t in enumerate(txs):
                if str(t.get('id')) == str(txid):
                    obj['id'] = str(txid)
                    txs[i] = obj
                    save_data(txs)
                    return self._send_json(obj)
            return self._send_json({'error':'not found'}, status=404)
        return self._send_json({'error':'endpoint not found'}, status=404)

    def do_DELETE(self):
        if not self._auth_or_401():
            return
        parts = self._path_parts()
        if len(parts) == 2 and parts[0] == 'transactions':
            txid = parts[1]
            txs = load_data()
            for i, t in enumerate(txs):
                if str(t.get('id')) == str(txid):
                    removed = txs.pop(i)
                    save_data(txs)
                    return self._send_json({'deleted': removed})
            return self._send_json({'error':'not found'}, status=404)
        return self._send_json({'error':'endpoint not found'}, status=404)

def run(host='127.0.0.1', port=8000):
    httpd = HTTPServer((host, port), Handler)
    print(f"Serving on http://{host}:{port}")
    httpd.serve_forever()

if __name__ == '__main__':
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--host', default='127.0.0.1')
    ap.add_argument('--port', default=8000, type=int)
    args = ap.parse_args()
    run(args.host, args.port)
