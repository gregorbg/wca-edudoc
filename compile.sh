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

HEADER_TITLE_PLACEHOLDER="DOCUMENT_TITLE"
HEADER_VERSION_PLACEHOLDER="DATE"
DATE=$(date '+%Y-%m-%d')

# Find all Markdown files and build PDFs out of them.
find "$PROJECT_DIR" -name '*.md' | while read file; do
  echo "Processing $file..."

  FILE_BASENAME=$(basename "$file")
  FILE_BASENAME=${FILE_BASENAME%.md}

  TITLE_LINE=$(head -n 1 "$file")
  DOCUMENT_TITLE=$(echo "$TITLE_LINE" | sed -E "s/#+\s*//")

  PDF_FILE="$BUILD_DIR/${FILE_BASENAME}.pdf"
  HTML_FILE="$BUILD_DIR/$FILE_BASENAME.html"

  CURRENT_HEADER="$ASSETS_ABS_DIR/tmp_header.html"
  cp $HEADER_HTML_FILE $CURRENT_HEADER
  sed -iE "s#$HEADER_TITLE_PLACEHOLDER#$DOCUMENT_TITLE#g" "$CURRENT_HEADER"
  sed -iE "s#$HEADER_VERSION_PLACEHOLDER#$DATE#g" "$CURRENT_HEADER"

  pandoc -s --from markdown --to html5 --metadata pagetitle="$PROJECT_DIR" "$file" -o "$HTML_FILE" # Markdown -> HTML
  wkhtmltopdf --encoding 'utf-8' --user-style-sheet "$CSS_STYLESHEET" -T 15mm -B 15mm -R 15mm -L 15mm --header-html "$CURRENT_HEADER" --footer-center "[page]" --quiet "$HTML_FILE" "$PDF_FILE" # HTML -> PDF
  rm $CURRENT_HEADER
done
