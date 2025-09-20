# Use a slim, Debian-based Python image
FROM python:3.9-slim-bullseye

# Set the timezone to Riyadh
ENV TZ=Asia/Riyadh

# Set default configuration (can be overridden during 'docker run')
ENV LAT="24.7136"
ENV LNG="46.6753"
ENV METHOD="Makkah"
ENV CAST_DEVICE="Living Room display"
ENV ADHAN_FILE="/app/adhan.webm"

# Install system dependencies: cron for scheduling and others for network discovery
RUN apt-get update && apt-get install -y \
    cron \
    nano \	
    wget \
    libnss-mdns \
    avahi-daemon \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy all your application files (Python scripts, crontab folder)
COPY . .

# Install the 'catt' Python package
RUN pip install --no-cache-dir catt

# Download a default adhan file during the build
#RUN wget -O adhan.webm "https://archive.org/download/AdhanMakkah/AdhanMakkah.webm"

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint to our custom script
ENTRYPOINT ["entrypoint.sh"]

# The command that the entrypoint will run: start cron in the foreground
CMD ["cron", "-f"]
