# Lightweight, multi-arch base image
FROM python:3.11-slim

# Avoid .pyc, use unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src

# Create app dir
WORKDIR /app

# Install system deps (if you need build tools, uncomment)
# RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

# Copy dependency files first for better caching
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy source
COPY src ./src

# If your API needs model artifacts at runtime, either:
# A) generate them during build (uncomment the next two lines and ensure the train script exists)
# COPY Makefile ./Makefile
# RUN make train-v01
# or B) mount artifacts at runtime (document this in README)

EXPOSE 8080

# Healthcheck (optional)
# HEALTHCHECK CMD wget -qO- http://localhost:8080/health || exit 1

# Start FastAPI (package name is "app" under src/)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

