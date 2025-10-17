# syntax=docker/dockerfile:1.7

########## build (train) stage ##########
FROM python:3.11-slim AS train
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app/src

# Native tools if needed for building wheels during training
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY src ./src

# If training needs any data/config, make sure to COPY it here:
# COPY data ./data
# COPY configs ./configs

ARG MODEL_VERSION=v0.1
ENV MODEL_VERSION=${MODEL_VERSION}

# Extra logging to help debug failures
RUN set -eux; \
    python -V; \
    python -c "import sys,os; print('MODEL_VERSION=', os.getenv('MODEL_VERSION')); print('CWD=', os.getcwd()); import pkgutil; print('has src.train?', bool(pkgutil.find_loader('src.train')))"

# Train and write artifacts into /app/model/artifacts/<version>
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m src.train --version "${MODEL_VERSION}" --out-root /app/model/artifacts

########## runtime stage ##########
FROM python:3.11-slim AS runtime
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app/src

RUN adduser --disabled-password --gecos "" appuser

COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser src ./src
COPY --from=train --chown=appuser:appuser /app/model /app/model

ARG MODEL_VERSION=v0.1
ENV MODEL_VERSION=${MODEL_VERSION}
ENV MODEL_DIR=/app/model/artifacts/${MODEL_VERSION}

EXPOSE 8080
USER appuser
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

