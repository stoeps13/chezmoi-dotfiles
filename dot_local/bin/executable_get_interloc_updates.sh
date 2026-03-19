#!/bin/bash

# Usage: get_interloc_updates.sh "2026-03-19" ~/vimwiki/hcl-cases

DATE="${1:?Usage: $0 <date> <directory>}"
DIR="${2:?Usage: $0 <date> <directory>}"

grep -rl "## ${DATE} Interloc Call" "$DIR" --include="*.md" | sort | while read -r file; do
    in_section=0
    empty_count=0

    # Print first line of file that contains useful info (e.g. title or case no)
    header=$(grep -m1 '^# CS' "$file")
    echo "#${header:-$file}"

    while IFS= read -r line; do
        if echo "$line" | grep -qE "^## ${DATE} Interloc Call"; then
            in_section=1
            empty_count=0
            echo "#$line"
            continue
        fi

        if [[ $in_section -eq 1 ]]; then
            # Stop condition 1: ## Comments
            if echo "$line" | grep -qE '^## Comments'; then
                break
            fi

            # Stop condition 2: any other ## heading
            if echo "$line" | grep -qE '^## '; then
                break
            fi

            # Stop condition 3: horizontal line
            if echo "$line" | grep -qE '^----'; then
                break
            fi

            # Stop condition 4: second empty line
            if [[ -z "$line" ]]; then
                (( empty_count++ ))
                if [[ $empty_count -ge 2 ]]; then
                    break
                fi
                echo "$line"
            else
                empty_count=0
                echo "$line"
            fi
        fi
    done < "$file"
    echo ""
done
