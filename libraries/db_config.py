import os
from dotenv import load_dotenv

_REQUIRED = ("DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME")


def get_db_config():
    """
    Returns DB connection config dict.
    Locally: loads .env.db if present.
    CI/CD: reads DB_HOST/DB_USER/DB_PASSWORD/DB_NAME directly from environment variables.
    Raises EnvironmentError if any variable is missing from both sources.
    """
    if os.path.exists(".env.db"):
        load_dotenv(dotenv_path=".env.db", override=True)

    missing = [k for k in _REQUIRED if not os.getenv(k)]
    if missing:
        raise EnvironmentError(
            f"Missing DB variable(s): {', '.join(missing)}. "
            "Set via .env.db locally or environment variables in CI."
        )

    return {
        "host": os.getenv("DB_HOST"),
        "user": os.getenv("DB_USER"),
        "password": os.getenv("DB_PASSWORD"),
        "db": os.getenv("DB_NAME"),
    }
