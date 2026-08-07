# Voice Failure States

This page explains the voice startup states that are considered failures or warnings.

## `permissionDenied`

Meaning:

- the app could not confirm microphone access

Typical recovery:

- open system privacy settings
- grant microphone access
- retry voice startup

## `hardwareMissing`

Meaning:

- no usable microphone or headset was detected

Typical recovery:

- connect a microphone or headset
- check the OS audio input settings
- retry voice startup

## `pluginUnavailable`

Meaning:

- the speech or platform plugin was not available on the current build

Typical recovery:

- rebuild the app
- verify plugin registration
- retry after the build issue is fixed

## `failed`

Meaning:

- startup timed out or hit an unexpected runtime error

Typical recovery:

- retry after the surrounding system settles
- re-open voice if the app was just launched
- inspect logs if the problem repeats

## `unavailable`

Meaning:

- the current platform does not support the voice startup path

Typical recovery:

- none needed for dashboard use
- use a supported desktop platform if voice is required

## General Rule

All of these states are non-blocking.
They should explain the situation clearly without stopping the dashboard from loading.
