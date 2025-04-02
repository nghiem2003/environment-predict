# Use the official Python base image
FROM python:3.10

# Set working directory
WORKDIR /app

# Copy dependencies first
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Expose Flask API port
EXPOSE 5001

# Start the Flask app
CMD ["python", "test_api.py"]
