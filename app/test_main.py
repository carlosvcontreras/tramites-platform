from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_tramite_existe():
    r = client.get("/tramites/1001")
    assert r.status_code == 200
    assert r.json()["estado"] == "RECIBIDO"


def test_tramite_no_existe():
    assert client.get("/tramites/9999").status_code == 404
