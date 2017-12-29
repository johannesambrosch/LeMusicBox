import processing.serial.*;
import jm.JMC;
import jm.music.data.*;
import jm.util.*;
import jm.music.tools.*;

Score score;

boolean inst1 = false;
boolean inst2 = false;
boolean inst3 = false;
boolean inst4 = false;

int i1d = 127;
int i2d = 127;
int i3d = 127;
int i4d = 127;

final int i1n = 0;
final int i2n = 1;
final int i3n = 2;
final int i4n = 3;

int i2t = 0;
int i3t = 0;
int i4t = 0;

int bpm = 128;

Serial myPort;  // Create object from Serial class
String val;

boolean m1 = false;
boolean m2 = false;
boolean m3 = false;

int status;
int pitchbend;

boolean playenabled = false;
int timer = 0;


//TUIO STUFF

// import the TUIO library
import TUIO.*;
// declare a TuioProcessing client
TuioProcessing tuioClient;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks



void setup() {
  score = new Score("EDMBEAT");

  String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);

  //TUIO STUFF
  // GUI setup
  noCursor();
  size(displayWidth, displayHeight);
  noStroke();
  fill(0);

  // periodic updates
  if (!callback) {
    frameRate(60); //<>//
    loop();
  } else noLoop(); // or callback updates 

  font = createFont("Arial", 18);
  scale_factor = height/table_size;

  // finally we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods in this class (see below)
  tuioClient  = new TuioProcessing(this);
}

void draw() {
  

  if ( myPort.available() > 0 && timer<millis()) {  // If data is available,
    String line = "";
    do {
      // read it and store it in val
      val = myPort.readStringUntil('\n');
      if (val!=null) {line=val;
      playenabled=true;
      timer = millis()+1000;
      }
      //println(val);
    }
    while (val!=null);
    
    
    

    if (line!="") {
      //println(line.substring(0,1));
      m1=((line.substring(0, 1).equals("1"))? true : false);
      m2=((line.substring(1, 2).equals("1"))? true : false);
      m3=((line.substring(2, 3).equals("1"))? true : false);
      status = int(line.substring(4, 5));
      String pitch = line.substring(6);
      //println(pitch);
      pitchbend = int(trim(pitch));
      pitchbend = int(map(pitchbend, 16,1023,-2.99,+2.99));
      println(m1);
      println(m2);
      println(m3);
      println(status);
      println(pitchbend);
      
      if(playenabled){
      reloadScore(score);
      Play.midi(score);
      //println(line);
      }
    }
  } 

  // 






  //TUIO STUFF

  background(255);
  textFont(font, 18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 

  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  for (int i=0; i<tuioObjectList.size (); i++) {
    TuioObject tobj = tuioObjectList.get(i);
    stroke(0);
    fill(0, 0, 0);
    pushMatrix();
    translate(tobj.getScreenX(width), tobj.getScreenY(height));
    //println(tobj.getScreenX(width));
    int pitch = (int)map(tobj.getScreenX(width), 0, 1920, 110, 880);
    rotate(tobj.getAngle());
    rect(-obj_size/2, -obj_size/2, obj_size, obj_size);
    popMatrix();
    fill(255);
    text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
  }

  ArrayList<TuioCursor> tuioCursorList = tuioClient.getTuioCursorList();
  for (int i=0; i<tuioCursorList.size (); i++) {
    TuioCursor tcur = tuioCursorList.get(i);
    ArrayList<TuioPoint> pointList = tcur.getPath();

    if (pointList.size()>0) {
      stroke(0, 0, 255);
      TuioPoint start_point = pointList.get(0);
      for (int j=0; j<pointList.size (); j++) {
        TuioPoint end_point = pointList.get(j);
        line(start_point.getScreenX(width), start_point.getScreenY(height), end_point.getScreenX(width), end_point.getScreenY(height));
        start_point = end_point;
      }

      stroke(192, 192, 192);
      fill(192, 192, 192);
      ellipse( tcur.getScreenX(width), tcur.getScreenY(height), cur_size, cur_size);
      fill(0);
      text(""+ tcur.getCursorID(), tcur.getScreenX(width)-5, tcur.getScreenY(height)+5);
    }
  }

  ArrayList<TuioBlob> tuioBlobList = tuioClient.getTuioBlobList();
  for (int i=0; i<tuioBlobList.size (); i++) {
    TuioBlob tblb = tuioBlobList.get(i);
    stroke(0);
    fill(0);
    pushMatrix();
    translate(tblb.getScreenX(width), tblb.getScreenY(height));
    rotate(tblb.getAngle());
    ellipse(-1*tblb.getScreenWidth(width)/2, -1*tblb.getScreenHeight(height)/2, tblb.getScreenWidth(width), tblb.getScreenWidth(width));
    popMatrix();
    fill(255);
    text(""+tblb.getBlobID(), tblb.getScreenX(width), tblb.getScreenX(width));
  }
}

void updateinst(int id, float x, float y) {
  //println("UPDATE");
  if (id==1) {
    println("x: " + x + ", y: "+y);
    bpm = (int) map(x, 0, 1, 50, 280);
    i1d = (int) map(y, 0, 1, 0, 127);
    println(i1d);
  } else if (id==2) {
    i2t=(int) map(x, 0, 1, -24, 24);
    i2d = (int) map(y, 0, 1, 0, 127);
  } else if (id==3) {
    i3t=(int) map(x, 0, 1, -24, 24);
    i3d = (int) map(y, 0, 1, 0, 127);
  } else if (id==4) {
    i4t=(int) map(x, 0, 1, -24, 24);
    i4d = (int) map(y, 0, 1, 0, 127);
  }
}

//TUIO METHODS

// --------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs
// there are three callbacks for add/set/del events for each object/cursor/blob type
// the final refresh callback marks the end of each TUIO frame

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
  if (tobj.getSymbolID()==i1n) {
    inst1= true;
    updateinst(1, tobj.getX(), tobj.getY());
    //println("SCHLAGZEUG AN DU HUSO");
  }
  if (tobj.getSymbolID()==i2n) {
    inst2= true;
    updateinst(2, tobj.getX(), tobj.getY());
  }
  if (tobj.getSymbolID()==i3n) {
    inst3= true;
    updateinst(3, tobj.getX(), tobj.getY());
  }
  if (tobj.getSymbolID()==i4n) {
    inst4= true;
    updateinst(4, tobj.getX(), tobj.getY());
  }
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (verbose) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
    +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
  if (tobj.getSymbolID()==i1n) {
    updateinst(1, tobj.getX(), tobj.getY());
  }
  if (tobj.getSymbolID()==i2n) {
    updateinst(2, tobj.getX(), tobj.getY());
  }
  if (tobj.getSymbolID()==i3n) {
    updateinst(3, tobj.getX(), tobj.getY());
  }
  if (tobj.getSymbolID()==i4n) {
    updateinst(4, tobj.getX(), tobj.getY());
  }
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (verbose) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  if (tobj.getSymbolID()==i1n) {
    inst1= false;
    //println("SCHLAGZEUG AUS DU HUSO");
  }
  if (tobj.getSymbolID()==i2n) inst2= false;
  if (tobj.getSymbolID()==i3n) inst3= false;
  if (tobj.getSymbolID()==i4n) inst4= false;
}

