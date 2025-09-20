#!/usr/bin/env python

import datetime
import time
import sys
import os
from os.path import join as pathjoin

# Import the local praytimes.py directly
from praytimes import PrayTimes

# --- Configuration ---
PT = PrayTimes()
CRON_FILE = '/etc/cron.d/prayer-cron'
LOG_FILE = '/app/adhan.log'
ROOT_DIR = '/app'

# --- Read Configuration from Environment Variables ---
LAT = float(os.getenv('LAT', '24.7136'))
LNG = float(os.getenv('LNG', '46.6753'))
METHOD = os.getenv('METHOD', 'Makkah')
CAST_DEVICES_STR = os.getenv('CAST_DEVICES', 'Living Room display')
ADHAN_FILE = os.getenv('ADHAN_FILE', '/app/adhan.webm')

print("--- Adhan Clock Configuration ---")
print(f"Latitude: {LAT}, Longitude: {LNG}, Method: {METHOD}")
print(f"Cast Devices: {CAST_DEVICES_STR}")
print(f"Adhan File: {ADHAN_FILE}")
print("-------------------------------")

# --- Main Script ---
# Set calculation method
PT.setMethod(METHOD)
utcOffset = -(time.timezone / 3600)
isDst = time.localtime().tm_isdst
now = datetime.datetime.now()

# --- Build the correct shell command for casting ---
device_list = [device.strip() for device in CAST_DEVICES_STR.split(',')]
catt_commands = [f'catt -d "{device}" cast {ADHAN_FILE}' for device in device_list]
# This creates a perfectly formatted shell command:
# catt -d "Device 1" cast file.webm & catt -d "Device 2" cast file.webm
play_command = " & ".join(catt_commands)
play_command_with_log = f"{play_command} >> {LOG_FILE} 2>&1"


# --- Generate the cron file content as a list of strings ---
cron_lines = []
cron_lines.append("# This file is auto-generated. Do not edit manually.")
cron_lines.append("SHELL=/bin/sh")
cron_lines.append(f"PATH=/usr/local/bin:/usr/bin:/bin")
cron_lines.append("") # Blank line for readability

# --- Calculate prayer times ---
times = PT.getTimes((now.year, now.month, now.day), (LAT, LNG), utcOffset, isDst)
prayer_names = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']

# Add prayer time jobs
for prayer in prayer_names:
    hour, minute = times[prayer].split(':')
    cron_lines.append(f"{minute} {hour} * * * root {play_command_with_log} # {prayer}")
    print(f"Scheduled {prayer} at {hour}:{minute}")

# Add maintenance jobs
update_command = f"python3 {ROOT_DIR}/updateAzaanTimers.py >> {LOG_FILE} 2>&1"
cron_lines.append(f"15 3 * * * root {update_command} # daily_update")
print("Scheduled daily update job for 03:15")

clear_logs_command = f"truncate -s 0 {LOG_FILE}"
cron_lines.append(f"0 0 1 * * root {clear_logs_command} # monthly_log_clear")
print("Scheduled monthly log clearing job")

# --- Write the content to the cron file ---
try:
    with open(CRON_FILE, 'w') as f:
        for line in cron_lines:
            f.write(line + "\n")
    print(f"Successfully wrote {len(prayer_names) + 2} jobs to {CRON_FILE}")
except Exception as e:
    print(f"ERROR: Failed to write to cron file: {e}")

print(f"Script execution finished at: {datetime.datetime.now()}")
