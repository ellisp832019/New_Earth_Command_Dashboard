# Start Here

This module gives your New Earth Dashboard a safe Alexa voice layer.

## Build order

1. Read `docs/01_ARCHITECTURE.md`.
2. Configure permissions in `config/voice_permissions.yaml`.
3. Run the mock dashboard API.
4. Run the voice gateway.
5. Test commands locally with `scripts/test_gateway.sh`.
6. Create an Alexa custom skill in the Alexa Developer Console.
7. Paste in the interaction model from `alexa_skill/interaction_models/en-GB/interactionModel.json`.
8. Deploy the Lambda adapter or host your own HTTPS endpoint.
9. Connect Alexa to the gateway through a secure public endpoint.
10. Keep dangerous commands blocked until the dashboard safety layer is mature.

## Recommended first command set

```text
Alexa, ask New Earth Dashboard for my summary.
Alexa, ask New Earth Dashboard for project status.
Alexa, ask New Earth Dashboard for MicroGrow status.
Alexa, ask New Earth Dashboard to add a note.
Alexa, ask New Earth Dashboard to start focus mode.
Alexa, ask New Earth Dashboard for next tasks.
```

## Hardware needed

Minimum:

- 1 Amazon Echo device or Alexa app
- Your dashboard machine
- A secure HTTPS endpoint for the Alexa skill

Better local lab:

- Echo Dot in office
- Dashboard PC on trusted LAN
- Local hub or mini PC
- Router with reserved IP addresses
- Optional VLAN or separate IoT Wi-Fi
