FROM python:3.11-slim
WORKDIR /app

# 1. Patch the OS layer (fixes zlib1g)
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# 2. Patch the Python layer (fixes setuptools, jaraco.context, and wheel) and install the API
RUN pip install --upgrade pip setuptools
RUN pip install fastapi uvicorn

COPY main.py .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]