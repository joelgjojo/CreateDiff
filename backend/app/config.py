from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field


class Settings(BaseSettings):
    """Strongly typed application configuration."""
    
    # Environment
    ENVIRONMENT: str = Field(default="development", description="runtime environment (development, staging, production)")
    HOST: str = Field(default="0.0.0.0", description="bind host")
    PORT: int = Field(default=8000, description="bind port")
    
    # Groq AI Credentials (Server-side ONLY)
    GROQ_API_KEY: str = Field(default="", description="Groq API key")
    GROQ_MODEL: str = Field(default="openai/gpt-oss-120b", description="Active Groq model name")
    GROQ_BASE_URL: str = Field(default="https://api.groq.com/openai/v1", description="Groq API Base URL")
    
    # Security & CORS
    CORS_ALLOWED_ORIGINS: str = Field(default="", description="Comma-separated list of allowed origins")
    
    # Rate Limiting (In-Memory IP Limiter)
    RATE_LIMIT_REQUESTS: int = Field(default=30, description="Allowed generation requests per window")
    RATE_LIMIT_WINDOW_SECONDS: int = Field(default=60, description="Rate limit window in seconds")
    
    # Request Payload Limits
    MAX_REQUEST_BODY_BYTES: int = Field(default=65536, description="Max request body size in bytes (64KB)")
    MAX_PROMPT_LENGTH: int = Field(default=2000, description="Max character length for user topic / idea")
    
    # Groq HTTP Client Timeouts (seconds)
    GROQ_CONNECT_TIMEOUT: float = Field(default=10.0, description="Groq connect timeout in seconds")
    GROQ_READ_TIMEOUT: float = Field(default=35.0, description="Groq read timeout in seconds")
    GROQ_TOTAL_TIMEOUT: float = Field(default=45.0, description="Groq overall timeout in seconds")

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT.lower() == "production"

    @property
    def cors_origins(self) -> List[str]:
        if not self.CORS_ALLOWED_ORIGINS.strip():
            # In development, default to local web / emulator ports
            if not self.is_production:
                return ["http://localhost:3000", "http://127.0.0.1:3000", "http://localhost:8080"]
            return []
        return [origin.strip() for origin in self.CORS_ALLOWED_ORIGINS.split(",") if origin.strip()]


settings = Settings()
