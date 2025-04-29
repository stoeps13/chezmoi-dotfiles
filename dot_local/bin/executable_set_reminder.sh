#!/usr/bin/bash
# The line below extracts the events in each line and add quotes to them so for loop will loop through each of them
# Delete at entries
for i in $(ssh stoeps@lnx-stwsh atq | awk '{print $1}'); do
  ssh stoeps@lnx-stwsh atrm $i
done

items=$(khal list -a work -o $(date +"%d.%m.%Y") 1d | tail -n +2)
echo  "$items"|while read -r rem
do
    rm_time=$(($(date +%s --date "`echo $rem | sed -n 's/^\([0-9][0-9]:[0-9][0-9]\)-.*/\1:00/p'`") - 600))
    rm_time=$(date +%H:%M --date @$rm_time) # This converts EPOCH back to human readble form

    rm_time_5=$(($(date +%s --date "`echo $rem | sed -n 's/^\([0-9][0-9]:[0-9][0-9]\)-.*/\1:00/p'`") - 300))
    rm_time_5=$(date +%H:%M --date @$rm_time_5) # This converts EPOCH back to human readble form

    rem_name=$(echo $rem | sed -n 's/.*:[0-9][0-9] \(.*\)/\1/p')
    echo "notify-send -u high -i /var/home/stoeps/.config/khal/cal.png 'Calendar Reminder' '$rem_name'" | ssh stoeps@lnx-stwsh at $rm_time today
    echo "notify-send -u critical -i /var/home/stoeps/.config/khal/cal.png 'Calendar Reminder' '$rem_name'" | ssh stoeps@lnx-stwsh at $rm_time_5 today
    echo "pw-cat -p ~/.config/khal/clock-alarm-8761.mp3 --target alsa_output.pci-0000_00_1f.3.analog-stereo --volume 0.3" | ssh stoeps@lnx-stwsh at $rm_time_5 today
done
exit
