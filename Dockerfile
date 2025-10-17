# Multi-arch base (works on amd64 + arm64)
FROM python:3.11-slim

# Fast, predictable Python and ensure app package import path
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src

# Work from /app
WORKDIR /app

# Install deps first for better layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy only what we need
COPY src ./src

# (Optional) copy model artifacts if you want them in the image
# COPY model/artifacts/v0.1 ./model/artifacts/v0.1

EXPOSE 8080

# Start the FastAPI app (module = app.main:app)
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

