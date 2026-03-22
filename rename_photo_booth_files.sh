#!/bin/bash

# Script to rename Photo Booth files to timestamp_consecutive_number format
# Usage: ./rename_photo_booth_files.sh <directory_path>

if [ -z "$1" ]; then
    echo "Usage: $0 <directory_path>"
    echo "Example: $0 '/Users/wrj/Documents/Mushroom_Specimens/2026_Mushroom_Specimens/WRJ_0103_Tiny_Maple_Tree_01_03_2026/1_4_2026_tomlov'"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

cd "$TARGET_DIR" || exit 1

# Create temporary file list sorted by modification time
temp_file=$(mktemp)
find . -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.JPG" -o -name "*.jpeg" -o -name "*.JPEG" -o -name "*.png" -o -name "*.PNG" \) -print0 | \
    xargs -0 stat -f "%m %N" | sort -n | cut -d' ' -f2- > "$temp_file"

# Counter for consecutive numbering
counter=1

# Read each file and rename
while IFS= read -r file; do
    # Skip if file doesn't exist (already renamed)
    [ ! -f "$file" ] && continue

    # Get file extension
    extension="${file##*.}"

    # Get file's modification timestamp in MM_DD_YYYY format
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        timestamp=$(stat -f "%Sm" -t "%m_%d_%Y" "$file")
    else
        # Linux
        timestamp=$(date -r "$file" +"%m_%d_%Y")
    fi

    # Create new filename with zero-padded counter
    new_name=$(printf "%s_%04d.%s" "$timestamp" "$counter" "$extension")

    # Rename file
    if [ "$file" != "$new_name" ]; then
        echo "Renaming: $file -> $new_name"
        mv "$file" "$new_name"
    fi

    ((counter++))
done < "$temp_file"

# Cleanup
rm "$temp_file"

echo ""
echo "Renaming complete! Processed $((counter - 1)) files."
