# Alexa Lambda Env Setup

Use this when updating the Alexa Lambda function environment variables so the skill can talk to the local New Earth voice gateway safely.

## Local sync helper

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\sync_alexa_lambda_env.ps1
```

This reads the private local gateway secret from `.env.local` or `.env` and writes a private helper file at:

```text
alexa_skill/lambda_node/.lambda-env.local.json
```

That file is ignored by git and is only for local reference.

## Lambda environment variables

Copy these two values into the Alexa Lambda configuration:

- `NEW_EARTH_GATEWAY_URL`
- `NEW_EARTH_VOICE_GATEWAY_SECRET`

The helper script prints both values after syncing.

## Where to set them

In AWS Lambda for the Alexa skill function:

1. Open the Lambda function used by the skill.
2. Open `Configuration`.
3. Open `Environment variables`.
4. Update `NEW_EARTH_GATEWAY_URL`.
5. Update `NEW_EARTH_VOICE_GATEWAY_SECRET`.
6. Deploy the updated configuration.

## Current local gateway target

For this local-first setup, the expected URL is:

```text
http://127.0.0.1:8088/voice/command
```

If you later expose the gateway through a secure tunnel or reverse proxy, update both the gateway URL and the Lambda environment variable together.

## Safety note

Do not commit live gateway secrets into tracked files. Keep secrets in:

- `.env.local`
- `.lambda-env.local.json`
- AWS Lambda environment variables
