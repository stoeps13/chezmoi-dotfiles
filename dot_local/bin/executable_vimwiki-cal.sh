#!/usr/bin/env bash

# Default values
start_date="$(date +%Y-%m-%d)" # Default is today
num_days=30

# Parse command line options
while getopts "d:n:" opt; do
  case $opt in
    d) start_date="$OPTARG" ;;
    n) num_days="$OPTARG" ;;
    *) echo "Usage: $0 [-d start_date(YYYY-MM-DD)] [-n num_days]" >&2
       exit 1 ;;
  esac
done

# Validate date format
if ! date -d "$start_date" >/dev/null 2>&1; then
    echo "Error: Invalid date format. Please use YYYY-MM-DD format." >&2
    exit 1
fi

# Validate num_days is a positive integer
if ! [[ "$num_days" =~ ^[0-9]+$ ]]; then
    echo "Error: Number of days must be a positive integer." >&2
    exit 1
fi

# Convert to date format for manipulation
start_timestamp=$(date -d "$start_date" +%s)

# Loop through each day
for ((i=0; i<num_days; i++)); do
    # Calculate current date
    current_timestamp=$((start_timestamp + i*86400))

    # Format dates as needed
    day_display=$(date -d "@$current_timestamp" +%d.%m.%Y)
    iso_date=$(date -d "@$current_timestamp" +%Y-%m-%d)
    weekday=$(date -d "@$current_timestamp" +%A)

    # Print date header in the desired format with weekday
    printf "## [$weekday, $day_display]($iso_date)\n\n"

    # Get khal output for this day
    khal_output=$(khal list -o "$day_display" --day-format "" --format "### {start-end-time-style} {title}" 1d)

    # Print the output, or a placeholder if empty
    if [ -z "$khal_output" ]; then
        printf "* No events\n"
    else
        printf "$khal_output\n"
    fi

    printf "\n"
done
