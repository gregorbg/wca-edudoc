#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Illegal number of parameters"
  echo "Please pass exactly one argument that represents the folder name of your project"

  exit 1
fi

PROJECT_DIR=$(basename "$1")
BUILD_DIR="$PROJECT_DIR/build"
LATEX_DIR="$BUILD_DIR/latex"

mkdir -p "$LATEX_DIR"

ASSETS_ABS_DIR=$(pwd)/assets
ASSETS_REL_DIR_TAG="../assets"

CSS_STYLESHEET="$ASSETS_ABS_DIR/style.css"
TEX_TEMPLATE="$ASSETS_ABS_DIR/template.tex"

TEX_MD_PLACEHOLDER="PDF_INTERMEDIATE"
TEX_TITLE_PLACEHOLDER="DOCUMENT_TITLE"

# Find all Markdown files and build PDFs out of them.
find "$PROJECT_DIR/" -name '*.md' | while read file; do
  echo "Processing $file…"

  FILE_BASENAME=$(basename "$file")
  FILE_BASENAME=${FILE_BASENAME%.md}

  TITLE_LINE=$(head -n 1 "$file")
  DOCUMENT_TITLE=$(echo "$TITLE_LINE" | sed -r "s/#+\s*//")

  PDF_INTERMEDIATE_FILE="$BUILD_DIR/${FILE_BASENAME}_markdown.pdf"
  HTML_FILE="$BUILD_DIR/$FILE_BASENAME.html"

  pandoc -s --from markdown --to html5 --metadata pagetitle="$PROJECT_DIR" "$file" -o "$HTML_FILE" # Markdown -> HTML
  wkhtmltopdf --encoding 'utf-8' --user-style-sheet "$CSS_STYLESHEET" -T 15mm -B 15mm -R 15mm -L 15mm --quiet "$HTML_FILE" "$PDF_INTERMEDIATE_FILE" # HTML -> PDF

  TEX_SOURCE="$BUILD_DIR/$FILE_BASENAME.tex"

  sed -r "s#$TEX_MD_PLACEHOLDER#$PDF_INTERMEDIATE_FILE#g" "$TEX_TEMPLATE" > "$TEX_SOURCE"
  sed -ir "s#$ASSETS_REL_DIR_TAG#$ASSETS_ABS_DIR#g" "$TEX_SOURCE"
  sed -ir "s#$TEX_TITLE_PLACEHOLDER#$DOCUMENT_TITLE#g" "$TEX_SOURCE"
  rm -f "${TEX_SOURCE}r"

  lualatex --output-directory="$LATEX_DIR" "$TEX_SOURCE" && mv "$LATEX_DIR/$FILE_BASENAME.pdf" "$BUILD_DIR/$FILE_BASENAME.pdf"
done
