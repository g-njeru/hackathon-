from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "postgresql+asyncpg://postgres:password@localhost:5432/hackathon"
    redis_url: str = "redis://localhost:6379"
    jwt_secret: str = "change-me-in-production"
    debug: bool = False

    class Config:
        env_file = ".env"


settings = Settings()
