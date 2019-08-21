#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Illegal number of parameters"
  echo "Please pass exactly one argument that represents the folder name of your project"

  exit 1
fi

BUILD_DIR="$1/build"
LATEX_DIR="$BUILD_DIR/latex"
mkdir -p "$LATEX_DIR"

TEX_TEMPLATE="template.tex"
TEX_PLACEHOLDER="PDF_INTERMEDIATE"

# Find all Markdown files and build PDFs out of them.
find "$1" -name '*.md' | while read file; do
  echo "Processing $file…"

  FILE_BASENAME=$(basename "$file")
  FILE_BASENAME=${FILE_BASENAME%.md}

  PDF_INTERMEDIATE_FILE="$BUILD_DIR/${FILE_BASENAME}_markdown.pdf"
  HTML_FILE="$BUILD_DIR/$FILE_BASENAME.html"

  pandoc -s --from markdown --to html5 --metadata pagetitle="$1" "$file" -o "$HTML_FILE" # Markdown -> HTML
  wkhtmltopdf --encoding 'utf-8' -T 15mm -B 15mm -R 15mm -L 15mm --quiet "$HTML_FILE" "$PDF_INTERMEDIATE_FILE" # HTML -> PDF

  TEX_SOURCE="$BUILD_DIR/$FILE_BASENAME.tex"

  sed -r "s#$TEX_PLACEHOLDER#$PDF_INTERMEDIATE_FILE#g" "$TEX_TEMPLATE" > "$TEX_SOURCE"
  lualatex --output-directory="$LATEX_DIR" "$TEX_SOURCE" > /dev/null
  mv "$LATEX_DIR/$FILE_BASENAME.pdf" "$BUILD_DIR/$FILE_BASENAME.pdf"
done
