# ---------- Base image ----------
FROM python:3.11-slim AS base

# Avoid Python .pyc files and enable unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create a virtual env for clean installs
ENV VENV_PATH=/opt/venv
RUN python -m venv $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"

# System deps (build essentials for some wheels; remove if not needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---------- Install Python deps ----------
# Copy only requirements first to leverage Docker layer caching
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt

# ---------- Copy project ----------
# Copy the source code (src-layout project)
COPY src/ /app/src

# If you have other files (e.g., .env.example, static, templates), copy as needed:
# COPY static/ /app/static
# COPY templates/ /app/templates

# Ensure Python can import from src/
ENV PYTHONPATH=/app/src

# Network
EXPOSE 8080

# ---------- Security: run as non-root ----------
RUN useradd -m appuser
USER appuser

# ---------- Start command ----------
# Points Uvicorn at the FastAPI app inside src/app/main.py
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

