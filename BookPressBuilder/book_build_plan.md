# BookPressBuilder Plan: Commander Edition (EPUB Only, 10-Section, Full-Section Mode)

---

## 1. Project Structure & Canonical Truth

- **Project Root:**  
  `E:\LocalClone\LocalClone\GitHub\Vera-FIXED\BookPressBuilder`
- **Book Folders:**  
  `/My Books - SIS LLC/` (Each subfolder = one book project)
- **Templates Directory:**  
  `/templates` (at project root; single source of style and structure)
- **Canonical Outline File:**  
  `master_book_outline.py` and `master_book_outline.md` (define required sections, imported by all scripts)
- **Output Directory:**  
  `/output/{book-slug}/` (Auto-created per build)
- **Audit Logs:**  
  `/output/{book-slug}/audit/` (Detailed logs & diagnostics per build)
- **Source Markdown:**  
  Every book project folder contains **exactly 10 full-section markdown files** (not split by sub-sections, no manuscript file, no subfolders):
  ```
  Section01.md
  Section02.md
  Section03.md
  Section04.md
  Section05.md
  Section06.md
  Section07.md
  Section08.md
  Section09.md
  Section10.md
  ```
  - **No manuscript.md**
  - **No subfolders for content**

---

## 2. Modes of Operation

### “Full-Section Mode” (Enforced, No Single Manuscript)

**Flow:**
1. User selects the book folder.
2. Script checks for **exactly 10** markdown files named as `Section01.md` through `Section10.md` in the root of the selected folder.
3. Loads the canonical outline (`master_book_outline.py` or `.md`) to enforce order and completeness.
4. Loads each section in order, concatenates for full build.
5. All images must be referenced as `images/<filename>.jpg`, and must be present in the `/images` subfolder in the book folder.
6. Templates and CSS always loaded from `/templates`.
7. Outputs: `.epub` (primary), plus audit log and (optional) epubcheck validation.
8. Full audit log and diagnostics—errors detailed, health score reported.

**Mandates:**
- **No single-manuscript mode.**
- **No partial builds.**
- **All 10 sections must be present, correctly named, and non-empty.**
- **All referenced images must exist and be correctly named/formatted.**
- **Audit log and error reporting are never skipped.**
- **No manual path-finding or hardcoding.**

---

## 3. Workflow

- **No manual path-finding:**  
  All scripts use absolute/project-root paths (never CWD).
- **Book selection:**  
  Always via interactive CLI prompt.
- **Section selection:**  
  No prompt; all 10 sections are loaded by script in order.
- **Audit logs:**  
  Always written, always detailed, always readable.
- **Error handling:**  
  No silent fails—all issues are surfaced and logged.

---

## 4. Automation & Diagnostics

- **Outline enforcement:**  
  Script checks for presence, order, and non-emptiness of all 10 section files.
- **Image auditing:**  
  - All referenced images must exist in `/images/`
  - All images must be `.jpg`
  - Audit log tracks missing or unused images
- **Health score:**  
  - 100 only if every check passes.
  - Build fails and logs all errors if any section/image is missing or incorrectly named.
- **epubcheck:**  
  - Runs automatically if available, result logged.
- **Alt-text auditing:**  
  - Warns if any images are missing alt-text.

---

## 5. Scripts Used

- `build_epub_full_sections.py` — For 10-section, outline-enforced builds.
- (Optional) `outline_generator.py` — To create empty section files for new books.
- (Optional) `template_checker.py` — To check template drift/versioning.

---

## 6. Commander’s Next Steps

1. Place exactly 10 full-section `.md` files in the root of each book folder.  
   - Name them `Section01.md` through `Section10.md`.
2. Place all images needed in the `/images/` subfolder, named as referenced in the markdown.
3. Run the build script.
4. Review the audit log after every build—errors will be obvious, fixes will be fast.
5. Only release when health score is 100 and audit log is clean.

---

## 7. **Nothing is skipped or left ambiguous.**
- No single-manuscript mode.
- No partial/extra/unnamed sections.
- No subfolders for content.
- No silent errors.
- Always interactive book selection.
- Always audit log.
- Always health score.
- Always epubcheck if available.