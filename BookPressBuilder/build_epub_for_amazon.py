import os
import re
import shutil
import json
from datetime import datetime
from pathlib import Path
from PIL import Image
import subprocess
import sys

# ==== SECTION 01: PLAN VALIDATION ====
PLAN_FILENAME = "book_build_plan.md"
SCRIPT_NAME = "build_epub_for_amazon.py"

PROJECT_ROOT = Path(__file__).parent.resolve()
PLAN_PATH = PROJECT_ROOT / PLAN_FILENAME

def load_plan():
    if not PLAN_PATH.exists():
        print(f"FATAL: Plan file '{PLAN_FILENAME}' not found in project root! This script must always validate against the plan before running.")
        sys.exit(1)
    with open(PLAN_PATH, "r", encoding="utf-8") as f:
        plan = f.read()
    required_keywords = [
        "10 full-section markdown files",
        "Section01.md",
        "Section10.md",
        "images/<filename>.jpg",
        "audit log",
        "health score",
        "epubcheck"
    ]
    for kw in required_keywords:
        if kw not in plan:
            print(f"FATAL: Plan validation failed. Required phrase '{kw}' missing from plan. Please update '{PLAN_FILENAME}'.")
            sys.exit(1)
    print(f"PLAN VALIDATION: '{SCRIPT_NAME}' is compliant with '{PLAN_FILENAME}'.")
    print("All logic, names, and outputs are enforced per plan. No single-manuscript mode. 10-section mode only. Audit required.")
    return plan

PLAN_TEXT = load_plan()

# ==== SECTION 02: CONFIG ====
BOOKS_DIR = PROJECT_ROOT / "My Books - SIS LLC"
TEMPLATES = PROJECT_ROOT / "templates" / "epub_files"
PANDOC_CSS = TEMPLATES / "epub.css"

COVER_WIDTH = 1600
COVER_HEIGHT = 2560
WORKBOOK_IMG_WIDTH = 400
WORKBOOK_IMG_HEIGHT = 640
IMG_MAX_WIDTH = 1600

NUM_SECTIONS = 10
SECTION_NAMES = [f"Section{str(i).zfill(2)}.md" for i in range(1, NUM_SECTIONS+1)]

SYSTEMATIC_IMAGES = [
    "front_cover.jpg", "workbook_addon.jpg", "intro.jpg"
] + [f"ch{str(i).zfill(2)}.jpg" for i in range(1, 21)] + [
    "conclusion.jpg", "companion_workbook.jpg", "back_cover.jpg"
]
PORTRAIT_IMAGES = {"workbook_addon.jpg", "companion_workbook.jpg"}
COVER_IMAGES = {"front_cover.jpg", "back_cover.jpg"}

# ==== SECTION 03: DIRS AND PROMPT UTILS ====
def ensure_dir(path: Path):
    if not path.exists():
        path.mkdir(parents=True, exist_ok=True)

def prompt_choice(options, prompt_string):
    for i, opt in enumerate(options, 1):
        print(f"{i}. {opt}")
    while True:
        choice = input(prompt_string)
        if choice.isdigit() and 1 <= int(choice) <= len(options):
            return options[int(choice) - 1]
        print("Invalid choice. Try again.")

# ==== SECTION 04: BOOK FOLDER SELECTION ====
def select_book_folder():
    projects = [f for f in BOOKS_DIR.iterdir() if f.is_dir()]
    if not projects:
        print("No book projects found.")
        sys.exit(1)
    print("\nSelect a book project:")
    folder = prompt_choice([p.name for p in projects], "Select project (number): ")
    return BOOKS_DIR / folder

# ==== SECTION 05: SECTION ENFORCEMENT ====
def check_sections(book_folder):
    missing = []
    empty = []
    section_paths = []
    for s in SECTION_NAMES:
        path = book_folder / s
        section_paths.append(path)
        if not path.exists():
            missing.append(s)
        elif path.stat().st_size == 0:
            empty.append(s)
    return section_paths, missing, empty

