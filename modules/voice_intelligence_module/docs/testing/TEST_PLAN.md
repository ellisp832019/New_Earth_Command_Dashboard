# Voice Intelligence Module Test Plan

## 1. Voice Notes

- can open voice module page
- can start recording
- can stop recording
- transcription returns text
- transcript can be edited before saving
- saved note includes timestamp and project

## 2. Meeting Transcriber

- can paste transcript
- can generate summary
- decisions are extracted
- actions are extracted
- risks are extracted
- follow-ups are extracted

## 3. MicroGrow Read-Only Status

- mock online node returns readable response
- mock offline node returns safe error
- no relay command is sent
- all status queries are logged

## 4. Safety Gateway

Must pass:

```text
Voice note → allowed
Create task → allowed
Read MicroGrow status → allowed
Turn relay on → blocked
Run mist → blocked
Delete file → blocked
Disable safety gateway → blocked
```

## 5. Privacy

- recording indicator visible
- no background recording in V1
- delete voice session works
- transcript storage path is visible

## 6. Regression

- dashboard still loads without OpenAI API key
- module fails gracefully when API unavailable
- mock mode works offline
