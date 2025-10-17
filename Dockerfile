# ===== Base image =====
FROM python:3.11-slim AS base

# Avoid interactive prompts & speed up pip
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# System deps (build tools only if needed by wheels)
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create app user & dirs
WORKDIR /app
RUN adduser --disabled-password --gecos "" appuser
# We’ll put your source at /app (so PYTHONPATH=/app makes 'app.*' imports work)
ENV PYTHONPATH=/app

# ===== Dependency layer =====
# If you have a requirements.txt, keep this section. If you use Poetry, see the note below.
COPY requirements.txt /app/requirements.txt
RUN pip install -U pip && pip install -r /app/requirements.txt

# ===== App layer =====
# Copy only the source first (faster rebuilds)
COPY src/ /app/

# If your package needs extra files at repo root (e.g., .env.example, config), COPY them here.
# COPY .env /app/.env

# Drop privileges
RUN chown -R appuser:appuser /app
USER appuser

# Network
EXPOSE 8080

# Start the FastAPI app located at src/app/main.py -> module "app.main", object "app"
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
