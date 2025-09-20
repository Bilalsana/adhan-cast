#!/bin/sh

echo "--- Starting Adhan Caster Entrypoint ---"

# Step 1: Capture all environment variables starting with a letter (to filter out some system ones)
# and save them to /etc/environment. The cron daemon will load this file.
echo "Saving environment variables for cron..."
printenv | grep '^[A-Z]' > /etc/environment

CRON_FILE="/etc/cron.d/prayer-cron"

# Step 2: Create an empty cron file with the correct permissions.
echo "Ensuring cron file exists with correct permissions..."
touch $CRON_FILE
chmod 644 $CRON_FILE

# Step 3: Run the Python script to perform the initial population of prayer times.
# It will now run with the full environment variables available.
echo "Running initial prayer time setup..."
python3 /app/updateAzaanTimers.py

# Step 4: Start the cron daemon in the foreground. It will now have the correct environment.
echo "Initial setup complete. Starting cron daemon..."
exec cron -f
