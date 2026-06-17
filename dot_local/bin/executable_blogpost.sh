#!/usr/bin/env bash

# Copied from https://lazybea.rs/ils9-reading-bubbles/
#
INDIEBLOG="https://indieblog.page/random"
OOH="https://ooh.directory/random"
FEEDLE="https://feedle.world/random"
YAY="https://yay.boo"
BUBBLE="https://bubbles.town/random?lang=en"

TMP=/tmp/rp
OUT=/tmp/links
SEEN="$HOME/.seen_random_posts"
touch "$SEEN"

# Need to filter bubble link first
canonical=$(curl -Ls "https://bubbles.town/random?lang=en" | rg -i canonical | head -n1 | cut -d\" -f4)
target=$(curl -Ls "$canonical" | rg noopener | head -n1 | cut -d\" -f2)

[[ -n "$target" ]] && echo "$target" >> "$TMP"

# Get random links
# wget -O /dev/null ${INDIEBLOG} 2>&1 | grep -w 'Location' | sed -E 's/^[[:space:]]*Location:[[:space:]]*([^?]+).*/\1/' >> ${TMP}
curl -s ${INDIEBLOG} --write-out '%{json}' | jq .redirect_url | tr -d '"' >> ${TMP}
curl -Ls ${OOH} | rg cite | tail -1 | cut -d'"' -f2 >> ${TMP}
curl -Ls ${FEEDLE} | rg 'ref=feedle.world' | uniq | tail -1 | cut -d '"' -f2 | sed 's/?.*$//' >> ${TMP}
curl -Ls ${YAY} | rg -i surprise | cut -d '"' -f2 >> ${TMP}
curl -Ls ${BUBBLE} | rg -i 'target="_blank"' | cut -d '"' -f2 >> ${TMP}

sed 's,https://s2f.kytta.dev/,,' ${TMP} | sed '/^$/d' | sort -u > ${OUT}

# Filter out already seen links
NEW_LINKS=$(grep -vxFf "$SEEN" "$OUT")

# If all links are old, fetch again or exit gracefully
if [[ -z "$NEW_LINKS" ]]; then
    echo "No new links found. Try again later!"
    exit 0
fi

# Choose one new link at random
SELECTED=$(echo "$NEW_LINKS" | shuf -n 1)

# Open it
xdg-open "$SELECTED" 

# Mark it as seen
echo "$SELECTED" >> "$SEEN"

# Clean up
rm "$TMP" "$OUT"
