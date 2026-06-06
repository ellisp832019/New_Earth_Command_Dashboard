# Custom Hardware Roadmap

## Future product name

New Earth Command Core V1

## Why build it later

Build the workflow first using Stream Deck. Once the button layout and automations are proven, create a dedicated custom hardware device.

## V0.1 prototype

- ESP32-S3 DevKit
- 8 to 12 buttons
- RGB status strip
- OLED status display
- USB serial connection to PC
- Simple command messages to local bridge

## V0.2 prototype

- Rotary encoders
- Better enclosure
- More buttons
- Touchscreen option
- NFC/project switching

## V0.3 prototype

- Dedicated PCB
- 3D printed enclosure
- Dashboard API integration
- Stream Deck replacement mode

## Firmware concept

The ESP32-S3 sends button events over USB serial:

```json
{"device":"new_earth_command_core","button":"START_MEETING","event":"pressed"}
```

The PC bridge receives the event and triggers the local dashboard action.

## Do not do yet

- Do not build a PCB before the workflow is proven
- Do not add mains voltage
- Do not make it dependent on cloud services
- Do not overcomplicate with AI voice before the button layer works
