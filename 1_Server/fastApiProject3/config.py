from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    redis_url: str
    redis_ip: str
    redis_port: str
    redis_db: str
    debug: bool

    class Config:
        env_file = ".env"
        env_file_encoding = 'utf-8'

settings = Settings()