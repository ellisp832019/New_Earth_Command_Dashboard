// ESP32-S3 New Earth Command Core V0.1 pseudocode

const int START_MEETING_BUTTON = 4;
const int BUILD_SESSION_BUTTON = 5;

void setup() {
  Serial.begin(115200);
  pinMode(START_MEETING_BUTTON, INPUT_PULLUP);
  pinMode(BUILD_SESSION_BUTTON, INPUT_PULLUP);
}

void loop() {
  if (digitalRead(START_MEETING_BUTTON) == LOW) {
    Serial.println("{\"device\":\"new_earth_command_core\",\"button\":\"START_MEETING\",\"event\":\"pressed\"}");
    delay(500);
  }

  if (digitalRead(BUILD_SESSION_BUTTON) == LOW) {
    Serial.println("{\"device\":\"new_earth_command_core\",\"button\":\"START_BUILD_SESSION\",\"event\":\"pressed\"}");
    delay(500);
  }
}
