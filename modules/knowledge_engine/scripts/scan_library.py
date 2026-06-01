from __future__ import annotations

import json
from pathlib import Path
import fitz  # PyMuPDF

from common import (
    ensure_dir,
    iso_from_timestamp,
    load_config,
    make_item_id,
    output_paths,
    safe_slug,
    sanitize_text,
    silence_mupdf_diagnostics,
)


def inspect_pdf(path: Path) -> tuple[int | None, bool, bool]:
    try:
        sample_text = ""
        with fitz.open(path) as doc:
            page_count = doc.page_count
            for page_index in range(min(page_count, 3)):
                sample_text += doc[page_index].get_text("text") or ""
        text_extractable = len(sample_text.strip()) > 80
        ocr_required = not text_extractable
        return page_count, text_extractable, ocr_required
    except Exception:
        return None, False, True


def category_from_relative(relative_path: Path) -> tuple[str, str]:
    parts = relative_path.parts
    source_section = parts[0] if len(parts) > 0 else "UNKNOWN"
    category = parts[1] if len(parts) > 2 else source_section
    return source_section, category


def scan_library() -> list[dict]:
    silence_mupdf_diagnostics()
    config = load_config()
    paths = output_paths(config)
    root = paths["root"]
    items: list[dict] = []

    for scan_folder in config["scan_folders"]:
        base = root / scan_folder
        if not base.exists():
            print(f"SKIP missing folder: {base}")
            continue

        for pdf_path in sorted(base.rglob("*")):
            if not pdf_path.is_file() or pdf_path.suffix.lower() != ".pdf":
                continue

            stat = pdf_path.stat()
            relative = pdf_path.relative_to(root)
            source_section, category = category_from_relative(relative)
            page_count, text_extractable, ocr_required = inspect_pdf(pdf_path)
            item_id = make_item_id(str(pdf_path))
            title = sanitize_text(
                pdf_path.stem.replace("_", " ").replace("-", " ").strip()
            )
            slug = safe_slug(f"{category}_{pdf_path.stem}")

            items.append({
                "id": item_id,
                "filename": sanitize_text(pdf_path.name),
                "title": title,
                "full_path": sanitize_text(str(pdf_path)),
                "relative_path": sanitize_text(str(relative).replace("\\", "/")),
                "source_section": sanitize_text(source_section),
                "category": sanitize_text(category),
                "file_size_bytes": stat.st_size,
                "created_at": iso_from_timestamp(stat.st_ctime),
                "modified_at": iso_from_timestamp(stat.st_mtime),
                "page_count": page_count,
                "text_extractable": text_extractable,
                "ocr_required": ocr_required,
                "tags": [sanitize_text(category)] if category else [],
                "summary_status": "not_started",
                "audio_status": "not_started",
                "listened_status": "not_started",
                "notes_path": None,
                "extracted_text_path": sanitize_text(
                    str(
                        paths["extracted_text"]
                        / source_section
                        / category
                        / f"{slug}.txt"
                    )
                ),
                "audio_manifest_path": sanitize_text(
                    str(
                        paths["audio"]
                        / source_section
                        / category
                        / slug
                        / "audio_manifest.json"
                    )
                ),
            })

    ensure_dir(paths["catalogue"])
    output = paths["catalogue"] / "pdf_catalogue.json"
    items.sort(key=lambda item: (item["source_section"], item["relative_path"], item["title"]))

    with output.open("w", encoding="utf-8") as f:
        json.dump(items, f, indent=2, ensure_ascii=False)

    print(f"Scanned {len(items)} PDFs")
    print(f"Wrote {output}")
    return items


if __name__ == "__main__":
    scan_library()
