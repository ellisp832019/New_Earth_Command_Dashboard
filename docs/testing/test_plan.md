# Voice Module Test Plan

## Voice Notes

- open the voice module page
- start and stop recording
- return a readable mock transcript
- edit the transcript before save
- save a note with a timestamp and destination

## Meeting Transcriber

- paste a transcript
- generate a mock summary
- surface decisions, actions, risks, and follow-ups

## MicroGrow Read-Only Status

- return a readable status snapshot in mock mode
- handle offline or missing-node states safely
- block any relay or hardware write attempt

## Safety Gateway

- allow voice note capture
- allow task drafting
- allow read-only MicroGrow status
- block relay, mist, heater, pump, and destructive commands

## Privacy and Regression

- recording state is visible
- background recording stays off in V1
- dashboard still runs without an OpenAI API key
- mock mode works offline
