# AlarMe ⏰
An alarm clock you can't say no to! App-controlled alarm clock only disabled by an NFC terminal somewhere in your home. Made for MLH Hack At Home

## How does it work?
7:59am, you're fast asleep. 💤

8:00am, AlarMe goes off. Panic sets in. 😮
Beeping fills your ears and your heart starts pounding. You reach for the snooze button and realize it isn't there. You grab your phone and head to the NFC tag you placed in the kitchen downstairs. You tap it and BOOM. Alarm turns off. Now you're awake, might as well make some coffee.

## Why?
This project was inspired by my inability to get up in the morning, since I could easily snooze my alarm. Now, I have to get up and out of bed!

## Tech Used:
- Flutter Framework (Dart)
  - [get_it](https://pub.dev/packages/get_it) to help with the coding process
  - [analog_clock](https://pub.dev/packages/analog_clock) for the nice visual clock 
  - [nfc_in_flutter](https://pub.dev/packages/nfc_in_flutter) to allow for NFC capabilities
  - [shared_preferences](https://pub.dev/packages/shared_preferences) to help store the last set alarm for the user to check
  
- Arduino MKR 1000, small, Wifi enabled, and a Real Time Clock included! (UPDATE: this actually got fried and no longer works 😢)
  - speaker from an old printer
  - unbalanced DC motor for vibration
  
  
  
### Other Resources
Tim MacDonald's [Medium Article](https://medium.com/@TimMcDon4ld/using-flutter-and-arduino-to-control-appliances-b8fcd61b220) on how to connect Flutter and an Arduino over TCP

  