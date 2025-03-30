from fastapi import FastAPI, Request
from prometheus_client import Counter, Histogram, generate_latest, REGISTRY
from fastapi.responses import PlainTextResponse
import time


app = FastAPI()

# Create custom metrics
YOLO_DETECTIONS = Counter(
    "yolo_detections_total",
    "Total number of objects detected",
    ["model_version"]
)


DETECTION_LATENCY = Histogram(
    "yolo_detection_latency_seconds",
    "Latency for object detection",
    ["model_version"]
)

# Add metrics endpoint
@app.get("/metrics")
async def metrics():
    return PlainTextResponse(generate_latest(REGISTRY))


# Your detection endpoint
@app.post("/detect")
async def detect(request: Request):
    start_time = time.time()

      
    # Get model version from headers
    model_version = request.headers.get("X-Model-Version", "v1")

    # Update metrics
    YOLO_DETECTIONS.labels(model_version=model_version).inc()
    DETECTION_LATENCY.labels(model_version=model_version).observe(time.time() - start_time)

    return {"objects": [...]}

