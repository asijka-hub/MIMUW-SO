#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename="$1"

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "File not found: $filename"
    exit 1
fi

# Read the file line by line and check line length and character range
line_count=0
valid_line_count=0

while IFS= read -r line; do
    line_count=$((line_count + 1))
    
    # Count characters in the line (excluding end of line representation)
    char_count=$(echo -n "$line" | wc -m)
    
    # Check if the line length is within the acceptable range and characters are within ASCII range
    if [ "$char_count" -le 72 ] && [[ "$line" =~ ^[[:print:]]*$ ]]; then
        valid_line_count=$((valid_line_count + 1))
    fi
done < "$filename"

# Check if the file meets the criteria
if [ "$line_count" -eq 7 ] && [ "$valid_line_count" -eq 7 ]; then
    echo "File $filename meets the criteria."
else
    echo "File $filename does not meet the criteria."
fi

if dd count=1 if=file of=/dev/c0d0; then
	echo "bootloader installed"
else
	echo "instalation failed"
fi

if dd count=1 seek=1 if=P of=/dev/c0d0; then
	echo "P file installed"
else
	echo "P file instalation failed"
fi

