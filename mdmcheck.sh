#!/bin/bash

TARGET_NAME="Data"
CONFIG_PROFILE_DIR="/Volumes/$TARGET_NAME/private/var/db/ConfigurationProfiles/Settings/"
NO_MDM_FILE=".cloudConfigNoActivationRecord"
HAS_MDM_FILE=".cloudConfigHasActivationRecord"

# Check if "Data" already exists in /Volumes
if [ -d "/Volumes/$TARGET_NAME" ]; then
  # Skip renaming if /Volumes/Data exists
  :
else
  # Find APFS volumes ending with "- Data"
  matched_volumes=$(diskutil list | grep -i "APFS Volume" | grep -E "\-Data\s" | awk '{$1=$1};1')

  if [ -z "$matched_volumes" ]; then
    exit 1
  fi

  # Rename each matching volume to "Data"
  while IFS= read -r line; do
    volume_name=$(echo "$line" | awk '{print $4}')
    disk_identifier=$(echo "$line" | awk '{print $NF}')
    
    diskutil rename "$disk_identifier" "$TARGET_NAME"
  done <<< "$matched_volumes"
fi

# Wait briefly to allow system to remount renamed volume
sleep 2

# Check if the directory exists
if [ ! -d "$CONFIG_PROFILE_DIR" ]; then
  exit 1
fi

# Check for MDM indicator files
if [ -f "$CONFIG_PROFILE_DIR/$HAS_MDM_FILE" ]; then
  echo "MDM Found"
elif [ -f "$CONFIG_PROFILE_DIR/$NO_MDM_FILE" ]; then
  echo "MDM Not Found"
else
  echo "Past UI setup not done properly"
fi
