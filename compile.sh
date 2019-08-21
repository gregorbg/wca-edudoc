#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Illegal number of parameters"
  echo "Please pass exactly one argument that represents the folder name of your project"

  exit 1
fi

BUILD_DIR="$1/build"
mkdir -p "$BUILD_DIR"

# Find all Markdown files and build PDFs out of them.
find "$1" -name '*.md' | while read file; do
  echo "Processing $file…"

  FILE_BASENAME=$(basename "$file")
  FILE_BASENAME=${FILE_BASENAME%.md}

  PDF_FILE="$BUILD_DIR/$FILE_BASENAME.pdf"
  HTML_FILE="$BUILD_DIR/$FILE_BASENAME.html"

  pandoc -s --from markdown --to html5 --metadata pagetitle="$1" "$file" -o "$HTML_FILE" # Markdown -> HTML
  wkhtmltopdf --encoding 'utf-8' --user-style-sheet "$1/style.css" -T 15mm -B 15mm -R 15mm -L 15mm --quiet "$HTML_FILE" "$PDF_FILE" # HTML -> PDF
done
