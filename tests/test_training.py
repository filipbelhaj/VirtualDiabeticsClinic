from src.train import train
from src.versions import V01
import json, os

def test_train_v01(tmp_path):
    out, metrics = train(V01, seed=42, out_root=tmp_path.as_posix())
    assert os.path.exists(os.path.join(out, "model.pkl"))
    assert metrics["version"] == V01
