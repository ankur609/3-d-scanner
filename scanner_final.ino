#include <SPI.h>
#include <SD.h>

#define trigPin A2
#define echoPin A3

File scannerValues;
String filename="scn001.txt";
int csPin=10;
int sensePin=A3;

int tStep=2;
int tDir=3;
int tMS1=4;
int tMS2=5;
int tEnable=6;

int zStep=7;
int zDir=8;
int zMS1=9;
int zMS2=18;
int zEnable=19;


void setup() 
{ 
   pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(tStep,OUTPUT);
  pinMode(tDir,OUTPUT);
  pinMode(tMS1,OUTPUT);
  pinMode(tMS2,OUTPUT);
  pinMode(tEnable,OUTPUT);
  pinMode(zStep,OUTPUT);
  pinMode(zDir,OUTPUT);
  pinMode(zMS1,OUTPUT);
  pinMode(zMS2,OUTPUT);
  pinMode(zEnable,OUTPUT);
  
  
  digitalWrite(tMS1,LOW);
  digitalWrite(tMS2,LOW);
  

  digitalWrite(zMS1,LOW);
  digitalWrite(zMS2,LOW);

  digitalWrite(tEnable,LOW);
  digitalWrite(zEnable,LOW);
    
  Serial.begin(9600);

  Serial.print("Initializing SD card... ");
  if (!SD.begin(csPin))
  {
    Serial.println("initialization failed!");
    return;
  }
  Serial.println("initialization success!");
  
}

void loop() 
{

  int vertDistance=4;
  int noZSteps=20; 
  int zCounts=(200/1*vertDistance)/noZSteps; 
  //int thetaCounts=400;
  int thetaCounts=200;

  digitalWrite(zDir,LOW); 
  for (int j=0; j<zCounts; j++) 
  {
    for (int i=0; i<thetaCounts; i++)   
    {
      rotateMotor(tStep, 1); 
      delay(20);
      double senseDistance=0; 
      senseDistance=readAnalogSensor(); 
      writeToSD(senseDistance); 
    }
  
    rotateMotor(zStep, noZSteps); 
    delay(1000);
    writeToSD(9999); 
  }

  digitalWrite(zDir,HIGH);
  delay(10);  
  for (int j=0; j<zCounts; j++)
  {
    rotateMotor(zStep, noZSteps);
    delay(10);
  }

  for (int k=0; k<3600; k++) 
  {
    delay(1000); 
  }

}

void rotateMotor(int pinNo, int steps)
{
  
  for (int i=0; i<steps; i++)
  {
    digitalWrite(pinNo, LOW); 
    delay(1);
    digitalWrite(pinNo, HIGH); 
    delay(1);
    //delayMicroseconds(500); 
    //delay(100);
  }
}

double readAnalogSensor()
{ float duration, distance;
float avgdist=0;
for(int i=1;i<=10;i++)
 { digitalWrite(trigPin, LOW);  
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
//  delayMicroseconds(1000);
  delayMicroseconds(10); 
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance = (duration/2) / 29.1;
  if (distance <= 200 || distance >= 0){
      avgdist=avgdist+distance;
  }
 
  delay(35);
 }
  avgdist=avgdist/10;
    Serial.print(avgdist);
    Serial.println(" cm");
    


  return avgdist;
}

void writeToSD(double senseDistance)
{

  scannerValues = SD.open(filename, FILE_WRITE);
  
  // If the file opened okay, write to it:
  if (scannerValues) 
  {
   
    /* 
     Serial.print("Writing to ");
     Serial.print(filename);
     Serial.println("..."); 
    */


    scannerValues.print(senseDistance);
    scannerValues.println();
    
   
    scannerValues.close();
    
    //Serial.println("done.");
  } 
  else 
  {
   
    Serial.print("error opening ");
    Serial.println(filename);
  }
}

void readFromSD()
{  

  scannerValues = SD.open(filename);
  if (scannerValues)
  {
    Serial.print("Contents of ");
    Serial.print(filename);
    Serial.println(":");

    while (scannerValues.available()) 
    {
      Serial.write(scannerValues.read());
    }
    scannerValues.close();
  } 
  else
  {
 
    Serial.print("error opening ");
    Serial.println(filename);
  }
}

double mapDouble(double x, double in_min, double in_max, double out_min, double out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

