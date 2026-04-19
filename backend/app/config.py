"""Application configuration via environment variables / .env file."""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/huaxia"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # LLM
    LLM_PROVIDER: str = "deepseek"  # deepseek / claude / qwen
    DEEPSEEK_API_KEY: str = ""
    DEEPSEEK_BASE_URL: str = "https://api.deepseek.com"
    CLAUDE_API_KEY: str = ""
    QWEN_API_KEY: str = ""

    # AMap
    AMAP_API_KEY: str = ""

    # MinIO
    MINIO_ENDPOINT: str = "localhost:9000"
    MINIO_ACCESS_KEY: str = "minioadmin"
    MINIO_SECRET_KEY: str = "minioadmin"
    MINIO_BUCKET: str = "huaxia"

    # Auth
    API_KEY: str = "dev-api-key"

    # Stable Diffusion
    SD_API_URL: str = "http://localhost:7860"

    class Config:
        env_file = ".env"


settings = Settings()
