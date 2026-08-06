# Manual Test Checklist

## Setup

Recommended Windows setup:

```powershell
cd modules/knowledge_engine
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

Optional:

```powershell
copy config.example.json config.json
```

## Folder Setup

Run:

```powershell
python scripts/setup_omega_folders.py
```

Expected:

- `08_LIBRARY_CATALOGUE` exists
- `09_AI_INDEXING` exists
- `09_AI_INDEXING/extracted_text` exists
- `09_AI_INDEXING/chunks` exists
- `09_AI_INDEXING/search_index` exists
- `11_AUDIO_LIBRARY` exists

## Scanner

Run:

```powershell
python scripts/scan_library.py
```

Expected:

- `pdf_catalogue.json` created
- PDFs are not moved
- PDFs are scanned recursively
- uppercase and lowercase `.pdf` files are both included

## Text Extraction

Run:

```powershell
python scripts/extract_text.py --batch-size 100
```

Expected:

- extracted text files appear in `09_AI_INDEXING/extracted_text`
- repeated runs continue from the last completed batch
- `09_AI_INDEXING/extracted_text/extraction_state.json` tracks progress
- `09_AI_INDEXING/extracted_text/extraction_failures.json` lists damaged or failed PDFs
- scanned PDFs are skipped and flagged as OCR required

## Catalogue Builder

Run:

```powershell
python scripts/build_catalogue.py
```

Expected:

- `pdf_catalogue.json` is normalised and re-saved
- `pdf_catalogue.csv` is created
- `library_stats.json` is created

## API

Run:

```powershell
uvicorn api.main:app --reload --port 8787
```

Or run `start_knowledge_engine.ps1` from the module root to prepare the
folders and start the API in one step.

Open:

```txt
http://127.0.0.1:8787/health
http://127.0.0.1:8787/library
http://127.0.0.1:8787/library/search?q=MicroGrow
http://127.0.0.1:8787/library/item/<id>
http://127.0.0.1:8787/library/stats
http://127.0.0.1:8787/library/extraction/status
```
