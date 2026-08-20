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

    # Phase 3 infrastructure. Auth is enabled by default in production and can
    # be enabled in staging/dev with AUTH_REQUIRED=true.
    AUTH_REQUIRED: bool = Field(default=False)
    SUPABASE_URL: str = Field(default="", description="Supabase project URL; server-side only")
    SUPABASE_SERVICE_ROLE_KEY: str = Field(default="", description="Supabase service-role secret; server-side only")
    SUPABASE_JWT_SECRET: str = Field(default="", description="Supabase JWT secret; server-side only")
    SUPABASE_JWT_ISSUER: str = Field(default="", description="Expected Supabase JWT issuer")
    SUPABASE_JWT_AUDIENCE: str = Field(default="authenticated")
    SUPABASE_JWT_ALGORITHMS: List[str] = Field(default_factory=lambda: ["HS256"])
    DATABASE_URL: str = Field(default="", description="PostgreSQL URL; never sent to clients")
    DB_AUTO_CREATE: bool = Field(default=False, description="Development only; production uses migrations")
    USAGE_GENERATION_LIMIT: int = Field(default=100, description="Rolling 24-hour generation limit")
    USAGE_CAMPAIGN_LIMIT: int = Field(default=20, description="Rolling 24-hour campaign limit")
    USAGE_AI_REQUEST_LIMIT: int = Field(default=150, description="Rolling 24-hour AI request limit")

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT.lower() == "production"

    @property
    def async_database_url(self) -> str:
        if self.DATABASE_URL.startswith("postgresql://"):
            return self.DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://", 1)
        return self.DATABASE_URL

    @property
    def usage_limits(self) -> dict[str, int]:
        return {
            "generation": self.USAGE_GENERATION_LIMIT,
            "campaign": self.USAGE_CAMPAIGN_LIMIT,
            "ai_request": self.USAGE_AI_REQUEST_LIMIT,
        }

    @property
    def cors_origins(self) -> List[str]:
        if not self.CORS_ALLOWED_ORIGINS.strip():
            # In development, default to local web / emulator ports
            if not self.is_production:
                return ["http://localhost:3000", "http://127.0.0.1:3000", "http://localhost:8080"]
            return []
        return [origin.strip() for origin in self.CORS_ALLOWED_ORIGINS.split(",") if origin.strip()]


settings = Settings()
