import argparse, json, os
from sklearn.datasets import load_diabetes
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression, Ridge
from sklearn.metrics import r2_score
from src.utils import set_all_seeds, save_artifacts, rmse, quantile_threshold, gitsha_for_build_context
from src.versions import V01

def train(version: str, seed: int = 42, test_size: float = 0.2, out_root: str = "model/artifacts"):
    assert version in ALL, f"Unknown version: {version}"

    set_all_seeds(seed)

    Xy = load_diabetes(as_frame=True)
    X = Xy.frame.drop(columns=["target"])
    y = Xy.frame["target"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=seed
    )

    pipe = Pipeline([("scaler", StandardScaler()), ("model", LinearRegression())])

    pipe.fit(X_train, y_train)
    y_hat_train = pipe.predict(X_train)
    y_hat_test = pipe.predict(X_test)

    metrics = {
        "rmse_train": rmse(y_train, y_hat_train),
        "rmse_test": rmse(y_test, y_hat_test),
        "r2_train": float(r2_score(y_train, y_hat_train)),
        "r2_test": float(r2_score(y_test, y_hat_test)),
        "n_train": int(len(y_train)),
        "n_test": int(len(y_test)),
        "version": version,
        "seed": seed,
        "test_size": test_size,
    }

    risk_threshold = quantile_threshold(y_hat_train, q=0.8)

    out_dir = os.path.join(out_root, version)

    # Save the usual artifacts (model + meta you already have)
    save_artifacts(
        out_dir=out_dir,
        model=pipe,
        metrics=metrics,
        extra_meta={
            "risk_threshold": risk_threshold,
            "gitsha": gitsha_for_build_context(),
            "features": list(X.columns),
        },
    )

    os.makedirs(out_dir, exist_ok=True)
    metrics_path = os.path.join(out_dir, "metrics.json")
    with open(metrics_path, "w") as f:
        json.dump(metrics, f, indent=2, sort_keys=True)

    print(json.dumps({"metrics_path": metrics_path, **metrics}, indent=2))
    return out_dir, metrics

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--version", default=V01, choices=list(ALL))
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--test-size", type=float, default=0.2)
    p.add_argument("--out-root", default="model/artifacts")
    args = p.parse_args()
    train(args.version, args.seed, args.test_size, args.out_root)
