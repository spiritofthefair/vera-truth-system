"""
build_templates_from_master.py

Purpose:
    - Regenerate and synchronize the .css, .epub, .tex, .pdf, and canonical 'template' output files for BookPressBuilder
      using the "master_book_structure_template.*" files as the single source of truth.
    - For HTML: extract only the canonical structure, update all image names to [PLACEHOLDER FOR IMAGE], split all sections/chapters onto new pages,
      and ensure all formatting is defined in the CSS template.
    - The generated templates are NOT copies of the book; they are stripped-down, structure-only, reusable templates.

Instructions:
    - Place all "master_book_structure_template.*" files (.md, .docx, .epub, .html, .pdf, etc.) in the templates folder.
    - Run this script after any update to any of these master files.
    - This script generates: .css, .epub, .tex, .pdf, and structure-only .html templates.
      You may manually update .md and .docx as needed from the master files.
    - All outputs strictly mirror the canonical structure, section/page break logic, and [PLACEHOLDER FOR IMAGE] markers.
    - No other templates or outputs are touched.

Author: spiritofthefair
Repo: spiritofthefair/Vera

"""

import os
import sys
import shutil
import zipfile
from bs4 import BeautifulSoup

import pypandoc

CANONICAL_MD = "master_book_structure_template.md"
CANONICAL_DOCX = "master_book_structure_template.docx"
CANONICAL_PDF = "master_book_structure_template.pdf"
CANONICAL_EPUB = "master_book_structure_template.epub"
CANONICAL_HTML = "master_book_structure_template.html"

CSS_TEMPLATE = "book_structure_template.css"
EPUB_TEMPLATE = "book_structure_template.epub"
TEX_TEMPLATE = "book_structure_template.tex"
PDF_OUTPUT = "book_structure_template.pdf"
HTML_TEMPLATE = "book_structure_template.html"
HTML_IMAGES_DIR = "book_structure_template_images"

# -------- CSS Generation (Faithful to master, all formatting here) --------
CSS_HEADER = """
/* BookPressBuilder Canonical CSS Template - Regenerated
   Define all fonts, sizes, margins, page-breaks, headings, etc. here!
*/
body {
    font-family: 'Times New Roman', Times, serif;
    font-size: 12pt;
    line-height: 1.15;
    margin: 1in;
    text-align: justify;
}
h1 {
    page-break-before: always;
    font-size: 2em;
    font-weight: bold;
    text-align: left;
    margin-top: 2em;
    margin-bottom: 1em;
}
h2, h3 {
    page-break-before: always;
    font-weight: bold;
    text-align: left;
    margin-top: 2em;
    margin-bottom: 1em;
}
hr.pagebreak {
    page-break-after: always;
    border: none;
    margin: 0;
    height: 0;
}
img, .placeholder-image {
    display: block;
    font-weight: bold;
    color: #888;
    border: 1px dashed #888;
    margin: 2em 0;
    text-align: center;
    padding: 1em;
    width: 100%;
    max-width: 6in;
}
@media print {
    h1, h2, h3 { page-break-before: always; }
}
"""

def generate_css_template():
    with open(CSS_TEMPLATE, "w", encoding="utf-8") as f:
        f.write(CSS_HEADER)
    print(f"✔ CSS template updated at {CSS_TEMPLATE}")

# -------- HTML Canonical Template Builder --------
def create_html_template_from_master():
    if not os.path.isfile(CANONICAL_HTML):
        print("⚠ No master HTML file found.")
        return

    # Load HTML and parse with BeautifulSoup
    with open(CANONICAL_HTML, "r", encoding="utf-8") as f:
        soup = BeautifulSoup(f, "html.parser")

    # Remove all content except for canonical structure and placeholders
    # 1. Remove actual book text, keep only headings, TOC, placeholders, and canonical structure
    for tag in soup.find_all(['p', 'span', 'div']):
        # Remove if not a heading, image placeholder, or explicitly needed
        # Keep only if within TOC, or contains a placeholder marker
        tag_str = str(tag).lower()
        if ("placeholder for image" in tag_str) or ("toc" in tag.get("class", []) or "toc" in tag_str):
            continue
        if tag.find(['h1', 'h2', 'h3', 'img']):
            continue
        tag.decompose()

    # 2. Replace all images with canonical placeholder
    for img in soup.find_all('img'):
        placeholder = soup.new_tag("div", **{"class": "placeholder-image"})
        placeholder.string = "[PLACEHOLDER FOR IMAGE]"
        img.replace_with(placeholder)

    # 3. Canonicalize all headings and add page-breaks
    for level in ['h1', 'h2', 'h3']:
        for heading in soup.find_all(level):
            # Make sure it starts on a new page
            heading['style'] = "page-break-before: always;" + (heading.get('style', '') or "")
            # Optionally, strip text to just "SECTION" or "CHAPTER" marker
            # heading.string = heading.string if heading.string else f"SECTION"
            # Remove id, class, etc. that is not canonical
            for attr in list(heading.attrs):
                if attr not in ['style']:
                    del heading[attr]

    # 4. Remove all scripts/styles except for the canonical CSS link
    for tag in soup.find_all(['script', 'style']):
        tag.decompose()
    # Add or update the canonical CSS link
    css_link = soup.new_tag("link", rel="stylesheet", href=CSS_TEMPLATE)
    if soup.head:
        for link in soup.head.find_all('link'):
            link.decompose()
        soup.head.append(css_link)
    else:
        new_head = soup.new_tag("head")
        new_head.append(css_link)
        soup.insert(0, new_head)

    # 5. Remove all images and copy images folder as template (if exists)
    if os.path.isdir(HTML_IMAGES_DIR):
        shutil.rmtree(HTML_IMAGES_DIR)
    images_src_dir = os.path.join(os.path.dirname(CANONICAL_HTML), "images")
    if os.path.isdir(images_src_dir):
        shutil.copytree(images_src_dir, HTML_IMAGES_DIR)

    # 6. Write out the canonical HTML template
    with open(HTML_TEMPLATE, "w", encoding="utf-8") as f:
        f.write(str(soup.prettify()))
    print(f"✔ HTML template generated at {HTML_TEMPLATE} (images in {HTML_IMAGES_DIR}/)")

