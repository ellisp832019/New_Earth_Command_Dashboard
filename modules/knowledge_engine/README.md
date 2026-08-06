# New Earth Dashboard - Knowledge Engine

The Knowledge Engine is the Dashboard module for scanning, cataloguing, extracting, searching, and eventually converting the New Earth Omega OS PDF library into MP3 audio.

## Source Of Truth

Omega OS stores the library:

```txt
D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING
```

The Dashboard stores the code:

```txt
modules/knowledge_engine
```

Original PDFs must stay in Omega OS. The Dashboard only reads them and writes generated outputs into Omega OS generated folders.

## Quick Start

Windows commands:

```powershell
cd modules/knowledge_engine
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python scripts/setup_omega_folders.py
python scripts/scan_library.py
python scripts/extract_text.py --batch-size 100
python scripts/build_catalogue.py
uvicorn api.main:app --reload --port 8787
```

You can also launch the module from the Dashboard by running
`start_knowledge_engine.ps1`, which prepares the folder structure and starts
the API in one visible PowerShell window.

Optional but recommended:

```powershell
copy config.example.json config.json
```

If `config.json` is not present, the scripts fall back to `config.example.json`.

## Current Behaviour

- Scans PDFs recursively from the configured Omega OS source folders.
- Generates `08_LIBRARY_CATALOGUE/pdf_catalogue.json`.
- Generates `08_LIBRARY_CATALOGUE/pdf_catalogue.csv`.
- Generates `08_LIBRARY_CATALOGUE/library_stats.json`.
- Extracts readable PDF text into `09_AI_INDEXING/extracted_text`.
- Runs text extraction in resumable batches and saves progress in
  `09_AI_INDEXING/extracted_text/extraction_state.json`.
- Writes a failure report to `09_AI_INDEXING/extracted_text/extraction_failures.json`.
- Flags likely scanned PDFs that need OCR.
- Exposes a local FastAPI service for the Dashboard.
- Prepares safe placeholders for summaries and audio output.

## Output Folders

```txt
22_KNOWLEDGE_AND_LEARNING/
  08_LIBRARY_CATALOGUE/
    pdf_catalogue.json
    pdf_catalogue.csv
    library_stats.json
  09_AI_INDEXING/
    extracted_text/
    chunks/
    search_index/
  11_AUDIO_LIBRARY/
```

## Dashboard Integration Plan

The Flutter Dashboard should connect to the module in this order:

1. Show a Knowledge Library page that loads `GET /library`.
2. Add search using `GET /library/search?q=...`.
3. Open an item detail drawer or page with `GET /library/item/{id}`.
4. Surface module health and counts with `GET /health` and `GET /library/stats`.
5. Surface extraction progress with `GET /library/extraction/status`.
6. Add actions for opening the original PDF path from the item payload.
7. Keep MP3 and semantic search as future stubs until the local pipeline is ready.

## What Comes Later

- Local OCR with Tesseract.
- Semantic search with embeddings.
- AI summary generation.
- Local TTS with Piper or cloud TTS.
- MP3 playback from the Dashboard.
- Obsidian note sync.