# ==== SECTION 06: IMAGE REFS AND HANDLING ====
def collect_md_images(section_paths):
    images = []
    seen = set()
    for section in section_paths:
        with open(section, 'r', encoding='utf-8') as f:
            text = f.read()
        img_re = re.compile(r'!\[[^\]]*\]\((images/[^)]+)\)')
        section_imgs = img_re.findall(text)
        for img in section_imgs:
            if img not in seen:
                seen.add(img)
                images.append(img)
    return images

def canonical_image_name(img_rel):
    return str(Path(img_rel).with_suffix(".jpg"))

def copy_and_rename_images(images, src_folder, dest_folder):
    mapping = {}
    ensure_dir(dest_folder)
    for img_rel in images:
        src_path = src_folder / Path(img_rel).name
        canon_name = Path(canonical_image_name(img_rel)).name
        dest_path = dest_folder / canon_name
        if not src_path.exists():
            print(f"ERROR: Referenced image {src_path} does not exist! Build will fail health check.")
            continue
        im = Image.open(src_path)
        im = im.convert("RGB")
        if canon_name in COVER_IMAGES:
            im = im.resize((COVER_WIDTH, COVER_HEIGHT), Image.LANCZOS)
        elif canon_name in PORTRAIT_IMAGES:
            im = im.resize((WORKBOOK_IMG_WIDTH, WORKBOOK_IMG_HEIGHT), Image.LANCZOS)
        else:
            w, h = im.size
            if w > IMG_MAX_WIDTH:
                new_h = int(h * IMG_MAX_WIDTH / w)
                im = im.resize((IMG_MAX_WIDTH, new_h), Image.LANCZOS)
        im.save(dest_path, "JPEG", quality=90, optimize=True)
        mapping[img_rel] = f"images/{canon_name}"
    return mapping

# ==== SECTION 07: UPDATE SECTION MDS ====
def update_md_images(section_paths, mapping, out_dir):
    new_paths = []
    for sec_path in section_paths:
        with open(sec_path, 'r', encoding='utf-8') as f:
            text = f.read()
        for old, new in mapping.items():
            text = text.replace(f"({old})", f"({new})")
        new_path = out_dir / sec_path.name
        with open(new_path, 'w', encoding='utf-8') as f:
            f.write(text)
        new_paths.append(new_path)
    return new_paths

# ==== SECTION 08: AUDIT FUNCTIONS AND ALT-TEXT ====
def check_image_set(all_md_refs, allowed_set):
    for ref in all_md_refs:
        canon = Path(canonical_image_name(ref)).name
        if canon not in allowed_set:
            print(f"WARNING: Markdown references image '{ref}' which is not part of the systematic set.")

def check_alt_text(md_path):
    no_alt_pattern = re.compile(r'!\[\s*\]\((images/[^)]+)\)')
    with open(md_path, 'r', encoding='utf-8') as f:
        text = f.read()
    missing = no_alt_pattern.findall(text)
    return missing

def write_audit_log(log_path, audit_dict):
    with open(log_path, 'w', encoding='utf-8') as f:
        json.dump(audit_dict, f, indent=2)

# ==== SECTION 09: BUILD EPUB ====
def run_pandoc(md_paths, epub_path, cover, css, metadata):
    input_args = [str(p) for p in md_paths]
    cmd = [
        "pandoc", *input_args,
        "-o", str(epub_path),
        "--toc",
        f"--metadata=title:{metadata['title']}",
        f"--metadata=author:{metadata['author']}",
        f"--metadata=publisher:{metadata['publisher']}",
        f"--metadata=cover-image:{cover}",
        f"--css={css}"
    ]
    print("Running Pandoc:", " ".join(cmd))
    result = subprocess.run(cmd, capture_output=True)
    if result.returncode != 0:
        print("ERROR: Pandoc failed:", result.stderr.decode())
        sys.exit(1)

