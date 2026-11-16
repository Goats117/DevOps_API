FROM python:3.11-slim
WORKDIR /app

# 1. Patch the OS layer
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# 2. Purge the vulnerable baked-in package, then cleanly install the secure versions
RUN pip uninstall -y setuptools && \
    pip install --no-cache-dir "setuptools>=78.1.1" fastapi uvicorn

COPY main.py .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]