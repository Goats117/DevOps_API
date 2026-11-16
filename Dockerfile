FROM python:3.11-slim
WORKDIR /app
RUN pip install wheel>=0.46.2 fastapi uvicorn
COPY main.py .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]