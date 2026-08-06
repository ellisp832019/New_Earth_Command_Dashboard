# ESP32-S3 Command Core Spec

## V0.1 goal

Create a small USB-connected physical button box that sends command events to the PC.

## Parts

- ESP32-S3 DevKit
- 8 buttons
- 2 rotary encoders
- WS2812 RGB LED strip or ring
- OLED display
- USB-C cable
- 3D printed enclosure

## Firmware behaviour

- Read button presses
- Debounce inputs
- Send JSON event over USB serial
- Receive status updates from PC bridge
- Set LEDs according to mode/status

## Example serial event

```json
{"button":"START_MEETING","event":"pressed"}
```

## PC bridge behaviour

- Listen to serial port
- Validate device ID
- Match command ID
- Trigger dashboard/local action
- Write action log

## Safety

Custom hardware should never directly control dangerous equipment. It should only request actions from the dashboard bridge.
