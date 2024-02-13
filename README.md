# Plex Sessions Monitor

## Overview

This script is designed to monitor active sessions on your Plex server and send alerts via Discord webhook if users exceed a specified maximum number of sessions.

## Prerequisites

- Bash environment
- [xmlstarlet](http://xmlstar.sourceforge.net/)
- Access to your Plex server
- Discord webhook URL

## Installation

1. Clone or download this repository.
2. Install `xmlstarlet` if not already installed (`sudo apt-get install xmlstarlet`).
3. Set up a Discord webhook and obtain the webhook URL.
4. Configure the variables in the script according to your Plex server setup and desired maximum session limit.

## Usage

1. Make the script executable:
    ```bash
    chmod +x plex_sessions_monitor.sh
    ```

2. Run the script:
    ```bash
    ./plex_sessions_monitor.sh
    ```

3. (Optional) Make it a crontab every minute (crontab -e)
	```bash
	* * * * * ./plex_sessions_monitor.sh
	```
	
4. The script will check active sessions on your Plex server and send alerts to Discord if any user exceeds the maximum allowed sessions.

## Configuration

Before running the script, make sure to configure the following variables:

- `PLEX_TOKEN`: Your Plex authentication token.
- `PLEX_SERVER_IP`: IP address of your Plex server.
- `PLEX_SERVER_PORT`: Port on which your Plex server is running (default: 32400).
- `DISCORD_WEBHOOK_URL`: URL of your Discord webhook to receive alerts.
- `MAX_PROFILE_SESSIONS`: Maximum number of sessions allowed per user.

To find your Plex token, login to your Plex account, open your browser's developer tools (F12), navigate to request parameters, and locate the token.

## Disclaimer

This script is provided as-is without any guarantees or warranties. Use it at your own risk.

Feel free to re-use!
