# syntax=docker/dockerfile:1.7

########## build (train) stage ##########
FROM python:3.11-slim AS train
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app/src

# Install deps first for better layer caching
COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy source
COPY src ./src

# Version arg (default) -> env so RUN can use it
ARG MODEL_VERSION=v0.1
ENV MODEL_VERSION=${MODEL_VERSION}

# Train and write artifacts into /app/model/artifacts/<version>
RUN python -m src.train --version "${MODEL_VERSION}" --out-root /app/model/artifacts


########## runtime stage ##########
FROM python:3.11-slim AS runtime
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app/src

# Non-root user
RUN adduser --disabled-password --gecos "" appuser

# Install only runtime deps
COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Bring application source
COPY --chown=appuser:appuser src ./src

# Bring trained artifacts from build stage
ARG MODEL_VERSION=v0.1
ENV MODEL_VERSION=${MODEL_VERSION}
ENV MODEL_DIR=/app/model/artifacts/${MODEL_VERSION}
COPY --from=train --chown=appuser:appuser /app/model /app/model

EXPOSE 8080
USER appuser

# If your FastAPI app is under src/app/main.py,
# PYTHONPATH=/app/src makes `app.main:app` importable.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