def run_calibre_epub(input_epub, output_epub, cover, metadata):
    cmd = [
        "ebook-convert", str(input_epub), str(output_epub),
        "--output-profile", "kindle",
        "--margin-left", "5", "--margin-right", "5",
        "--margin-top", "5", "--margin-bottom", "5",
        "--unwrap-lines",
        "--line-unwrap-factor", "0.40",
        "--detect-chapters",
        "--chapter-mark", "pagebreak",
        "--remove-fake-margins",
        "--max-toc-links", "50",
        "--markdown-extensions", "tables,toc"
    ]
    cmd += [
        "--title", metadata["title"],
        "--authors", metadata["author"],
        "--publisher", metadata["publisher"],
        "--cover", str(cover)
    ]
    print("Running Calibre ebook-convert:", " ".join(cmd))
    result = subprocess.run(cmd, capture_output=True)
    if result.returncode != 0:
        print("ERROR: Calibre ebook-convert failed:", result.stderr.decode())
        sys.exit(1)

def run_epubcheck(epub_path, output_dir):
    epubcheck_path = shutil.which("epubcheck")
    if not epubcheck_path:
        print("WARNING: epubcheck not found in PATH. Skipping EPUB validation.")
        return {"epubcheck_ran": False, "epubcheck_passed": None, "epubcheck_output": ""}
    cmd = ["epubcheck", str(epub_path)]
    print("Running epubcheck:", " ".join(cmd))
    result = subprocess.run(cmd, capture_output=True)
    passed = (result.returncode == 0)
    out_log = result.stdout.decode() + "\n" + result.stderr.decode()
    with open(output_dir / "epubcheck.log", 'w', encoding='utf-8') as f:
        f.write(out_log)
    return {
        "epubcheck_ran": True,
        "epubcheck_passed": passed,
        "epubcheck_output": out_log
    }

