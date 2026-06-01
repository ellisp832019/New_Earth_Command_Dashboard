from __future__ import annotations

import argparse
import json
from datetime import datetime
from pathlib import Path
import fitz

from common import ensure_dir, load_config, output_paths, silence_mupdf_diagnostics


STATE_FILENAME = "extraction_state.json"


def extract_text_for_item(item: dict) -> tuple[str, str | None]:
    if item.get("ocr_required"):
        return "ocr_required", None

    pdf_path = Path(item["full_path"])
    text_path = Path(item["extracted_text_path"])
    ensure_dir(text_path.parent)

    if text_path.exists() and text_path.stat().st_size > 0:
        return "already_exists", None

    try:
        chunks = []
        with fitz.open(pdf_path) as doc:
            for page_index, page in enumerate(doc, start=1):
                text = page.get_text("text") or ""
                chunks.append(f"\n\n--- PAGE {page_index} ---\n\n{text}")
        text_path.write_text("".join(chunks), encoding="utf-8", errors="ignore")
        return "extracted", None
    except Exception as exc:
        return "failed", str(exc)


def load_state(state_path: Path) -> dict:
    if not state_path.exists():
        return {
            "completed_ids": [],
            "failed_ids": [],
            "last_run_at": None,
        }

    try:
        decoded = json.loads(state_path.read_text(encoding="utf-8"))
    except Exception:
        return {
            "completed_ids": [],
            "failed_ids": [],
            "last_run_at": None,
        }

    if not isinstance(decoded, dict):
        return {
            "completed_ids": [],
            "failed_ids": [],
            "last_run_at": None,
        }

    return {
        "completed_ids": list(decoded.get("completed_ids", [])),
        "failed_ids": list(decoded.get("failed_ids", [])),
        "last_run_at": decoded.get("last_run_at"),
    }


def save_state(state_path: Path, state: dict) -> None:
    state_path.write_text(
        json.dumps(state, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract readable text from the Knowledge Engine catalogue.",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=100,
        help=(
            "Maximum number of pending PDFs to extract in this run. "
            "Use 0 to process all pending items."
        ),
    )
    parser.add_argument(
        "--retry-failures",
        action="store_true",
        help="Retry items that previously failed extraction.",
    )
    return parser.parse_args()


def main() -> None:
    silence_mupdf_diagnostics()
    args = parse_args()
    config = load_config()
    paths = output_paths(config)
    catalogue_path = paths["catalogue"] / "pdf_catalogue.json"
    state_path = paths["extracted_text"] / STATE_FILENAME

    if not catalogue_path.exists():
        raise FileNotFoundError(f"Run scan_library.py first. Missing: {catalogue_path}")

    ensure_dir(paths["indexing"])
    ensure_dir(paths["extracted_text"])

    items = json.loads(catalogue_path.read_text(encoding="utf-8"))
    state = load_state(state_path)
    completed_ids = set(state["completed_ids"])
    failed_ids = set(state["failed_ids"])

    pending = []
    already_done = 0
    skipped_ocr = 0
    skipped_failed = 0

    for item in items:
        item_id = str(item.get("id", ""))
        if item.get("ocr_required"):
            skipped_ocr += 1
            continue

        if item_id in completed_ids:
            already_done += 1
            continue

        text_path = Path(str(item.get("extracted_text_path", "")))
        if text_path.exists() and text_path.stat().st_size > 0:
            completed_ids.add(item_id)
            already_done += 1
            continue

        if item_id in failed_ids and not args.retry_failures:
            skipped_failed += 1
            continue

        pending.append(item)

    batch_size = args.batch_size
    if batch_size > 0:
        pending = pending[:batch_size]

    print(f"Pending text-extractable PDFs: {len(pending)}")
    print(f"Already extracted: {already_done}")
    print(f"OCR required: {skipped_ocr}")
    if skipped_failed and not args.retry_failures:
        print(f"Previously failed and skipped: {skipped_failed}")

    extracted = 0
    failed = 0

    for index, item in enumerate(pending, start=1):
        title = item.get("title") or item.get("filename") or item.get("id") or "PDF"
        status, error = extract_text_for_item(item)
        item_id = str(item.get("id", ""))

        if status == "extracted":
            extracted += 1
            completed_ids.add(item_id)
            failed_ids.discard(item_id)
            print(f"[{index}/{len(pending)}] EXTRACTED: {title}")
        elif status == "already_exists":
            completed_ids.add(item_id)
            failed_ids.discard(item_id)
            print(f"[{index}/{len(pending)}] EXISTS: {title}")
        elif status == "ocr_required":
            print(f"[{index}/{len(pending)}] OCR REQUIRED: {title}")
        else:
            failed += 1
            failed_ids.add(item_id)
            print(f"[{index}/{len(pending)}] FAILED: {title} :: {error}")

        state["completed_ids"] = sorted(completed_ids)
        state["failed_ids"] = sorted(failed_ids)
        state["last_run_at"] = datetime.now().isoformat(timespec="seconds")
        save_state(state_path, state)

    print(f"Extracted text for {extracted} PDFs in this batch")
    print(f"Failed in this batch: {failed}")
    print(f"Resume state: {state_path}")


if __name__ == "__main__":
    main()
