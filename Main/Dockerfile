# --- build (train) stage ---
FROM python:3.11-slim AS train
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1

COPY requirements.txt .
RUN python -m pip install --upgrade pip && pip install -r requirements.txt

COPY src ./src

# Declare ARG here and give a default
ARG MODEL_VERSION=v0.1
# Promote to ENV so later RUN lines can use it
ENV MODEL_VERSION=${MODEL_VERSION}

# Train and write artifacts into /app/model/artifacts/<version>
RUN python -m src.train --version "${MODEL_VERSION}" --out-root model/artifacts

# --- runtime stage ---
FROM python:3.11-slim AS runtime
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1
RUN adduser --disabled-password --gecos "" appuser

# Bring trained artifacts
COPY --from=train /app/model /app/model

COPY requirements.txt .
RUN python -m pip install --upgrade pip && pip install -r requirements.txt

COPY app ./app
COPY src ./src

# You must redeclare ARG in this stage if you reference it
ARG MODEL_VERSION=v0.1
ENV MODEL_VERSION=${MODEL_VERSION}
ENV MODEL_DIR=/app/model/artifacts/${MODEL_VERSION}

EXPOSE 8080
USER appuser

# Optional: install wget if you keep this healthcheck
# RUN apt-get update && apt-get install -y --no-install-recommends wget && rm -rf /var/lib/apt/lists/*
# HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
#   CMD wget -qO- http://127.0.0.1:8080/health || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
