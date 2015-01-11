/*  
 **  shapeForms
 **  Experiment with Leap Motion for Processing Beta 
 **  https://github.com/voidplus/leap-motion-processing/tree/beta
 **  Beware, there are many libs with the same class LeapMotion
 **
 **  ©2014 Joseph Gray
 */

import processing.video.*;
import de.voidplus.leapmotion.*;

LeapMotion leap;

PShader blur;

int totalJoints = 40; // 2*5*4 joints
PVector[] joints; 


int totalGeodes = 40; // 2*5*4 joints
Geode[] geodes; 

Movie mov;

void setupMovie()
{
  mov = new Movie(this, "transit.mov");
  mov.play();
  mov.loop();
}

void setup() {
  size(displayWidth, displayHeight, OPENGL);
  background(0);
setupMovie();

  blur = loadShader("blur.glsl"); 
  colorMode(HSB);

  noCursor();

  joints = new PVector[totalJoints];

  geodes = new Geode[totalGeodes]; // 5*2*4 joints

  for (int i=0; i<totalGeodes; i++) {
    float radiusMax = random(44, 111); 
    int totalVertex = round(random(5, 10));
    int totalSegments = round(random(5, 10)); 
    float noiseAmp = random(4, 17);
    color strokeColor = color(random(255), 128, 255, 11); 
    color fillColorLower = color(random(255), 255, 196, random(100, 150)); 
    color fillColorUpper  = color(random(255), 255, 255, random(100, 255));
    Geode geode = new Geode(radiusMax, totalVertex, totalSegments, noiseAmp, strokeColor, fillColorLower, fillColorUpper );
    geodes[i] = geode;
  }

  leap = new LeapMotion(this);
}

void draw() {
  //update the movie image if we can
  if (mov.available()) {
    mov.read();
  }  
  fill(255);
//  rect(mouseX,mouseY,50,50);
  lightFalloff(0.7, 0.001, 0.0);
  ambientLight(255, 0, 129);

  // set variable for shader
  blur.set("time", millis()/1000.f);
  filter(blur); 
  
  for (Hand hand : leap.getHands ()) {
    drawHand(hand);
  }
 
}

void drawBackground(float strength) {
  noStroke();
  pushMatrix();
    translate(width*.5, height*.5, 0);
  
    rotateY(millis()*.00007);
    pointLight( 128, 0, 255, 0, 0, 999);
  
    fill(255, strength);
    sphere(1000);
  
    rotateX(HALF_PI);
    fill(0);
    
    rectMode(CENTER);
    rect(0, 0, 5000, 5000);

  popMatrix();
}


void drawHand(Hand hand)
{
    //create two lights for this hand
    PVector hand_stabilized  = hand.getStabilizedPosition();
    pointLight( 196, 255, 255, hand_stabilized.x, hand_stabilized.y-1000.0, hand_stabilized.z);
    pointLight( 64, 255, 255, hand_stabilized.x, hand_stabilized.y+1000.0, hand_stabilized.z);


    float scalar = hand.getSphereRadius()/100.0;
    float currentRollPitchYaw[] = new float[]{radians(hand.getRoll()),
                                              radians(hand.getPitch()), 
                                              radians(hand.getYaw())};

    // ========= FINGERS =========
    noStroke();
    beginShape(QUAD_STRIP);
  
    int i=0;
    for(Finger finger : hand.getFingers()){
        i++;
        //create a vector for joint position
        PVector[] joints = new PVector[4];
        joints[0] = finger.getPositionOfJointTip();
        joints[1] = finger.getPositionOfJointDip();
        joints[2] = finger.getPositionOfJointPip();
        joints[3] = finger.getPositionOfJointMcp();
  
        int geodeIndex = i*4;
        //draw one geode for each joint
        for(PVector joint : joints){
          geodeIndex++;
          pushMatrix();
            translate(joint.x, joint.y, joint.z);
            //rotate some based on the position of the joint
            rotateX(joint.x*scalar*.001);
            rotateY(joint.y*scalar*.001);
            rotateZ(joint.z*scalar*.001);
            //more rotation for that of the 'hand'
            rotateX(currentRollPitchYaw[0]+HALF_PI);
            rotateY(currentRollPitchYaw[1]);
            rotateZ(-currentRollPitchYaw[2]);
            //scale based on 'hand sphere radius'
            scale(scalar);
            geodes[geodeIndex].mesh.setTexture(mov);
            shape(geodes[geodeIndex].mesh);
          popMatrix();
        }
      }
      endShape();
}
