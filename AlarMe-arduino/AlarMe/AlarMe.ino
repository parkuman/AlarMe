#include <SPI.h>
#include <RTCZero.h>
#include <WiFi101.h>

#include "arduino_secrets.h"

#define SPEAKER_PIN 2
#define MOTOR_PIN1 10
#define MOTOR_PIN2 9
#define MOTOR_POWER 11

char ssid[] = SECRET_SSID; // your network SSID (name)
char pass[] = SECRET_PASS; // your network password (use for WPA, or use as key for WEP)

int status = WL_IDLE_STATUS;
WiFiServer server(80);

RTCZero rtc;

const int EST = 20;

void setup()
{

  Serial.begin(9600);           // initialize serial communication
  pinMode(SPEAKER_PIN, OUTPUT); // set the LED pin mode
  pinMode(MOTOR_PIN1, OUTPUT);
  pinMode(MOTOR_PIN2, OUTPUT);
  pinMode(MOTOR_POWER, OUTPUT);

  // attempt to connect to WiFi network:
  while (status != WL_CONNECTED)
  {
    Serial.print("Attempting to connect to Network named: ");
    Serial.println(ssid); // print the network name (SSID);

    // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
    status = WiFi.begin(ssid, pass);
    // wait 10 seconds for connection:
    delay(10000);
  }
  server.begin();    // start the web server on port 80
  printWiFiStatus(); // you're connected now, so print out the status

  rtc.begin();

  unsigned long epoch;
  int numberOfTries = 0, maxTries = 6;
  do
  {
    epoch = WiFi.getTime();
    numberOfTries++;
  } while ((epoch == 0) && (numberOfTries < maxTries));

  if (numberOfTries == maxTries)
  {
    Serial.print("NTP unreachable!!");
    while (1)
      ;
  }
  else
  {
    Serial.print("Epoch received: ");
    Serial.println(epoch);
    rtc.setEpoch(epoch);

    Serial.println();
  }
}

unsigned long currentMillis = 0;

unsigned long beepPreviousMillis = 0;
int beepState = 0;
int beepNum = 0;
int beepTime = 150;

unsigned long vibratePreviousMillis = 0;
int vibrateState = 0;
int vibrateTime = 1000;

bool alarmOn = false;

int alarmTimeHour = 0;
int alarmTimeMinute = 0;
int alarmTimeSecond = 0; // always will be 0, want the alarm to go off on the minute and never again

void loop()
{
  WiFiClient client = server.available(); // listen for incoming clients
  String command = "";                    // string command that takes the input from the server client

  if (client)
  {                                    // if you get a client,
    Serial.println("Phone Connected"); // print a message out the serial port

    while (client.connected())
    { // loop while the client's connected

      while (client.available() > 0)
      {                         // if there's bytes to read from the client,
        char c = client.read(); // read a byte

        Serial.print(c);

        if (c == '\n')
          break;

        command += c;
      }

      if (command == "ON")
        on();
      else if (command == "OFF")
        off();
      else if (command == "ALARM")
      {
        Serial.println("\nTurning alarm on . . .");
        alarmOn = true;
      }
      else if (command == "SNOOZE")
      {
        Serial.println("\nTurning alarm off . . .");
        alarmOn = false;

        clearAlarm();
      }
      else if (command.charAt(0) == '*')
      {
        int colon;
        for (colon = 0; colon < command.length(); colon++)
        {
          if (command.charAt(colon) == ':')
            break;
        }

        alarmTimeHour = command.substring(1, colon).toInt();
        alarmTimeMinute = command.substring(colon + 1).toInt();
        rtc.setAlarmTime(alarmTimeHour, alarmTimeMinute, 0);
        rtc.enableAlarm(rtc.MATCH_HHMMSS);

        rtc.attachInterrupt(enableAlarm);

        Serial.print("\nSetting Alarm to: ");
        Serial.print(alarmTimeHour);
        Serial.print(":");
        Serial.println(alarmTimeMinute);
      }
      else if (command.charAt(0) == '^')
      {
        int colon;
        for (colon = 0; colon < command.length(); colon++)
        {
          if (command.charAt(colon) == ':')
            break;
        }

        int hours = command.substring(1, colon).toInt();
        int minutes = command.substring(colon + 1).toInt();
        rtc.setTime(hours, minutes, 0);

        Serial.print("\nSetting Current Time to: ");
        Serial.print(hours);
        Serial.print(":");
        Serial.println(minutes);
      } 

      if (alarmOn)
      {
        currentMillis = millis();
        Serial.println("Alarm ON - Phone Connected");
        vibrate();
        beep();
      }

      delay(10);
      command = ""; // reset the command string to prepare for the next
    }
    // close the connection:
    client.stop();
    Serial.println("Phone disonnected");
  }

  if (alarmOn)
  {
    currentMillis = millis();
    Serial.println("Alarm ON - No Phone Connected");
    vibrate();
    beep();
  }
}

void on()
{
  digitalWrite(LED_BUILTIN, HIGH);
}

void off()
{
  digitalWrite(LED_BUILTIN, LOW);
}

void beep()
{
  if ((beepState == HIGH) && (currentMillis - beepPreviousMillis >= beepTime))
  {
    beepState = LOW;
    beepPreviousMillis = currentMillis;
    tone(SPEAKER_PIN, 1000);
  }
  else if ((beepState == LOW) && (currentMillis - beepPreviousMillis >= beepTime))
  {
    beepState = HIGH;
    beepPreviousMillis = currentMillis;
    noTone(SPEAKER_PIN);
  }
}

void vibrate()
{
  if ((vibrateState == HIGH) && (currentMillis - vibratePreviousMillis >= vibrateTime))
  {
    vibrateState = LOW;
    vibratePreviousMillis = currentMillis;
    digitalWrite(MOTOR_PIN1, HIGH);
    digitalWrite(MOTOR_PIN2, LOW);
    analogWrite(MOTOR_POWER, 210);
  }
  else if ((vibrateState == LOW) && (currentMillis - vibratePreviousMillis >= vibrateTime))
  {
    vibrateState = HIGH;
    vibratePreviousMillis = currentMillis;
    digitalWrite(MOTOR_PIN1, LOW);
    digitalWrite(MOTOR_PIN2, LOW);
    analogWrite(MOTOR_POWER, 0);
  }
}

void clearAlarm()
{
  digitalWrite(MOTOR_PIN1, LOW);
  digitalWrite(MOTOR_PIN2, LOW);
  analogWrite(MOTOR_POWER, 0);
  noTone(SPEAKER_PIN);
}

void printWiFiStatus()
{
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your WiFi shield's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
  // print where to go in a browser:
  Serial.print("To see this page in action, open a browser to http://");
  Serial.println(ip);
}

void print2digits(int number)
{
  if (number < 10)
  {
    Serial.print("0");
  }
  Serial.print(number);
}

void printTime()
{
  print2digits(rtc.getHours() + EST);
  Serial.print(":");
  print2digits(rtc.getMinutes());
  Serial.print(":");
  print2digits(rtc.getSeconds());
  Serial.println();
}

void enableAlarm()
{
  alarmOn = true;
}