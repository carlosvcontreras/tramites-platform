# ---- Etapa 1: builder. Instala dependencias en un venv. ----
FROM python:3.12-slim AS builder
WORKDIR /build
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- Etapa 2: runtime. Solo el venv y el código; sin pip cache ni herramientas de build. ----
FROM python:3.12-slim
RUN useradd --uid 10001 --no-create-home app
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY app/main.py .
ENV PATH="/opt/venv/bin:$PATH" PYTHONUNBUFFERED=1 PORT=8080
# Usuario no-root
USER 10001
EXPOSE 8080
# Cloud Run define PORT; se lee con sh -c.
# "exec" reemplaza al shell por uvicorn: uvicorn queda como PID 1 y recibe las señales
# (Ctrl+C en local, SIGTERM de Cloud Run al apagar una instancia) y se detiene limpio.
CMD ["sh", "-c", "exec uvicorn main:app --host 0.0.0.0 --port ${PORT}"]
