import os, json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, ValidationError
from typing import Optional
from src.utils import load_model

MODEL_VERSION = os.getenv("MODEL_VERSION", "v0.1")
MODEL_DIR = os.getenv("MODEL_DIR", f"/app/model/artifacts/{MODEL_VERSION}")
METRICS_PATH = os.path.join(MODEL_DIR, "metrics.json")
META_PATH = os.path.join(MODEL_DIR, "metadata.json")

class DiabetesFeatures(BaseModel):
    age: float = Field(..., description="Normalized age")
    sex: float = Field(..., description="Normalized sex code")
    bmi: float
    bp: float
    s1: float
    s2: float
    s3: float
    s4: float
    s5: float
    s6: float

app = FastAPI(title="Virtual Diabetes Clinic - Progression Scorer", version=MODEL_VERSION)

_model = None
_meta = {}

def get_model():
    global _model, _meta
    if _model is None:
        try:
            _model = load_model(MODEL_DIR)
            with open(META_PATH) as f:
                _meta = json.load(f)
        except Exception as e:
            raise RuntimeError(f"Failed to load model: {e}")
    return _model

@app.get("/health")
def health():
    try:
        get_model()
        return {"status": "ok", "model_version": MODEL_VERSION}
    except Exception as e:
        return {"status": "error", "error": str(e), "model_version": MODEL_VERSION}

@app.post("/predict")
def predict(features: DiabetesFeatures):
    try:
        model = get_model()
        X = [[
            features.age, features.sex, features.bmi, features.bp,
            features.s1, features.s2, features.s3, features.s4,
            features.s5, features.s6
        ]]
        yhat = float(model.predict(X)[0])
        risk_threshold = float(_meta.get("risk_threshold", 1000.0))
        risk_score = yhat 
        high_risk = bool(risk_score >= risk_threshold)
        return {
            "prediction": yhat,
            "risk_score": risk_score,
            "high_risk": high_risk,
            "model_version": MODEL_VERSION
        }
    except ValidationError as ve:
        raise HTTPException(status_code=400, detail={"error": "validation_error", "details": ve.errors()})
    except Exception as e:
        raise HTTPException(status_code=400, detail={"error": "prediction_error", "details": str(e)})
