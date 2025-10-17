oFROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src ./src

EXPOSE 8080

# Set this to your actual module path:
# e.g., main:app  OR  api.main:app
ENV MODULE_PATH=main:app

# Use --app-dir so you don't need an "app" package/folder
CMD uvicorn --app-dir /src ${MODULE_PATH} --host 0.0.0.0 --port 8080
