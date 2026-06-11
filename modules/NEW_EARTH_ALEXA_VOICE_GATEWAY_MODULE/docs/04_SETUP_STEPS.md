# Setup Steps

## 1. Copy module into dashboard

Recommended path:

```text
New_Earth_Dashboard/modules/NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE/
```

## 2. Install Python requirements

```bash
cd modules/NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows PowerShell
python -m ensurepip --upgrade
pip install -r requirements.txt
```

The current dependency pins are validated against Python `3.14` on Windows.

## 2a. Set shared secret

Before running local tests or the dashboard launch helper, set:

```text
NEW_EARTH_VOICE_GATEWAY_SECRET=change-this-long-random-secret
```

## 3. Run mock dashboard

```bash
python examples/dashboard_mock/mock_dashboard_api.py
```

Default mock dashboard URL:

```text
http://127.0.0.1:8099
```

## 4. Run voice gateway

```bash
python -m src.voice_gateway.app
```

Default gateway URL:

```text
http://127.0.0.1:8088
```

## 5. Test locally

```bash
bash scripts/test_gateway.sh
```

If `NEW_EARTH_VOICE_GATEWAY_SECRET` is set in your shell, the script now includes the secure `x-gateway-secret` header automatically.

If you are using the dashboard launch helper, it also gives you copy buttons for:

- Windows startup commands
- env lines
- the gateway test command
- the trusted launcher command
- local health checks

## 6. Windows trusted launcher

Run this from the module folder to start the mock dashboard and the voice gateway from outside the Flutter UI:

```text
scripts\launch_voice_gateway.cmd
```

If you prefer `.bat`, use:

```text
scripts\launch_voice_gateway.bat
```

To stop the local services again:

```text
scripts\stop_voice_gateway.cmd
```

Or:

```text
scripts\stop_voice_gateway.bat
```

## 7. Create Alexa custom skill

In the Alexa Developer Console:

1. Create new skill.
2. Choose Custom model.
3. Choose hosted Lambda or your own endpoint.
4. Set locale to English UK.
5. Import interaction model from:

```text
alexa_skill/interaction_models/en-GB/interactionModel.json
```

6. Point the skill backend to the Lambda adapter or HTTPS endpoint.
7. Test with the Alexa simulator.

## 8. Connect to real dashboard APIs

Edit:

```text
config/gateway_config.example.yaml
```

Then copy it to:

```text
config/gateway_config.local.yaml
```

Never commit local secrets.

For a fast disable, set:

```text
ALEXA_GATEWAY_ENABLED=false
```
