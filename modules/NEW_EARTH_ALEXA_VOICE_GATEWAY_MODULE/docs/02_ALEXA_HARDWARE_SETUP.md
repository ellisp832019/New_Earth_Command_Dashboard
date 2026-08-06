# Alexa Hardware Setup Guide

## Recommended hardware

### Starter

- Echo Dot or Echo Pop
- Alexa mobile app
- New Earth Dashboard machine

Good for basic voice testing in the office.

### Better office setup

- Echo Dot in the office
- Dashboard PC or mini PC on Ethernet
- Router with DHCP reservation for the dashboard machine
- Optional separate IoT Wi-Fi network

### Future secure setup

- Echo device on guest/IoT Wi-Fi
- New Earth Gateway mini PC on trusted LAN
- Firewall rules restricting inbound access
- Voice Gateway only exposes one narrow HTTPS route
- Hardware kill switch for AI/voice gateway machine

## Physical placement

Place Alexa where it can hear you clearly but not where private conversations are always happening.

Suggested locations:

```text
Office desk: good for build commands
Workshop bench: useful for hands-free notes
Grow room: only for read-only MicroGrow status at first
Bedroom/living area: avoid private dashboard commands
```

## Network recommendation

Best starting setup:

```text
Alexa Echo → normal home Wi-Fi
Dashboard PC → Ethernet or strong Wi-Fi
Gateway service → dashboard machine or local hub
```

Better secure setup:

```text
Alexa Echo → IoT Wi-Fi / guest network
Dashboard + Gateway → trusted LAN
Router firewall → only allow expected outbound/inbound paths
```

## Do not expose directly

Do not expose these directly to Alexa:

- Finance folders
- Obsidian vault folders
- MicroGrow relay endpoints
- Local database files
- Shell access
- AI agent runtime
- File system paths

## Hardware checklist

- [ ] Alexa device added to Amazon account
- [ ] Alexa app installed on phone
- [ ] Amazon Developer account created
- [ ] Dashboard machine has a fixed local IP
- [ ] Gateway service runs locally
- [ ] HTTPS endpoint or secure tunnel available for testing
- [ ] Voice commands start read-only
- [ ] Audit log is enabled
- [ ] Physical fallback/manual control still exists

