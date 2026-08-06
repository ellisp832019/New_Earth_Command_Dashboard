# Hardware Requirements

## Phase 1: Buy and use now

### Required

| Item | Purpose | Priority |
|---|---|---|
| Elgato Stream Deck XL or similar 32-key deck | Main physical command surface | High |
| Main Windows PC | Runs Stream Deck software, Dashboard, OBS, VS Code | High |
| Existing monitors | Dashboard, code, meetings | High |
| USB microphone | Meetings, voice notes, content | Medium |
| Webcam | Meetings, demos, Kickstarter content | Medium |
| OBS Studio | Screen recording and content capture | High |

### Recommended

| Item | Purpose |
|---|---|
| Logitech Brio or similar webcam | Better video quality |
| USB mic such as Blue Yeti / Wave:3 | Cleaner meeting and recording audio |
| LED desk lights | Better content recording |
| Bluetooth/USB label printer | QR codes and asset labels |
| External SSD | Local recording archive |
| USB hub | Clean desk wiring |

## Phase 2: Maker hardware for custom deck

| Item | Purpose |
|---|---|
| ESP32-S3 DevKit | Custom button/control firmware |
| Mechanical push buttons | Physical mode buttons |
| Rotary encoders | Volume, navigation, mode control |
| WS2812 RGB LEDs | Status lights |
| OLED or small TFT displays | Status and labels |
| 7 inch touchscreen | Future dedicated command screen |
| NFC reader | Optional login/project switching |
| QR scanner | Asset and project scanning |
| 3D printed enclosure | Custom New Earth hardware casing |

## Phase 3: New Earth Command Core

A future product/prototype combining:

- Mini PC or local hub
- ESP32-S3 controller
- Touchscreen
- Physical buttons
- Status LEDs
- Microphone
- Speaker
- QR scanner
- Label printer integration
- Local dashboard API bridge

## Hardware rule

Do not start with custom electronics. Start with Stream Deck + Dashboard + scripts. Build the custom ESP32 hardware once the workflow is proven.