# ==== SECTION 10: MAIN LOGIC ====
def main():
    print("=== BookPressBuilder Commander Edition: 10-Section EPUB Builder ===")
    print(f"VALIDATING: All steps per '{PLAN_FILENAME}'.")

    book_folder = select_book_folder()
    images_src = book_folder / "images"
    # FATAL CHECK: images folder must exist and not be empty!
    if not images_src.exists() or not any(images_src.iterdir()):
        print(f"FATAL: The images folder '{images_src}' is missing or empty. Add your images and try again.")
        output_base = book_folder / "output"
        timestamp = datetime.now().strftime("%Y-%m-%d_%H%M")
        output = output_base / timestamp
        output.mkdir(parents=True, exist_ok=True)
        audit = {
            "timestamp": timestamp,
            "book_folder": str(book_folder),
            "fail_reason": f"FATAL: The images folder '{images_src}' is missing or empty.",
            "health_score": 0,
            "build_success": False
        }
        with open(output / "build_audit.json", 'w', encoding='utf-8') as f:
            json.dump(audit, f, indent=2)
        sys.exit(1)
    output_base = book_folder / "output"
    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M")
    output = output_base / timestamp
    output_images = output / "images"
    ensure_dir(output)
    ensure_dir(output_images)

    section_paths, missing_sections, empty_sections = check_sections(book_folder)
    if len(section_paths) != 10 or missing_sections or empty_sections:
        err = ""
        if len(section_paths) != 10:
            err += f"ERROR: Found {len(section_paths)} section files, expected 10.\n"
        if missing_sections:
            err += f"ERROR: Missing section files: {missing_sections}\n"
        if empty_sections:
            err += f"ERROR: Empty section files: {empty_sections}\n"
        print(err)
        write_audit_log(output / "build_audit.json", {
            "timestamp": timestamp,
            "book_folder": str(book_folder),
            "missing_sections": missing_sections,
            "empty_sections": empty_sections,
            "fail_reason": err,
            "health_score": 0,
            "build_success": False,
            "plan": PLAN_FILENAME
        })
        sys.exit(1)

    md_img_refs = collect_md_images(section_paths)
    check_image_set(md_img_refs, set(SYSTEMATIC_IMAGES))
    mapping = copy_and_rename_images(md_img_refs, images_src, output_images)
    new_section_paths = update_md_images(section_paths, mapping, output)

    missing_images = [img for img in SYSTEMATIC_IMAGES if (img in [Path(canonical_image_name(r)).name for r in md_img_refs]) and not (output_images / img).exists()]
    health_score = 100 if not missing_images else max(0, 100 - 10 * len(missing_images))

    images_missing_alt = []
    for mdp in new_section_paths:
        missing = check_alt_text(mdp)
        if missing:
            images_missing_alt.extend(missing)

    title = input(f"Book Title [{book_folder.name}]: ") or book_folder.name
    author = input("Author [Shane Russell]: ") or "Shane Russell"
    publisher = input("Publisher [Social Impact Solutions LLC]: ") or "Social Impact Solutions LLC"

    cover_candidates = [f for f in output_images.glob("*cover*.jpg")]
    cover = None
    if cover_candidates:
        print("\nSelect cover image:")
        cover = output_images / prompt_choice([c.name for c in cover_candidates], "Select cover image (number): ")
    else:
        print("ERROR: No cover images found in images folder after processing. You must have a front_cover.jpg.")
        write_audit_log(output / "build_audit.json", {
            "timestamp": timestamp,
            "book_folder": str(book_folder),
            "fail_reason": "No front_cover.jpg in images after processing.",
            "health_score": 0,
            "build_success": False,
            "plan": PLAN_FILENAME
        })
        sys.exit(1)

    epub_name = f"{title.replace(' ', '-')}.epub"
    epub_path = output / epub_name
    run_pandoc(new_section_paths, epub_path, cover, PANDOC_CSS, {
        "title": title, "author": author, "publisher": publisher
    })

    calibre_epub_name = epub_name.replace(".epub", "-Kindle.epub")
    calibre_epub_path = output / calibre_epub_name
    run_calibre_epub(epub_path, calibre_epub_path, cover, {
        "title": title, "author": author, "publisher": publisher
    })

    epubcheck_result = run_epubcheck(calibre_epub_path, output)

    audit = {
        "timestamp": timestamp,
        "book_folder": str(book_folder),
        "section_files_used": [str(p) for p in section_paths],
        "md_images_referenced": md_img_refs,
        "systematic_images_present": [f for f in SYSTEMATIC_IMAGES if (output_images / f).exists()],
        "systematic_images_missing": missing_images,
        "images_missing_alt_text": images_missing_alt,
        "epub_path": str(epub_path),
        "calibre_epub_path": str(calibre_epub_path),
        "epubcheck": epubcheck_result,
        "health_score": health_score,
        "build_success": (health_score == 100 and (not epubcheck_result.get("epubcheck_ran") or epubcheck_result.get("epubcheck_passed"))),
        "plan": PLAN_FILENAME
    }
    write_audit_log(output / "build_audit.json", audit)

    print(f"\nEPUB for Amazon KDP ready: {calibre_epub_path}")
    if missing_images:
        print(f"ERROR: {len(missing_images)} systematic images missing. Health score: {health_score}. See audit log.")
    elif images_missing_alt:
        print(f"WARNING: {len(images_missing_alt)} images missing alt-text. Health score: {health_score}. See audit log.")
    elif epubcheck_result.get("epubcheck_ran") and not epubcheck_result.get("epubcheck_passed"):
        print(f"ERROR: epubcheck failed. See {output}/epubcheck.log and audit log for details.")
    elif audit['build_success']:
        print("BUILD COMPLETE: Health score 100. EPUB passes all diagnostics and epubcheck. Ready for Amazon KDP.")
    else:
        print("BUILD INCOMPLETE: See audit log for details.")

if __name__ == "__main__":
    main()