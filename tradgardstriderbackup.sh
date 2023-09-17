#!/bin/bash
set -euo pipefail
mkdir -p rips
curl -O https://www.svtplay.se/tradgardstider && grep -o '/video/[0-9A-Za-z]*/tradgardstider' tradgardstider|sort |uniq> tradgardstider_url.out


while IFS= read -r line; do
  # Process each line here
  URL="https://www.svtplay.se$line"

    EPISODE=$(curl -s $URL)
    echo 
    echo ">> Working on $URL"
    echo ">> Extracting metadata: year"
    YEAR=$(echo $EPISODE| grep -oE 'Produktionsår</dt><dd[^>]*>[0-9]+</dd>' | grep -oE '[0-9]+' | awk '$0 >= 2016 && $0 <= 2023')
    echo ">> Extracting metadata: title"
    TITLE=$(echo $EPISODE|grep -oE '<p[^>]*>[^<]* • [0-9]+ min</p>'| sed 's/<[^>]*>//g; s/ • .*//') 
    echo ">> Extracting metadata: part"
    PART=$(echo $EPISODE|grep -oE 'Del [0-9] av [0-9]\.( Vårsäsongen\.| Höstsäsongen\.)?'| tr -d '.'| head -1)
    

    # Check if a line contains "syntolkat" and skip it.
    if [[ "$TITLE" == *"syntolkat"* ]]; then
    echo "Skipping 'syntolkat'....."
    else
    echo "----------------------"
    echo "URL: $URL"
    echo "PART: $PART"
    echo "TITLE: $TITLE"
    echo "YEAR: $YEAR"
    FILENAME="Trädgårdstider-$YEAR-$PART-$TITLE"
    echo ">> Filename generated: $FILENAME"

    yt-dlp $URL --restrict-filenames -P rips -o "$FILENAME"
    echo "----------------------"

    fi

done < "tradgardstider_url.out"
