# Adhan Caster 🕌

A simple, self-hosted Docker application that calculates daily Islamic prayer times for any location and automatically casts the Adhan (call to prayer) to Google Cast / Chromecast devices on your network.

---

## Features

- **Automatic Prayer Time Calculation**: Fetches daily prayer times from Aladhan API based on your configured location and calculation method.
- **Daily Cron Updates**: Automatically updates its own schedule every day at 3:15 AM to ensure prayer times are always accurate.
- **Multi-Device Casting**: Casts the Adhan simultaneously to multiple Chromecast and Google Nest devices.
- **Dockerized & Portable**: Runs in a lightweight Docker container, making it easy to deploy on any system that runs Docker (like a Raspberry Pi, home server, or NAS).
- **Highly Configurable**: Easily change your location, calculation method, and target devices using environment variables.

---

## Setup Instructions

This project is designed to be run with Docker and Docker Compose. Choose the setup method you prefer.

### Method 1: Manual Setup (Recommended)

This method is best if you are comfortable editing configuration files.

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/Bilalsana/adhan-cast.git](https://github.com/Bilalsana/adhan-cast.git)
    cd adhan-cast
    ```

2.  **Configure the Application**
    Open the `docker-compose.yml` file with a text editor. Find the `environment` section and edit the variables to match your setup.

    *A default `adhan.webm` audio file is included. If you wish to use your own, replace the file in this directory and update the `ADHAN_FILE` variable below if the filename is different.*

    ```yaml
    services:
      adhan-caster:
        # ...
        environment:
          # REQUIRED: Set your timezone from this list: [https://en.wikipedia.org/wiki/List_of_tz_database_time_zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
          - TZ=Asia/Riyadh

          # REQUIRED: Set your location's latitude and longitude
          - LAT=24.7136
          - LNG=46.6753

          # REQUIRED: Set the exact names of your Chromecast devices, separated by commas
          - CAST_DEVICES=Living Room display,Bedroom Speaker
          
          # This points to the included audio file. Change it if you use a different file.
          - ADHAN_FILE=/app/adhan.webm

          # OPTIONAL: Set the prayer time calculation method (Makkah, ISNA, Egypt, etc.)
          - METHOD=Makkah
    ```

3.  **Build and Run the Container**
    From the project's root directory, run the following command:
    ```bash
    docker-compose up --build -d
    ```

---

### Method 2: Interactive Setup Script

This method is best if you want a guided setup that automatically finds your devices.

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/Bilalsana/adhan-cast.git](https://github.com/Bilalsana/adhan-cast.git)
    cd adhan-cast
    ```

2.  **Run the Interactive Setup**
    Simply run the setup script. It will scan for your devices and guide you through the configuration process.
    ```bash
    ./OPTIONALsetup.sh
    ```

The script will ask for your device names and location, create a `.env` configuration file, and start the application for you.

---

## Managing the Service

-   **To view the logs**:
    ```bash
    docker-compose logs -f
    ```
-   **To stop the service**:
    ```bash
    docker-compose down
    ```
-   **To restart the service**:
    ```bash
    docker-compose restart
    ```
