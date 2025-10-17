# Virtual Diabetes Clinic — Progression Risk Scorer

A tiny ML service that predicts short-term diabetes progression (regression on the open scikit-learn diabetes dataset) and exposes a REST API for triage.

## Quickstart (local)

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
uvicorn app.main:app --port 8080
