from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel

# Allow running with: uvicorn api.main:app --reload --port 8787
import sys
MODULE_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_ROOT = MODULE_ROOT / "scripts"
if str(SCRIPTS_ROOT) not in sys.path:
    sys.path.append(str(SCRIPTS_ROOT))

from common import load_config, output_paths  # noqa: E402

app = FastAPI(
    title="New Earth Knowledge Engine",
    description="Search and catalogue API for the New Earth Omega OS knowledge library.",
    version="0.1.0",
)


def load_items() -> list[dict[str, Any]]:
    config = load_config()
    paths = output_paths(config)
    catalogue_path = paths["catalogue"] / "pdf_catalogue.json"
    if not catalogue_path.exists():
        return []
    items = json.loads(catalogue_path.read_text(encoding="utf-8"))
    items.sort(key=lambda item: (item.get("source_section", ""), item.get("relative_path", ""), item.get("title", "")))
    return items


def load_extraction_state() -> dict[str, Any]:
    config = load_config()
    paths = output_paths(config)
    state_path = paths["extracted_text"] / "extraction_state.json"
    report_path = paths["extracted_text"] / "extraction_failures.json"

    if state_path.exists():
        try:
            state = json.loads(state_path.read_text(encoding="utf-8"))
        except Exception:
            state = {}
    else:
        state = {}

    if report_path.exists():
        try:
            report = json.loads(report_path.read_text(encoding="utf-8"))
        except Exception:
            report = {}
    else:
        report = {}

    return {
        "state_path": str(state_path),
        "report_path": str(report_path),
        "completed_ids": state.get("completed_ids", []),
        "failed_ids": state.get("failed_ids", []),
        "failed_items": report.get("items", []),
        "last_run_at": state.get("last_run_at"),
    }


@app.get("/")
def root() -> dict[str, str]:
    return {
        "status": "ok",
        "module": "knowledge_engine",
        "message": "New Earth Knowledge Engine is running.",
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "module": "knowledge_engine"}


@app.get("/library")
def library(limit: int = Query(100, ge=1, le=1000), offset: int = Query(0, ge=0)) -> dict[str, Any]:
    items = load_items()
    return {
        "total": len(items),
        "limit": limit,
        "offset": offset,
        "items": items[offset: offset + limit],
    }


@app.get("/library/search")
def search_library(q: str = Query(..., min_length=1), limit: int = Query(50, ge=1, le=500)) -> dict[str, Any]:
    items = load_items()
    needle = q.lower().strip()
    matches = []

    for item in items:
        haystack = " ".join([
            str(item.get("title", "")),
            str(item.get("filename", "")),
            str(item.get("relative_path", "")),
            str(item.get("source_section", "")),
            str(item.get("category", "")),
            " ".join(item.get("tags", [])),
        ]).lower()

        # Optional content search from extracted text, capped for speed.
        extracted_text_path = item.get("extracted_text_path")
        if extracted_text_path and Path(extracted_text_path).exists():
            try:
                haystack += " " + Path(extracted_text_path).read_text(encoding="utf-8", errors="ignore")[:50000].lower()
            except Exception:
                pass

        if needle in haystack:
            matches.append(item)
            if len(matches) >= limit:
                break

    return {"query": q, "total_matches": len(matches), "items": matches}


@app.get("/library/item/{item_id}")
def library_item(item_id: str) -> dict[str, Any]:
    items = load_items()
    for item in items:
        if item.get("id") == item_id:
            return item
    raise HTTPException(status_code=404, detail="Library item not found")


@app.get("/library/stats")
def library_stats() -> dict[str, Any]:
    config = load_config()
    paths = output_paths(config)
    stats_path = paths["catalogue"] / "library_stats.json"
    if stats_path.exists():
        return json.loads(stats_path.read_text(encoding="utf-8"))
    items = load_items()
    return {"total_pdfs": len(items), "message": "Run build_catalogue.py for full stats."}


@app.get("/library/extraction/status")
def library_extraction_status() -> dict[str, Any]:
    items = load_items()
    extraction = load_extraction_state()
    completed_ids = set(str(item_id) for item_id in extraction["completed_ids"])
    failed_ids = set(str(item_id) for item_id in extraction["failed_ids"])

    text_extractable = sum(1 for item in items if item.get("text_extractable"))
    ocr_required = sum(1 for item in items if item.get("ocr_required"))
    extracted = len(completed_ids)
    failed = len(failed_ids)
    pending = max(text_extractable - extracted - failed, 0)

    return {
        "total_pdfs": len(items),
        "text_extractable": text_extractable,
        "ocr_required": ocr_required,
        "extracted": extracted,
        "failed": failed,
        "pending": pending,
        "last_run_at": extraction["last_run_at"],
        "state_path": extraction["state_path"],
        "report_path": extraction["report_path"],
        "failed_items": extraction["failed_items"],
    }
