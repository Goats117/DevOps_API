FROM python:3.11-slim
WORKDIR /app

# 1. Patch the OS layer
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# 2. Patch the global Python layer (fixes CVE-2025-47273)
RUN pip install --upgrade pip "setuptools>=78.1.1"

# 3. Install the application dependencies
RUN pip install fastapi uvicorn

COPY main.py .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]