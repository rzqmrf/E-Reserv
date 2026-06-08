from __future__ import annotations

from datetime import datetime
from typing import Any, List

import numpy as np
from fastapi import FastAPI
from pydantic import BaseModel, Field
from sklearn.metrics import mean_absolute_error
from sklearn.neural_network import MLPRegressor
from sklearn.preprocessing import MinMaxScaler


app = FastAPI(title="E-ReservLap AI Analytics Service")


class HistoryRow(BaseModel):
    day: int | None = None
    date: str
    revenue: float = Field(default=0, ge=0)
    bookings: int = Field(default=0, ge=0)
    dow: int | None = None
    dom: int | None = None


class PredictRequest(BaseModel):
    history: List[HistoryRow]


def moving_average_prediction(revenues: np.ndarray, days: int = 7) -> list[float]:
    recent = revenues[-7:] if len(revenues) else np.array([0.0])
    previous = revenues[-14:-7] if len(revenues) >= 14 else recent
    recent_avg = float(np.mean(recent)) if len(recent) else 0.0
    previous_avg = float(np.mean(previous)) if len(previous) else recent_avg
    growth = 0.0 if previous_avg <= 0 else (recent_avg - previous_avg) / previous_avg
    growth = float(np.clip(growth, -0.25, 0.25))
    return [max(0.0, recent_avg * (1 + growth * (i / days))) for i in range(1, days + 1)]


def build_training_data(rows: list[HistoryRow], revenues: np.ndarray, window: int = 7):
    x_values = []
    y_values = []
    for index in range(window, len(revenues)):
        row = rows[index]
        window_values = revenues[index - window:index]
        bookings = float(row.bookings)
        dow = float(row.dow if row.dow is not None else index % 7)
        dom = float(row.dom if row.dom is not None else (index % 30) + 1)
        x_values.append(np.append(window_values, [bookings, dow, dom]))
        y_values.append(revenues[index])
    return np.array(x_values), np.array(y_values)


def model_quality(actual: np.ndarray, predicted: np.ndarray) -> dict[str, Any]:
    if len(actual) == 0 or len(predicted) == 0:
        return {"mae": 0, "mape": 0, "confidence": 0}

    mae = float(mean_absolute_error(actual, predicted))
    non_zero = actual > 0
    if np.any(non_zero):
        mape = float(np.mean(np.abs((actual[non_zero] - predicted[non_zero]) / actual[non_zero])) * 100)
    else:
        mape = 0.0
    confidence = float(np.clip(100 - mape, 45, 96))
    return {"mae": round(mae), "mape": round(mape, 1), "confidence": round(confidence, 1)}


