#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <Servo.h>
#include "SinricPro.h"
#include "SinricProSwitch.h"

#define WIFI_SSID "Your_WIFI_NAME"
#define WIFI_PASS "Your_WIFI_Password"

#define APP_KEY    ""
#define APP_SECRET ""
#define SWITCH_ID  ""

Servo servo;
#define SERVO_PIN D4  // your servo connected pin

int ON_ANGLE = 60;   // adjust this angle to actually press ON
int OFF_ANGLE = 120; // adjust this angle to press OFF

// Function to handle switch commands
bool onPowerState(const String &deviceId, bool &state) {
  if (deviceId == SWITCH_ID) {
    if (state) {
      Serial.println("Turning ON Bedroom Light...");
      servo.write(ON_ANGLE);
    } else {
      Serial.println("Turning OFF Bedroom Light...");
      servo.write(OFF_ANGLE);
    }
  }
  return true;
}

// Function to connect/reconnect WiFi
void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;

  Serial.print("Connecting to WiFi...");
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  int retryCount = 0;

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    retryCount++;

    // If too long, reset WiFi attempt
    if (retryCount > 30) {  
      Serial.println("\nStill not connected. Restarting WiFi...");
      WiFi.disconnect();
      WiFi.begin(WIFI_SSID, WIFI_PASS);
      retryCount = 0;
    }
  }

  Serial.println("\nWiFi Connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void setup() {
  Serial.begin(115200);
  servo.attach(SERVO_PIN);
  servo.write(OFF_ANGLE); // default off position

  WiFi.mode(WIFI_STA);
  connectWiFi(); // initial connection

  SinricProSwitch &mySwitch = SinricPro[SWITCH_ID];
  mySwitch.onPowerState(onPowerState);

  SinricPro.begin(APP_KEY, APP_SECRET);
  SinricPro.restoreDeviceStates(true);
}

void loop() {
  // Keep SinricPro running
  SinricPro.handle();

  // Keep checking WiFi
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi lost! Reconnecting...");
    connectWiFi();
  }
}
