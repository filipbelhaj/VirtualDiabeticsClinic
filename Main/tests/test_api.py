import json, os
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert "model_version" in r.json()

def test_predict_ok():
    payload = {
        "age": 0.02, "sex": -0.044, "bmi": 0.06, "bp": -0.03,
        "s1": -0.02, "s2": 0.03, "s3": -0.02, "s4": 0.02,
        "s5": 0.02, "s6": -0.001
    }
    r = client.post("/predict", json=payload)
    assert r.status_code == 200
    body = r.json()
    assert "prediction" in body and isinstance(body["prediction"], float)

def test_predict_bad_input():
    r = client.post("/predict", json={"oops": 1})
    assert r.status_code == 422 or r.status_code == 400
