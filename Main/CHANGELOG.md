
### `CHANGELOG.md`
```markdown
# Changelog

## v0.2
**What changed**
- Model: `StandardScaler + Ridge(alpha=1.0)` (was LinearRegression).
- Added calibrated risk threshold at train 80th percentile → response includes `risk_score` and `high_risk`.
- Release workflow builds `:v0.2`, smoke-tests, pushes to GHCR, publishes metrics.

**Metrics (seed=42, test_size=0.2)**
- RMSE (test): **53.78**
- R² (test): 0.42 (approx)
- Δ vs v0.1 RMSE: **–0.08** (slightly better, consistent across runs with fixed seed).
- Threshold (80th pct of train preds): saved in `metadata.json`.

## v0.1
**What changed**
- Baseline model: `StandardScaler + LinearRegression`.
- API `/health`, `/predict`.
- Docker image with baked model.
- CI pipeline: lint, tests, smoke train artifacts.

**Metrics (seed=42, test_size=0.2)**
- RMSE (test): **53.85**
- R² (test): ~0.42
