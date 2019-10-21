#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Illegal number of parameters"
  echo "Please pass exactly one argument that represents the folder name of your project"

  exit 1
fi

PROJECT_DIR=$(basename "$1")
BUILD_DIR="$PROJECT_DIR/build"

mkdir -p "$BUILD_DIR"

ASSETS_ABS_DIR=$(pwd)/assets
ASSETS_REL_DIR_TAG="../assets"

CSS_STYLESHEET="$ASSETS_ABS_DIR/style.css"
HEADER_HTML_FILE="$ASSETS_ABS_DIR/header.html"
FOOTER_HTML_FILE="$ASSETS_ABS_DIR/footer.html"

# Find all Markdown files and build PDFs out of them.
find "$PROJECT_DIR" -name '*.md' | while read file; do
  echo "Processing $file..."

  FILE_BASENAME=$(basename "$file")
  FILE_BASENAME=${FILE_BASENAME%.md}

  PDF_FILE="$BUILD_DIR/${FILE_BASENAME}.pdf"
  HTML_FILE="$BUILD_DIR/$FILE_BASENAME.html"

  pandoc -s --from markdown --to html5 --metadata pagetitle="$PROJECT_DIR" "$file" -o "$HTML_FILE" # Markdown -> HTML
  wkhtmltopdf --encoding 'utf-8' --user-style-sheet "$CSS_STYLESHEET" -T 15mm -B 15mm -R 15mm -L 15mm --header-html "$HEADER_HTML_FILE" --footer-html "$FOOTER_HTML_FILE" --quiet "$HTML_FILE" "$PDF_FILE" # HTML -> PDF
done
