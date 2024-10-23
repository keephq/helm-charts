#!/bin/bash

# Usage: ./concat_files_recursive.sh <directory> <output_file>
# Example: ./concat_files_recursive.sh ./my_directory combined_output.txt

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <directory> <output_file>"
  exit 1
fi

# Assign arguments to variables for readability
DIRECTORY=$1
OUTPUT_FILE=$2

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
  echo "Error: Directory $DIRECTORY does not exist."
  exit 1
fi

# Create or clear the output file
> "$OUTPUT_FILE"

# Find and concatenate all files recursively
find "$DIRECTORY" -type f | while read -r file; do
  echo "Adding $file to $OUTPUT_FILE"
  cat "$file" >> "$OUTPUT_FILE"
done

echo "All files have been recursively concatenated into $OUTPUT_FILE."
