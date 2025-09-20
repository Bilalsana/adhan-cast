#!/bin/bash

# Define the name of the environment file
ENV_FILE=".env"

# --- Check if setup has already been run ---
if [ -f "$ENV_FILE" ]; then
    echo "Setup has already been completed. Starting the application..."
    docker-compose up -d
    exit 0
fi

echo "--- First-Time Setup for Adhan Caster ---"

# --- Step 1: Install catt locally if not found ---
if ! command -v catt &> /dev/null; then
    echo "'catt' command not found. Attempting to install it locally with pip..."
    if ! command -v pip &> /dev/null; then
        echo "Error: 'pip' is not installed. Please install Python and pip to continue."
        exit 1
    fi
    pip install catt
    # Check again
    if ! command -v catt &> /dev/null; then
        echo "Error: 'catt' installation failed. Please install it manually ('pip install catt')."
        exit 1
    fi
fi

# --- Step 2: Scan for Chromecast devices ---
echo ""
echo "Scanning for Chromecast devices on your network..."
# Run catt scan and store the output
DEVICE_SCAN=$(catt scan)

if [ -z "$DEVICE_SCAN" ]; then
    echo "No Chromecast devices found. Please ensure they are on the same network and try again."
    exit 1
fi

echo "Found the following devices:"
echo "$DEVICE_SCAN"
echo ""

# --- Step 3: User selects devices ---
echo "Enter the names of the devices you want to use, separated by commas."
echo "Example: Living Room display,Bedroom Speaker"
read -p "Device Names: " SELECTED_DEVICES

if [ -z "$SELECTED_DEVICES" ]; then
    echo "No devices selected. Exiting setup."
    exit 1
fi

# --- Step 4: Ask for location and other settings ---
echo ""
read -p "Enter your Latitude (e.g., 24.7136): " LAT
read -p "Enter your Longitude (e.g., 46.6753): " LNG
read -p "Enter your Timezone (e.g., Asia/Riyadh): " TZ

# --- Step 5: Create the .env file ---
echo "Creating configuration file ($ENV_FILE)..."
{
    echo "# Adhan Caster Configuration"
    echo "COMPOSE_PROJECT_NAME=adhancaster"
    echo "TZ=${TZ:-Asia/Riyadh}"
    echo "LAT=${LAT:-24.7136}"
    echo "LNG=${LNG:-46.6753}"
    echo "CAST_DEVICES=${SELECTED_DEVICES}"
    echo "METHOD=Makkah"
    echo "ADHAN_FILE=/app/adhan.webm"
} > $ENV_FILE

echo ""
echo "Configuration saved successfully!"

# --- Step 6: Build and start the Docker container ---
echo "Building and starting the Docker container..."
docker-compose up --build -d

echo ""
echo "Adhan Caster is now running! You can view logs with 'docker-compose logs -f'."
