# SPDX-License-Identifier: GPL-3.0-or-later
from fastapi import FastAPI
from .core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="OpenRescue Decentralized Emergency System API",
)

@app.get("/health")
async def health_check():
    return {"status": "ok", "service": settings.PROJECT_NAME}
