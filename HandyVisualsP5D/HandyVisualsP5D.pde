import com.onformative.leap.LeapMotionP5;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.Hand;
import peasy.*;
import oscP5.*;
import netP5.*;


TUIOServer tuioServer;
TouchPoint simPoint;

PeasyCam cam;

LeapMotionP5 leap;

Hotpoint hotpoint1;


int x;
int y;
float outerRad;
float innerRad;

PVector f1;
// Size of each cell in the grid, ratio of window size to video size
// 80 * 8 = 640
// 60 * 8 = 480
int videoScale = 80;

// Number of columns and rows in our system
int cols, rows;

TouchPoint[] touchPoints;

static int globalTouchPointIndex;


public void setup() {
  size(700, 700, P3D);
  leap = new LeapMotionP5(this);
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2000);

  cols = screenWidth/videoScale;
  rows = screenHeight/videoScale;
  
  hotpoint1 = new Hotpoint(200, 200, 800, 150);
}

public void draw() {
  background(255);
 translate(-720,-500);
  noFill();

  // Begin loop for columns
  for (int i = 0; i < cols; i++) {
    // Begin loop for rows
    for (int j = 0; j < rows; j++) {
      //


      // Scaling up to draw a rectangle at (x,y)
      int x = i*videoScale;
      int y = j*videoScale;


      noFill();
      stroke(170, 170, 170);
      // For every column and row, a rectangle is drawn at an (x,y) location scaled and sized by videoScale.
      rect(x, y, videoScale, videoScale);
    }
  }


  for (Hand hand : leap.getHandList()) {
    

    PVector handPos = leap.getPosition(hand);
    PVector sphere_center = leap.getSphereCenter(hand);
    float sphere_radius = leap.getSphereRadius(hand);
    //PVector handStable = leap.getStabilizedPosition(hand);

    stroke(0, 255, 0);
    strokeWeight(1);
    float ellipseSizeHand = map(handPos.z, 300, -400, handPos.z/10, handPos.z/5);
    ellipse(handPos.x, handPos.y, ellipseSizeHand, ellipseSizeHand);

    arc(handPos.x, handPos.y, 60, 60, PI, TWO_PI);
    hotpoint1.check(handPos);


//begin hand visuals

    pushMatrix();
    translate(handPos.x, handPos.y, handPos.z);
   stroke(0);
  
  scale(sphere_radius/5);
  beginShape();
  vertex(-1, -1, -1);
  vertex( 1, -1, -1);
  vertex( 0,  0,  1);

  vertex( 1, -1, -1);
  vertex( 1,  1, -1);
  vertex( 0,  0,  1);

  vertex( 1, 1, -1);
  vertex(-1, 1, -1);
  vertex( 0, 0,  1);

  vertex(-1,  1, -1);
  vertex(-1, -1, -1);
  vertex( 0,  0,  1);
  endShape();
    popMatrix();


    for (Finger finger : leap.getFingerList()) {
      PVector fingerPos = leap.getTip(finger);
      stroke(255, 0, 0);

      line(handPos.x, handPos.y, handPos.z, 
      fingerPos.x, fingerPos.y, fingerPos.z);
      float ellipseSizeHandStable = map(fingerPos.z, 300, -400, fingerPos.z/10, fingerPos.z/5);
      ellipse(fingerPos.x, fingerPos.y, ellipseSizeHandStable, ellipseSizeHandStable);
      println("finger" + fingerPos);

      stroke(0, 0, 255);
      arc(fingerPos.x, fingerPos.y, 60, 60, PI, TWO_PI);
      stroke(0, 200, 200);
      strokeWeight(1);
      pushMatrix();
      translate(fingerPos.x, fingerPos.y, fingerPos.z);
        beginShape();
        scale(10);
        
  vertex(-1, -1, -1);
  vertex( 1, -1, -1);
  vertex( 0,  0,  1);

  vertex( 1, -1, -1);
  vertex( 1,  1, -1);
  vertex( 0,  0,  1);

  vertex( 1, 1, -1);
  vertex(-1, 1, -1);
  vertex( 0, 0,  1);

  vertex(-1,  1, -1);
  vertex(-1, -1, -1);
  vertex( 0,  0,  1);
  endShape();
      popMatrix();
    }
  }
}

public void stop() {
  leap.stop();
}