// --------------------------------------------------------------
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  if (verbose) println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  //redraw();
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  if (verbose) println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
  //redraw();
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (verbose) println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called when a blob is added to the scene
void addTuioBlob(TuioBlob tblb) {
  if (verbose) println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
  //redraw();
}

// called when a blob is moved
void updateTuioBlob (TuioBlob tblb) {
  if (verbose) println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
    +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
  //redraw()
}

// called when a blob is removed from the scene
void removeTuioBlob(TuioBlob tblb) {
  if (verbose) println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) {
  if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  if (callback) redraw();
}





//JMUSIC METHODS
private Phrase phraseFill(int length, int pitch) {
  Phrase phrase = new Phrase(0.0);
  for (int i=0; i<length; i++) {
    Note note = new Note(pitch, jm.JMC.EN, 
    (int)(Math.random()*20 + 100));
    phrase.addNote(note);
  }
  return phrase;
}

private Score reloadScore(Score score) {
  score.setTempo(bpm);
  Part flute = new Part("Flute", jm.JMC.FLUTE, 0);
  Part trumpet = new Part("Brass", jm.JMC.BRASS, 1);
  Part bass = new Part("Bass", jm.JMC.BASS, 2);

  score.empty();

  Part drums = new Part("Drums", 25, 9);
  drums.empty();
  Phrase phrBD = new Phrase();
  Phrase phrSD = new Phrase();
  Phrase phrHH = new Phrase();

  phrBD = phraseFill(8, 36);
  phrSD = phraseFill(8, 38);
  phrHH = phraseFill(8, 42);

  for (int i =0; i<8; i++) {
    phrBD.getNote(i).setPitch(jm.JMC.REST);
    phrSD.getNote(i).setPitch(jm.JMC.REST);
    phrHH.getNote(i).setPitch(jm.JMC.REST);
  }

  for (int i =0; i<8; i+=2) {
    phrBD.getNote(i).setPitch(36);
  }

  phrSD.getNote(2).setPitch(38);
  phrSD.getNote(6).setPitch(38);

  phrHH.getNote(1).setPitch(42);
  phrHH.getNote(3).setPitch(42);
  phrHH.getNote(5).setPitch(42);
  phrHH.getNote(7).setPitch(42);

  phrHH.getNote(1).setDynamic(30);
  phrHH.getNote(3).setDynamic(30);
  phrHH.getNote(5).setDynamic(30);
  phrHH.getNote(7).setDynamic(30);

  //Repeat drumloops
  int loopNum = 4;
  Mod.repeat(phrBD, loopNum);
  Mod.repeat(phrSD, loopNum);
  Mod.repeat(phrHH, loopNum);

  phrBD.setDynamic(i1d);
  phrSD.setDynamic(i1d);
  phrHH.setDynamic(i1d);

  // add phrases to the instrument (part)
  drums.addPhrase(phrBD);
  drums.addPhrase(phrSD);
  drums.addPhrase(phrHH);



  int[] pitchArray = {
    jm.JMC.E4, jm.JMC.G4, jm.JMC.D4, jm.JMC.C4
  };
  int[] pitchArray2 = {
    jm.JMC.E4, jm.JMC.B3, jm.JMC.G4, jm.JMC.D4, jm.JMC.D4, jm.JMC.A3, jm.JMC.C4, jm.JMC.G3
  };
  int[] pitchArray3 = {
    jm.JMC.E1, jm.JMC.E1, jm.JMC.E1, jm.JMC.E1, jm.JMC.E1, jm.JMC.E1, jm.JMC.E1, jm.JMC.E1, 
    jm.JMC.G1, jm.JMC.G1, jm.JMC.G1, jm.JMC.G1, jm.JMC.G1, jm.JMC.G1, jm.JMC.G1, jm.JMC.G1, 
    jm.JMC.D1, jm.JMC.D1, jm.JMC.D1, jm.JMC.D1, jm.JMC.D1, jm.JMC.D1, jm.JMC.D1, jm.JMC.D1, 
    jm.JMC.C1, jm.JMC.C1, jm.JMC.C1, jm.JMC.C1, jm.JMC.C1, jm.JMC.C1, jm.JMC.C1, jm.JMC.C1
  };
  double[] rhythmArray = {
    jm.JMC.WN, jm.JMC.WN, jm.JMC.WN, jm.JMC.WN
  };
  double[] rhythmArray2 = {
    jm.JMC.HN, jm.JMC.HN, jm.JMC.HN, jm.JMC.HN, jm.JMC.HN, jm.JMC.HN, jm.JMC.HN, jm.JMC.HN
  };
  double[] rhythmArray3 = {
    jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, 
    jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, 
    jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, 
    jm.JMC.EN, jm.JMC.EN, 
    jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN, jm.JMC.EN,
  };


  Phrase phrase1 = new Phrase(0.0);
  Phrase phrase2 = new Phrase(0.0);
  Phrase phrase3 = new Phrase(0.0);
  phrase1.addNoteList(pitchArray, rhythmArray);
  phrase2.addNoteList(pitchArray2, rhythmArray2);
  phrase3.addNoteList(pitchArray3, rhythmArray3);

  phrase1.setDynamic(i2d);
  phrase2.setDynamic(i3d);
  phrase3.setDynamic(i4d);


  Mod.transpose(phrase1, i2t);
  Mod.transpose(phrase2, i3t);
  Mod.transpose(phrase3, i4t);
  
  if(status==0){
    Mod.transpose(phrase1, pitchbend);
  }else if(status==1){
    Mod.transpose(phrase2, pitchbend);
  }else if(status==2){
    Mod.transpose(phrase3, pitchbend);
  }


  //add phrases to the parts
  flute.addPhrase(phrase1);    
  trumpet.addPhrase(phrase2);
  bass.addPhrase(phrase3);

  //add parts to the score
  if (inst2&&!m1)score.addPart(flute);
  if (inst3&&!m2)score.addPart(trumpet);  
  if (inst4&&!m3)score.addPart(bass);
  if (inst1) {
    score.addPart(drums);
  }

  return score;
}


void keyPressed() {
  /*if (key== CODED) {
   if (keyCode==UP) {
   bpm+=20;
   } else if (keyCode==DOWN) {
   bpm-=20;
   if (bpm<50) {
   bpm=50;
   }
   }
   if (keyCode==LEFT) {
   i2t--;
   }
   if (keyCode==RIGHT) {
   i2t++;
   }
   }
   if (key=='1') {
   inst1=!inst1;
   } else if (key=='2') {
   inst2=!inst2;
   } else if (key=='3') {
   inst3=!inst3;
   } else if (key=='4') {
   inst4=!inst4;
   }*/
}