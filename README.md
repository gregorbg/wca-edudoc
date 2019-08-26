# wca-edudoc

This is an experimental compiler toolchain to transform pure `Markdown` documents into fancy PDFs
similar to the style of the official [WCA Competitor Tutorial](https://www.worldcubeassociation.org/files/WCA_Competition_Tutorial.pdf).

## Requirements

### Software

- `git` (at https://git-scm.com/)
- `pandoc` (at https://pandoc.org/)
- `wkhtmltopdf` (at https://wkhtmltopdf.org/)
- `lualatex` (at http://www.luatex.org/, also included in prominent LaTeX distributions like [TeXLive](https://www.tug.org/texlive/))

Most (if not all) of these packages should also be available pre-build through the package manager of your distribution
(`apt`, `pacman`, `yay`, `homebrew` et al.)

It is generally recommended to work on a POSIX machine (macOS, Linux) as **none of the content is tested on Windows**.
WSL (aka "Windows subsystem on Linux") may be an alternative for Microsoft lovers.

### Setup

Nothing fancy really, apart from making sure that the software listed above is available on your `$PATH`
so the Bash interpreter can find it in shell scrips affiliated with this repository.

## Usage

For every document, open a new folder. `competitor-tutorial` is a good example to get started.
The folder should only contain the markdown `.md` file of the text that you want to edit.

To compile a complete PDF, invoke `compile.sh` and pass the name of the folder that houses your project `.md` file like so:

```shell script
./compile.sh competitor-tutorial/
```

The output file can then be found at `$project/build/$file.pdf` where `$project` is the folder of your project and `$file`
is the *exact* filename of your original `.md` file.

### Including assets

If you want to include assets (images, external code snippets, etc.) then place them in a separate `assets` subfolder
inside your project directory. Make sure to use **absolute** paths upon referring to images!

### Styling / Layout

We cannot make everything work with pure Markdown. Therefore, every project includes `assets/style.css` by default,
which already includes a basic set of rules to make everything look pretty.

- Headlines need to be centered on the top of the document.
- We use text boxes with coloured background that need HTML classes to be captured for CSS styling
- Image positioning requires some attribute magic, especially regarding text flow.

### Markdown dialect

In order to accommodate for the above, the compiler toolchain parses the [`Pandoc` dialect](https://pandoc.org/MANUAL.html) of markdown.
It enables you to add attributes to almost everything through the use of `{curly braces}`.

Please note, that these attributes can only be attached to elements of the markdown tree, i.e. complete (!) paragraphs
or text flows. They *cannot* be used to change styles within a paragraph itself.

#### Image positioning

When including images, you can add attributes to specify width and height directly. All images will be given a small
margin by default, and you can add text flow if you declare the image as `.logo`.

```markdown
(Image tooltip)[http://example.com/link/to/image]{width=50%}
```

will include the image under the given URL at half its original width. Height will be adjusted accordingly to keep the scale.

```markdown
(Image tooltip)[http://example.com/link/to/image]{.logo}
```

will include the image at original size, and have text flow around it on the right.

#### Text boxes

Text boxes like the red `IMPORTANT` and yellow `WARNING` boxes can be triggered by opening a `div` block as defined in
[`Pandoc` markdown standard](https://pandoc.org/MANUAL.html#divs-and-spans).

```markdown
This is a paragraph that will be normally rendered.

:::{.important}
This section will be contained within a red box!
:::

This text will appear below the red box.
```

## Compiler toolchain intrinsics

The compiler works as follows: (read left to right)

| | source file | pandoc | wkhtmltopdf | lualatex |
| --- | ----------- | ------ | ----------- | ---------|
| format| md | html | pdf | pdf |
| purpose | simple text | apply CSS | convert to universal single-file document format | add header / footer

### Why the heck use LaTeX?

TeX is a very complex layout engine. The only reason that we include it here is because we need recurring headers
(that include a seal and version of the document) and footers (page numbers).

Neither `pandoc` nor `wkhtmltopdf` support this feature (to my knowledge). The TeX template is arguably simple
(see `assets/template.tex`) so compilation should not take that long.

## Contributing

Public contribution is currently not possible. We will of course be open for public contributions once this repository
moves over to the official `thewca` organization.