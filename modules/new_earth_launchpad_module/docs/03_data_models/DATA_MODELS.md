# Data Models

## Campaign

```json
{
  "id": "MICROGROW_KICKSTARTER_2026",
  "name": "MicroGrow Kickstarter 2026",
  "project": "MicroGrow",
  "type": "kickstarter",
  "status": "Prototype",
  "funding_goal_gbp": 35000,
  "launch_date": null,
  "owner": "Peter Ellis",
  "summary": "Local-first grow automation ecosystem using ESP32 nodes, sensors, relays, hub, and Flutter app.",
  "created_at": "2026-06-04"
}
```

## Reward Tier

```json
{
  "id": "DEV_KIT_149",
  "campaign_id": "MICROGROW_KICKSTARTER_2026",
  "name": "MicroGrow Developer Kit",
  "price_gbp": 149,
  "quantity_limit": 100,
  "estimated_cogs_gbp": 65,
  "estimated_shipping_gbp": 8,
  "margin_gbp": 76,
  "status": "Draft"
}
```

## Story Block

```json
{
  "id": "origin_story",
  "campaign_id": "MICROGROW_KICKSTARTER_2026",
  "title": "Origin Story",
  "section": "Founder Story",
  "body": "MicroGrow began as a vision to rebuild life, food resilience, and conscious technology.",
  "status": "Draft"
}
```

## Readiness Item

```json
{
  "id": "firmware_live_data",
  "campaign_id": "MICROGROW_KICKSTARTER_2026",
  "category": "Firmware",
  "title": "Live sensor data endpoint working",
  "status": "Done",
  "proof_link": "",
  "notes": "ESP32 node exposes live data over local network."
}
```

## Risk

```json
{
  "id": "certification_delay",
  "campaign_id": "MICROGROW_KICKSTARTER_2026",
  "title": "Certification preparation may take longer than expected",
  "severity": "Medium",
  "likelihood": "Medium",
  "mitigation": "Keep V1 low-voltage and avoid mains switching inside the product. Use external certified power supplies."
}
```
