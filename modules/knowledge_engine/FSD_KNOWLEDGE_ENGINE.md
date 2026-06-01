# FSD — New Earth Knowledge Engine

## 1. Purpose

The Knowledge Engine turns the New Earth Omega OS PDF archive into a searchable, catalogued, audio-ready knowledge system.

It supports Peter's wider New Earth Dashboard vision by allowing books, magazines, whitepapers, courses, manuals, and research papers to be found, indexed, listened to, summarised, and connected to Obsidian notes.

## 2. Principle

Omega OS is the source of truth for files.

The Dashboard is the control engine.

Original PDFs must not be moved, renamed, overwritten, or deleted by this module.

## 3. Source folders

The module scans:

```txt
D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/01_BOOKS
D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/02_MAGAZINES
D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/03_RESEARCH_PAPERS
D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/04_WHITEPAPERS
D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/05_COURSES
D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/06_REFERENCE_MATERIAL
D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/07_IMPORT_QUEUE
```

## 4. Output folders

```txt
08_LIBRARY_CATALOGUE
09_AI_INDEXING
11_AUDIO_LIBRARY
```

## 5. Initial features

### FSD-001 Library Scanner

Scan PDF files recursively and record:

- ID
- filename
- title
- full path
- relative path
- source section
- category
- file size
- created time
- modified time
- page count
- text extractability
- OCR requirement
- tags
- summary status
- audio status
- listened status
- notes path

### FSD-002 Catalogue Builder

Generate:

```txt
08_LIBRARY_CATALOGUE/pdf_catalogue.json
08_LIBRARY_CATALOGUE/pdf_catalogue.csv
08_LIBRARY_CATALOGUE/library_stats.json
```

### FSD-003 Text Extraction

Extract readable text from PDFs into:

```txt
09_AI_INDEXING/extracted_text
```

### FSD-004 Search API

Expose:

```txt
GET /health
GET /library
GET /library/search?q=
GET /library/item/{item_id}
GET /library/stats
```

### FSD-005 MP3 Preparation

Prepare folder paths and manifest structure for future TTS-generated audio.

Initial audio status values:

```txt
not_started
queued
generated
failed
```

## 6. Later features

- OCR worker
- local embeddings
- semantic search
- AI summary engine
- Obsidian markdown note generator
- local Piper TTS engine
- MP3 player dashboard widget
- listening progress sync

## 7. Safety rules

- Never move original PDFs.
- Never delete original PDFs.
- Never overwrite extracted text without safe regeneration logic.
- Keep all generated files in Omega OS generated-output folders.
- Treat file paths as local/private.
