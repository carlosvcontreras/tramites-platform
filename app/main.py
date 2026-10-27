"""API de consulta de estado de trámite (Ministerio de Trámites Ciudadanos, ficticio)."""
import os

from fastapi import FastAPI, HTTPException

app = FastAPI(title="tramites-api")

# Datos simulados. En la vida real esto vendría del sistema on-premise (SOAP).
TRAMITES = {
    "1001": "RECIBIDO",
    "1002": "EN_REVISION",
    "1003": "APROBADO",
}


@app.get("/health")
def health():
    # Cloud Run inyecta API_KEY desde Secret Manager.
    # Nunca se devuelve ni se imprime el valor: solo si está cargada.
    return {"status": "ok", "api_key_cargada": bool(os.getenv("API_KEY"))}


@app.get("/tramites/{numero}")
def estado_tramite(numero: str):
    estado = TRAMITES.get(numero)
    if estado is None:
        raise HTTPException(status_code=404, detail="Trámite no encontrado")
    return {"numero": numero, "estado": estado}
