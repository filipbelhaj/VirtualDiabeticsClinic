import json, os, pickle, hashlib, time, random
import numpy as np

def set_all_seeds(seed: int = 42):
    import numpy as _np
    import random as _rand
    _rand.seed(seed)
    _np.random.seed(seed)
    try:
        import torch
        torch.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
    except Exception:
        pass

def save_artifacts(out_dir: str, model, metrics: dict, extra_meta: dict):
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(out_dir, "model.pkl"), "wb") as f:
        pickle.dump(model, f)
    with open(os.path.join(out_dir, "metrics.json"), "w") as f:
        json.dump(metrics, f, indent=2, sort_keys=True)
    meta = {
        "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "python": os.sys.version.split()[0],
        **extra_meta,
    }
    with open(os.path.join(out_dir, "metadata.json"), "w") as f:
        json.dump(meta, f, indent=2, sort_keys=True)

def load_model(model_dir: str):
    with open(os.path.join(model_dir, "model.pkl"), "rb") as f:
        return pickle.load(f)

def gitsha_for_build_context():
    return os.getenv("GITHUB_SHA", "")[:7]

def rmse(y_true, y_pred):
    return float(np.sqrt(np.mean((np.asarray(y_true) - np.asarray(y_pred)) ** 2)))

def quantile_threshold(y_pred_train, q=0.8):
    return float(np.quantile(np.asarray(y_pred_train), q))
