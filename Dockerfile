FROM mcr.microsoft.com/playwright/python:v1.51.0-jammy

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy bot
COPY bot.py .

# Chromium is already installed in the base image; tell Playwright where to find it
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

CMD ["python3", "bot.py"]
