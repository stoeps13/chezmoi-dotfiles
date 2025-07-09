#!/usr/bin/env bash

# Rename screenshot files from "Screenshot From YYYY-MM-DD HH-MM-SS.png" 
# to "YYYYMMDD-HHMMSS.png"

for file in Screenshot\ From\ *.png; do
    # Check if file exists (handles case where no matching files found)
    if [[ ! -e "$file" ]]; then
        echo "No screenshot files found matching the pattern"
        break
    fi
    
    # Extract the date and time parts using parameter expansion
    # Remove "Screenshot From " prefix
    datetime="${file#Screenshot From }"
    # Remove ".png" suffix
    datetime="${datetime%.png}"
    
    # Extract date part (YYYY-MM-DD)
    date_part="${datetime%% *}"
    # Extract time part (HH-MM-SS)
    time_part="${datetime##* }"
    
    # Remove hyphens from date and time
    clean_date="${date_part//-/}"
    clean_time="${time_part//-/}"
    
    # Create new filename
    new_name="${clean_date}-${clean_time}.png"
    
    # Rename the file
    if [[ "$file" != "$new_name" ]]; then
        mv "$file" "$new_name"
        echo "Renamed: $file -> $new_name"
    fi
done
