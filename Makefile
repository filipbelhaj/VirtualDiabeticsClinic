PY=python

.PHONY: setup train-v01 serve docker-v01 test lint

setup:
	$(PY) -m pip install -r requirements-dev.txt

train-v01:
	$(PY) -m src.train --version v0.1

serve:
	uvicorn app.main:app --reload --port 8080

test:
	pytest -q

lint:
	ruff check .
