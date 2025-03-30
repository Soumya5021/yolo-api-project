# Stage 1: Builder
FROM python:3.8-slim AS builder

WORKDIR /wheels

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir wheel && \
    pip wheel --no-cache-dir --wheel-dir=/wheels -r requirements.txt

# Stage 2: Runtime
FROM python:3.8-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /wheels /wheels
COPY requirements.txt .
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt && \
    rm -rf /wheels requirements.txt

COPY app/ ./app/

RUN useradd -u 1001 appuser && \
    chown -R appuser:appuser /app

# Fix writable directories and environment variables
ENV MPLCONFIGDIR=/tmp/matplotlib \
    YOLO_CONFIG_DIR=/tmp/ultralytics \
    UPLOAD_FOLDER=/tmp/uploads

RUN mkdir -p ${MPLCONFIGDIR} ${YOLO_CONFIG_DIR} ${UPLOAD_FOLDER} && \
    chown appuser:appuser ${MPLCONFIGDIR} ${YOLO_CONFIG_DIR} ${UPLOAD_FOLDER}

USER appuser

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]