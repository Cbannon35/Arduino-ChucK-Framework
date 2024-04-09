#include <Arduino.h>
//https://randomnerdtutorials.com/complete-guide-for-ultrasonic-sensor-hc-sr04/

long duration, cm;
int trigPin = 11;    // Trigger
int echoPin = 12;    // Echo

void setup() {
  Serial.begin(9600);
  pinMode(A0, INPUT_PULLUP);
  pinMode(A1, INPUT_PULLUP);
  pinMode(A2, INPUT_PULLUP);
  pinMode(A3, INPUT_PULLUP);
  pinMode(A4, INPUT_PULLUP);
  pinMode(A5, INPUT_PULLUP);
  pinMode(trigPin, OUTPUT); 
  pinMode(echoPin, INPUT_PULLUP); 
}

void loop() {
  // The sensor is triggered by a HIGH pulse of 10 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  digitalWrite(trigPin, LOW);
  delayMicroseconds(5);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
 
  pinMode(echoPin, INPUT);
  duration = pulseIn(echoPin, HIGH);
 
  // Convert the time into a distance
  cm = (duration/2) / 29.1;     // Divide by 29.1 or multiply by 0.0343
  // inches = (duration/2) / 74;   // Divide by 74 or multiply by 0.0135
  
  // Assume no hand detected
  if (cm > 50 || cm < 3) {
    cm = 18; // 3 --> doesn't change note's octave
  } else if (cm > 30) {
    // upper bound cm
    cm = 30;
  }
  // put it on scale of 0 to 5
  cm = cm / 6; 
  
  Serial.print(cm);
  Serial.print(" ");

  Serial.print(analogRead(A0));
  Serial.print(" ");
  Serial.print(analogRead(A1));
  Serial.print(" ");
  Serial.print(analogRead(A2));
  Serial.print(" ");
  Serial.print(analogRead(A3));
  Serial.print(" ");
  Serial.print(analogRead(A4));
  Serial.print(" ");
  Serial.print(analogRead(A5));
  Serial.println();
  delay(250);
}