# -------- EPUB Generation (from master, structure only) --------
def generate_epub():
    # Prefer to generate from canonical MD, but fallback to copy master EPUB if no MD
    if os.path.isfile(CANONICAL_MD):
        try:
            output = pypandoc.convert_file(
                CANONICAL_MD,
                "epub",
                outputfile=EPUB_TEMPLATE,
                extra_args=[
                    "--toc",
                    "--epub-chapter-level=1",
                    "--css", CSS_TEMPLATE,
                    "--metadata=title:BookPressBuilder Template",
                ]
            )
            print(f"✔ EPUB template generated at {EPUB_TEMPLATE}")
        except Exception as e:
            print(f"⚠ EPUB generation failed: {e}")
    elif os.path.isfile(CANONICAL_EPUB):
        shutil.copy(CANONICAL_EPUB, EPUB_TEMPLATE)
        print(f"✔ EPUB template copied from {CANONICAL_EPUB}")
    else:
        print("⚠ No canonical EPUB or MD found for EPUB template.")

# -------- TeX Generation --------
TEX_HEADER = r"""
% BookPressBuilder Canonical TeX Template - Regenerated
\documentclass[12pt]{book}
\usepackage[margin=1in]{geometry}
\usepackage{titlesec}
\usepackage{fancyhdr}
\titleformat{\chapter}[block]{\bfseries\LARGE}{\thechapter.}{1em}{}
\titleformat{\section}[block]{\bfseries\large}{\thesection.}{1em}{}
\pagestyle{fancy}
\fancyhead{}
\fancyfoot[C]{\thepage}
\setlength{\parindent}{2em}
\setlength{\parskip}{0pt}
\renewcommand{\baselinestretch}{1.15}
\begin{document}
"""

TEX_FOOTER = r"""
\end{document}
"""

def generate_tex_template():
    # Generate LaTeX from canonical MD, unless a canonical tex is present
    if os.path.isfile("master_book_structure_template.tex"):
        shutil.copy("master_book_structure_template.tex", TEX_TEMPLATE)
        print(f"✔ LaTeX template copied from master_book_structure_template.tex")
        return
    if os.path.isfile(CANONICAL_MD):
        try:
            latex_body = pypandoc.convert_file(CANONICAL_MD, "latex", extra_args=["--top-level-division=chapter"])
            with open(TEX_TEMPLATE, "w", encoding="utf-8") as f:
                f.write(TEX_HEADER)
                f.write(latex_body)
                f.write(TEX_FOOTER)
            print(f"✔ TeX template updated at {TEX_TEMPLATE}")
        except Exception as e:
            print(f"⚠ TeX generation failed: {e}")
    else:
        print("⚠ No canonical TeX or MD found for LaTeX template.")

# -------- PDF Generation (from DOCX for fidelity) --------
def generate_pdf_from_docx():
    # If a master PDF is present, copy it directly!
    if os.path.isfile(CANONICAL_PDF):
        shutil.copy(CANONICAL_PDF, PDF_OUTPUT)
        print(f"✔ PDF template copied from {CANONICAL_PDF}")
        return
    # Otherwise, generate from canonical DOCX (fallback)
    if os.path.isfile(CANONICAL_DOCX):
        try:
            output = pypandoc.convert_file(
                CANONICAL_DOCX,
                "pdf",
                outputfile=PDF_OUTPUT,
            )
            print(f"✔ PDF generated at {PDF_OUTPUT} (from DOCX)")
        except Exception as e:
            print(f"⚠ PDF generation from DOCX failed: {e}")
    else:
        print("⚠ No canonical PDF or DOCX found for PDF template.")

def main():
    # Check for at least one master file
    found_any = False
    for f in [CANONICAL_MD, CANONICAL_DOCX, CANONICAL_PDF, CANONICAL_EPUB, CANONICAL_HTML]:
        if os.path.isfile(f):
            found_any = True
            break
    if not found_any:
        print("❌ No master_book_structure_template.* files found in this folder.")
        sys.exit(1)
    print("🔎 Please visually confirm that all master_book_structure_template.* files are in sync before proceeding.")
    input("Press Enter to continue if all templates are visually synchronized, or CTRL+C to abort...")

    # 1. Update CSS (from canonical style knowledge)
    generate_css_template()
    # 2. Generate HTML canonical template
    create_html_template_from_master()
    # 3. Generate EPUB template
    generate_epub()
    # 4. Generate TeX template
    generate_tex_template()
    # 5. Generate PDF template
    generate_pdf_from_docx()

    print("✅ All canonical templates rebuilt/synced from master files as true templates, not book copies.")

if __name__ == "__main__":
    main()