def predict_with_model(rows: list[HistoryRow], revenues: np.ndarray, days: int = 7, window: int = 7):
    baseline = moving_average_prediction(revenues, days)
    if len(revenues) < window + 3 or np.max(revenues) <= 0:
        return baseline, {
            "name": "Python Moving Average Baseline",
            "window": window,
            "training_samples": 0,
            "quality": {"mae": 0, "mape": 0, "confidence": 50},
        }

    x_values, y_values = build_training_data(rows, revenues, window)
    scaler_x = MinMaxScaler()
    scaler_y = MinMaxScaler()
    x_scaled = scaler_x.fit_transform(x_values)
    y_scaled = scaler_y.fit_transform(y_values.reshape(-1, 1)).ravel()

    model = MLPRegressor(
        hidden_layer_sizes=(12, 6),
        activation="relu",
        solver="adam",
        max_iter=900,
        random_state=42,
    )
    model.fit(x_scaled, y_scaled)

    fitted_scaled = model.predict(x_scaled)
    fitted = scaler_y.inverse_transform(fitted_scaled.reshape(-1, 1)).ravel()
    quality = model_quality(y_values, np.maximum(0, fitted))

    rolling = revenues[-window:].astype(float).copy()
    avg_bookings = float(np.mean([row.bookings for row in rows[-window:]])) if rows else 0.0
    non_zero_revenues = revenues[revenues > 0]
    historical_peak = float(np.max(non_zero_revenues)) if len(non_zero_revenues) else 0.0
    recent_avg = float(np.mean(revenues[-window:])) if len(revenues) else 0.0
    upper_bound = max(historical_peak * 1.35, recent_avg * 1.8, 0.0)
    predictions: list[float] = []
    for index in range(days):
        next_day = (rows[-1].dow + index + 1) % 7 if rows and rows[-1].dow is not None else index % 7
        next_dom = ((rows[-1].dom or 1) + index - 1) % 31 + 1 if rows else index + 1
        next_features = np.append(rolling, [avg_bookings, next_day, next_dom])
        x_next = scaler_x.transform([next_features])
        y_next_scaled = model.predict(x_next)[0]
        y_next_scaled = float(np.clip(y_next_scaled, 0.0, 1.0))
        y_next = scaler_y.inverse_transform([[y_next_scaled]])[0][0]
        y_next = max(0.0, float(y_next))
        y_next = (y_next * 0.7) + (baseline[index] * 0.3)
        if upper_bound > 0:
            y_next = min(y_next, upper_bound)
        predictions.append(y_next)
        rolling = np.append(rolling[1:], y_next)

    return predictions, {
        "name": "MLPRegressor",
        "window": window,
        "training_samples": int(len(x_values)),
        "features": ["revenue_window", "bookings", "day_of_week", "day_of_month"],
        "quality": quality,
    }


def build_recommendations(predictions: list[dict[str, Any]], growth: float, last_week_avg: float) -> list[str]:
    recommendations: list[str] = []
    if growth >= 12:
        recommendations.append("Siapkan slot tambahan pada jam ramai karena tren pendapatan diprediksi naik.")
    elif growth <= -12:
        recommendations.append("Pertimbangkan promo weekday atau paket grup untuk menahan penurunan pendapatan.")
    else:
        recommendations.append("Pertahankan strategi harga saat ini; tren 7 hari relatif stabil.")

    peak = max(predictions, key=lambda item: item["revenue"], default=None)
    if peak and peak["revenue"] > last_week_avg * 1.2:
        recommendations.append(f"Pantau kapasitas pada {peak['label']} karena proyeksi melewati rata-rata minggu lalu.")

    if not any(item["revenue"] > 0 for item in predictions):
        recommendations.append("Data pendapatan masih kosong; kumpulkan transaksi berstatus paid agar model makin akurat.")

    return recommendations[:3]


@app.get("/health")
def health():
    return {"status": "ok", "service": "ai-analytics", "model": "MLPRegressor"}


@app.post("/predict")
def predict(payload: PredictRequest):
    history = payload.history
    revenues = np.array([row.revenue for row in history], dtype=float)

    predicted_values, model_info = predict_with_model(history, revenues)
    predictions = [
        {
            "label": "Besok" if index == 0 else f"{index + 1} Hari",
            "revenue": round(value),
        }
        for index, value in enumerate(predicted_values)
    ]

    total_prediction = sum(item["revenue"] for item in predictions)
    average_daily = total_prediction / len(predictions) if predictions else 0
    last_week = revenues[-7:] if len(revenues) else np.array([0.0])
    last_week_avg = float(np.mean(last_week)) if len(last_week) else 0.0
    growth = 0.0 if last_week_avg <= 0 else ((average_daily - last_week_avg) / last_week_avg) * 100
    peak = max(predictions, key=lambda item: item["revenue"], default={"label": "-", "revenue": 0})

    return {
        "source": "python_ai_service",
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "model": model_info,
        "history": [row.model_dump() for row in history[-14:]],
        "predictions": predictions,
        "insight": {
            "total_prediction": round(total_prediction),
            "average_daily": round(average_daily),
            "trend": "meningkat" if growth >= 0 else "menurun",
            "growth_percent": round(abs(growth), 1),
            "peak_day": peak["label"],
            "peak_revenue": peak["revenue"],
            "recommendations": build_recommendations(predictions, growth, last_week_avg),
        },
    }
