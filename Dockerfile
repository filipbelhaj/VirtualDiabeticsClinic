FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt
RUN PIP install -no-cache-dir -r requirements.txt

COPY . .

RUN python src/train.py

EXPOSE 8080

CMD ["uvicorn", "src.predict_service:app", "--host", "0.0.0.0", "--port", "8080"]ß
