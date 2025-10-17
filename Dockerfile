# syntax=docker/dockerfile:1.7
FROM python:3.11-slim AS runtime
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app/src

# Install runtime deps
COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy service code + (possibly empty) artifacts dir from CI
COPY src ./src
COPY model/artifacts ./model/artifacts

# Versioned artifact directory (default v0.1)
ARG MODEL_VERSION=v0.1
ENV MODEL_VERSION=${MODEL_VERSION}
ENV MODEL_DIR=/app/model/artifacts/${MODEL_VERSION}

EXPOSE 8080
USER nobody
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
