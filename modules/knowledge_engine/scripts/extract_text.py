from __future__ import annotations

import json
from pathlib import Path
import fitz

from common import ensure_dir, load_config, output_paths, silence_mupdf_diagnostics


def extract_text_for_item(item: dict) -> bool:
    if item.get("ocr_required"):
        return False

    pdf_path = Path(item["full_path"])
    text_path = Path(item["extracted_text_path"])
    ensure_dir(text_path.parent)

    try:
        chunks = []
        with fitz.open(pdf_path) as doc:
            for page_index in range(doc.page_count):
                text = doc[page_index].get_text("text") or ""
                chunks.append(f"\n\n--- PAGE {page_index + 1} ---\n\n{text}")
        text_path.write_text("".join(chunks), encoding="utf-8", errors="ignore")
        return True
    except Exception as exc:
        print(f"FAILED extraction: {pdf_path} :: {exc}")
        return False


def main() -> None:
    silence_mupdf_diagnostics()
    config = load_config()
    paths = output_paths(config)
    catalogue_path = paths["catalogue"] / "pdf_catalogue.json"

    if not catalogue_path.exists():
        raise FileNotFoundError(f"Run scan_library.py first. Missing: {catalogue_path}")

    ensure_dir(paths["indexing"])
    ensure_dir(paths["extracted_text"])

    items = json.loads(catalogue_path.read_text(encoding="utf-8"))
    extracted = 0
    skipped = 0

    for item in items:
        if extract_text_for_item(item):
            extracted += 1
        else:
            skipped += 1

    print(f"Extracted text for {extracted} PDFs")
    print(f"Skipped/OCR required: {skipped}")


if __name__ == "__main__":
    main()
