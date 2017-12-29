#define instr1 8
#define instr2 9
#define instr3 10
#define mute1 11
#define mute2 12
#define mute3 13

#define joyclick 2
#define jX A0
#define jY A1

#define left 3
#define right 6
#define mute 5
#define stuff 4

int status = 0;

int pitchbend;

boolean m1=false;
boolean m2=false;
boolean m3=false;

boolean play = false;

boolean LRactive = false;
long LRmillis=0;

boolean muteactive = false;
long mutemillis=0;

boolean stuffactive = false;
long stuffmillis=0;

void setup() {

  Serial.begin(9600);
  // put your setup code here, to run once:
  pinMode(instr1, OUTPUT);
  pinMode(instr2, OUTPUT);
  pinMode(instr3, OUTPUT);
  pinMode(mute1, OUTPUT);
  pinMode(mute2, OUTPUT);
  pinMode(mute3, OUTPUT);

  pinMode(joyclick, INPUT_PULLUP);
  pinMode(left, INPUT_PULLUP);
  pinMode(right, INPUT_PULLUP);
  pinMode(mute, INPUT_PULLUP);
  pinMode(stuff, INPUT_PULLUP);
  pinMode(jX, INPUT_PULLUP);
}

void loop() {
  //Falls das Board über 50 Tage läuft kek
  if(LRmillis - millis() > 500) LRmillis=0;
  if(mutemillis - millis() > 500) mutemillis=0;
  if(stuffmillis - millis() > 500) stuffmillis = 0;

  pitchbend = analogRead(jX);
  

  if (!digitalRead(stuff)){
    play = true;
    } else {
    play = false;
  }

  if(play == true){
    String serialout;
    if(m1) serialout+= "1";
    else serialout+="0";
    if(m2) serialout+= "1";
    else serialout+="0";
    if(m3) serialout+= "1";
    else serialout+="0";

    serialout += " ";
    serialout += status;
    serialout += " ";
    
    serialout += pitchbend;
    Serial.println(serialout);
   }

  
  
    
  //Status per LED ausgeben
  switch (status){
    case 0:
      digitalWrite(instr1, HIGH);
      digitalWrite(instr2, LOW);
      digitalWrite(instr3, LOW);
      break;
    case 1:
      digitalWrite(instr1, LOW);
      digitalWrite(instr2, HIGH);
      digitalWrite(instr3, LOW);
      break;
    case 2:
      digitalWrite(instr1, LOW);
      digitalWrite(instr2, LOW);
      digitalWrite(instr3, HIGH);
      break;
  }

  //Statusänderung überprüfen
  if(!digitalRead(left)&&!LRactive){
    if(status==0) status = 3;
    status--;
    LRactive = true;
    LRmillis = millis() + 200;
  }
  if(!digitalRead(right)&&!LRactive){
    status++;
    status = status %3;
    LRactive = true;
    LRmillis = millis() + 200;
  }
  //Timer für LRfreigabe
  if(millis() > LRmillis){
    LRactive = false;
  }

  //Mute Button registrieren
  if(!digitalRead(mute)&&!muteactive){
    muteactive=true;
    mutemillis = millis()+200;
    switch (status){
    case 0:
      m1=!m1;
      break;
    case 1:
      m2=!m2;
      break;
    case 2:
      m3=!m3;
      break;
    }
  }
  //Timer für Mutefreigabe
  if(millis() > mutemillis){
    muteactive = false;
  }

  //MuteLEDs flashen
  if(m1){
    digitalWrite(mute1, HIGH);
  }else{
    digitalWrite(mute1, LOW);
  }

  if(m2){
    digitalWrite(mute2, HIGH);
  }else{
    digitalWrite(mute2, LOW);
  }

  if(m3){
    digitalWrite(mute3, HIGH);
  }else{
    digitalWrite(mute3, LOW);
  }
  

  
}
