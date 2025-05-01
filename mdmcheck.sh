#!/bin/bash

TARGET_NAME="Data"
CONFIG_PROFILE_DIR="/Volumes/$TARGET_NAME/private/var/db/ConfigurationProfiles/Settings/"
NO_MDM_FILE=".cloudConfigNoActivationRecord"
HAS_MDM_FILE=".cloudConfigHasActivationRecord"

echo "Step 1: Renaming volumes ending in '- Data' to '$TARGET_NAME'..."

# Find APFS volumes ending in "- Data"
matched_volumes=$(diskutil list | grep -i "APFS Volume" | grep -E "\- Data\s" | awk '{$1=$1};1')

# if [ -z "$matched_volumes" ]; then
#   echo "❌ No volumes found ending in '- Data'."
# else
#   while IFS= read -r line; do
#     volume_name=$(echo "$line" | awk '{print $4}')
#     disk_identifier=$(echo "$line" | awk '{print $NF}')
    
#     echo "🔄 Renaming '$volume_name' ($disk_identifier) to '$TARGET_NAME'..."
#     diskutil rename "$disk_identifier" "$TARGET_NAME"
#   done <<< "$matched_volumes"
#   echo "✅ Rename complete."
# fi
   if [ -d "/Volumes/Macintosh HD - Data" ]; then
                diskutil rename "Macintosh HD - Data" "Data"
            fi

echo
echo "Step 2: Checking for MDM status under:"
echo "$CONFIG_PROFILE_DIR"
echo

# Wait briefly to allow system to remount renamed volume
sleep 2

# Check if the directory exists
if [ ! -d "$CONFIG_PROFILE_DIR" ]; then
  echo "⚠️ ConfigurationProfiles directory not found. Volume may not be mounted properly or path is incorrect."
  exit 1
fi

# Check for MDM indicator files
if [ -f "$CONFIG_PROFILE_DIR/$HAS_MDM_FILE" ]; then
  echo "✅ Has MDM detected (found $HAS_MDM_FILE)"
elif [ -f "$CONFIG_PROFILE_DIR/$NO_MDM_FILE" ]; then
  echo "❌ No MDM detected (found $NO_MDM_FILE)"
else
  echo "⚠️ Past UI setup not done properly (neither file found)"
fi
