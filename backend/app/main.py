from fastapi import FastAPI, Body
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from app.core.config import settings
from app.api.routes import auth, protected
from app.services.cap_parser import parse_cap_xml

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="OpenRescue Decentralized Emergency System API",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost", "http://localhost:3000", "http://127.0.0.1", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(protected.router, prefix="/api", tags=["protected"])

@app.get("/health")
def health_check():
    return {"status": "ok", "service": settings.PROJECT_NAME}

class XMLPayload(BaseModel):
    xml_data: str

@app.post("/parse-cap")
def parse_cap(payload: XMLPayload):
    try:
        result = parse_cap_xml(payload.xml_data)
        return {"status": "success", "data": result}
    except ValueError as e:
        return {"status": "error", "message": str(e)}
