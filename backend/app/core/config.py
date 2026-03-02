# SPDX-License-Identifier: GPL-3.0-or-later
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "OpenRescue"
    VERSION: str = "0.1.0"
    ENVIRONMENT: str = "development"
    
    # DB
    DB_USER: str = "openrescue"
    DB_PASSWORD: str = "openrescue_pass"
    DB_HOST: str = "db"
    DB_PORT: str = "5432"
    DB_NAME: str = "openrescue_db"
    
    # Redis
    REDIS_URL: str = "redis://redis:6379/0"
    
    # JWT Auth
    SECRET_KEY: str = "DEV_SECRET_KEY"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # DB URL override
    DATABASE_URL: str | None = None

    class Config:
        env_file = ".env"

settings = Settings()
