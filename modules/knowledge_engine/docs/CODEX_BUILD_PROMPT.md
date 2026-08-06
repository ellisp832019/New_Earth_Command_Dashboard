# Codex Build Prompt — Knowledge Engine

Build and integrate the New Earth Dashboard Knowledge Engine module.

The module lives at:

```txt
modules/knowledge_engine
```

The source library is:

```txt
D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING
```

Scan:

```txt
01_BOOKS
02_MAGAZINES
03_RESEARCH_PAPERS
04_WHITEPAPERS
05_COURSES
06_REFERENCE_MATERIAL
07_IMPORT_QUEUE
```

Write catalogue outputs to:

```txt
08_LIBRARY_CATALOGUE
```

Write extracted text and indexes to:

```txt
09_AI_INDEXING
```

Write generated audio to:

```txt
11_AUDIO_LIBRARY
```

Requirements:

1. Keep all original PDFs untouched.
2. Python scanner for recursive PDF discovery.
3. Catalogue JSON and CSV generation.
4. PDF text extraction with PyMuPDF.
5. OCR detection placeholder.
6. FastAPI endpoints for Dashboard integration.
7. Future-ready MP3/TTS manifest structure.
8. Add frontend integration later into the Dashboard as a Knowledge Library page.

First Dashboard UI page should show:

- Search bar
- Category filters
- Table/card list of PDFs
- PDF metadata
- Text extractable / OCR needed badge
- Summary status
- Audio status
- Open original file action
- Future play button
