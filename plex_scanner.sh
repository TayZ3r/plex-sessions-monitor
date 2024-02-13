#!/bin/bash

# Variables
PLEX_TOKEN="YOUR PLEX TOKEN" #(TO FIND : LOGIN TO YOUR PLEX ACCOUNT, PRESS F12, NAVIGATE IN REQUEST PARAMETERS, YOU'LL FIND IT THERE
PLEX_SERVER_IP="YOUR PLEX SERVER IP"
PLEX_SERVER_PORT="32400" # 32400 is default port
DISCORD_WEBHOOK_URL="YOUR WEBHOOK URL"
MAX_PROFILE_SESSIONS=3 # Alert will be raised if 3 sessions from the same user are active

# Retrieve  sessions
response=$(curl -s "http://$PLEX_SERVER_IP:$PLEX_SERVER_PORT/status/sessions?X-Plex-Token=$PLEX_TOKEN")

# Check if there are active sessions
session_count=$(echo "$response" | xmlstarlet sel -t -v "count(/MediaContainer/Video)")

declare -A user_sessions
declare -A session_details

if [ "$session_count" = "0" ]; then
    exit
else
    
    # Iterate on each session
    for i in $(seq 1 $session_count); do
        # Extraire le titre de la vidéo, le nom de l'utilisateur, le type de contenu et l'adresse IP
        user_title=$(echo "$response" | xmlstarlet sel -t -m "(/MediaContainer/Video)[$i]" -v "User/@title" -n)
        content_title=$(echo "$response" | xmlstarlet sel -t -m "(/MediaContainer/Video)[$i]" -v "@title" -n)
        content_type=$(echo "$response" | xmlstarlet sel -t -m "(/MediaContainer/Video)[$i]" -v "@type" -n)
        ip_address=$(echo "$response" | xmlstarlet sel -t -m "(/MediaContainer/Video)[$i]/Player" -v "@address" -n)
        
        # Naming of Series/Movies to display
        display_name="$content_title"
        if [ "$content_type" == "episode" ]; then
            series_title=$(echo "$response" | xmlstarlet sel -t -m "(/MediaContainer/Video)[$i]" -v "@grandparentTitle" -n)
            episode=$(echo "$response" | xmlstarlet sel -t -m "(/MediaContainer/Video)[$i]" -v "@index" -n)
            season=$(echo "$response" | xmlstarlet sel -t -m "(/MediaContainer/Video)[$i]" -v "@parentIndex" -n)
            display_name="$series_title (S$season:E$episode)"
        fi
        
        # Count the sessions of a user and store them
        if [[ -z ${user_sessions[$user_title]} ]]; then
            user_sessions[$user_title]=1
            session_details[$user_title]="Session 1: $display_name (IP: $ip_address)\n"
        else
            ((user_sessions[$user_title]++))
            session_num=${user_sessions[$user_title]}
            session_details[$user_title]+="Session $session_num: $display_name (IP: $ip_address)\n"
        fi
        

    done
fi

# Check and build alert message for users having too much sessions open
for user in "${!user_sessions[@]}"; do
    if [[ ${user_sessions[$user]} -ge $MAX_PROFILE_SESSIONS ]]; then
        # Build alert message
        alert_message="**:warning: WARNING : User $user is watching from ${user_sessions[$user]} different devices.**\n\n${session_details[$user]}"

        # Send alert message on Discord webhook
        curl -H "Content-Type: application/json" -d "{\"content\": \"$alert_message\"}" $DISCORD_WEBHOOK_URL
    fi
done

