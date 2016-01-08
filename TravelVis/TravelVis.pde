/***************************************************
 *  Travels in Pixels 2015
 *  Created by David Jan Mercado 2016
 *  www.davidjanmercado.com
 ***************************************************/

// {bg, ellipse, line, midpoint, halo, text}
color[] darkmap = {#0D1B24, #43ED4A, #43ED4A, #43ED4A, #FFFFFF, #FFFFFF};
//color[] abstractmap = {#0D1B24, #DCEBF0, #DCEBF0, #EA7525, #FFFFFF, #FFFFFF};  // abs
color[] palette = darkmap;
PFont monthFont, dataFont;

Table gpsdata;
int rowCount;

PImage europeMap;
MercatorMap mercatorMap;

PVector screenLoc;
PVector prevLoc;

float d = 2;
int row = 1;

// Calendar graph
int numOfDays = 365;
int numOfMonths = 12;
int numOfPhotos = 0;

float prevCX = 0f;
float prevCY = 0f;

float calOriginX = 0;
float calOriginY = 510;
float calEndX = 800;
float calEndY = 460;

boolean anim = true; // true to see animated points

String[] monthName = {"NULL", "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
                      "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"};
int[] dayCount = {0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334};

void setup() {
  size(800, 600);
  smooth();
  frameRate(10); // slow frame rate to compensate for the few test data
  
  gpsdata = new Table("gpstestdata.csv");
  rowCount = gpsdata.getRowCount();
  
  europeMap = loadImage("europe.png");
  monthFont = loadFont("HapnaMono-Light-50.vlw");
  dataFont = loadFont("HelveticaNeueCE-Thin-11.vlw");
  
  // Tile mill: (W, S, E, N) -5.603, 39.2323, 23.4888, 53.8525
  // mercatorMap: (N, S, W, E)
  mercatorMap = new MercatorMap(width, height, 54.4349, 39.1514, -5.1856, 23.8623);
 
  prevLoc = mercatorMap.getScreenLocation(new PVector(51.525455, 0.13640556));
  
  if (!anim) {
    background(palette[0]);
    image(europeMap, 0, 0, width, height); // comment out if abs
  }
}

void draw() {
  if (anim) {
    background(palette[0]);
    image(europeMap, 0, 0, width, height);
    
    stroke(palette[5], 50);
    strokeWeight(0.5);
    line(5, 590, 795, 590);
  }
  
  if (row < rowCount) {
    String filename = gpsdata.getString(row, 0);
    float latitude = gpsdata.getFloat(row, 1);
    float longitude = gpsdata.getFloat(row, 2);
    String date = gpsdata.getString(row, 3);
      
    screenLoc = mercatorMap.getScreenLocation(new PVector(latitude, longitude));

    if (anim) {
      drawHalo(date);
      fill(palette[5], 80);
      textFont(dataFont);
      textAlign(LEFT);
      text(date, screenLoc.x+12, screenLoc.y+3); // Draw date
      
      drawTimeSeq(date);
      writeDate(date);
    } else {
      drawSimple();
      //drawHalo(date); // abs
    }
    
    prevLoc = screenLoc;
   
    row++;
  } else {
    if (anim) {
      fill(palette[2], 80);
      textFont(monthFont);
      textAlign(CENTER);
      text("TRAVELS IN PIXELS 2015", width/2, height/2+20);
    }
    //println("DONE");
  }
  //saveFrame("/Volumes/PYTHON/photosall/01AnimFalse/" + "no-anim-#######.png");
}

void drawSimple() {
    noStroke();
    
    // Point
    fill(palette[1], 70);
    ellipse(screenLoc.x, screenLoc.y, d, d);
    
    // Line
    stroke(palette[2], 70);
    strokeWeight(0.1); // abs
    noFill();
    line(prevLoc.x, prevLoc.y, screenLoc.x, screenLoc.y);
}

void drawHalo(String mDate) {
  
  String[] datelist = mDate.split(" ");
  float month = Float.parseFloat(datelist[0].substring(5,7));
  float day = Float.parseFloat(datelist[0].substring(8, 10));
  
  noStroke();
  fill(palette[1]);
  float cx = map(day + dayCount[(int)month], 1, 365, calOriginX+5, calEndX-5); // Days
  float cy = map(0, 0, 386, calOriginY, calEndY);
  
  if (cx == prevCX) { // Same date
    numOfPhotos+=0.2;
  } else {
    numOfPhotos = 0;
    prevCX = cx;
  }
  
  d = numOfPhotos;
  //d = 50 + 20 * sin(frameCount * 0.1f); // abs (pulsing halo)
  
  // Mid Point 
  noStroke();
  fill(palette[3], 100);
  ellipse(screenLoc.x, screenLoc.y, 2, 2); // Remains constant
    
  // Halo
  fill(palette[4], 10);
  ellipse(screenLoc.x, screenLoc.y, d, d);
    
  // Line
  stroke(palette[1], 70);
  strokeWeight(1);
  noFill();
  line(prevLoc.x, prevLoc.y, screenLoc.x, screenLoc.y);
}

void writeDate(String mDate) {
  String[] datelist = mDate.split(" ");
  float month = Float.parseFloat(datelist[0].substring(5,7));
  float day = Float.parseFloat(datelist[0].substring(8, 10));
  
  fill(palette[2], 80);
  textFont(monthFont);
  textAlign(RIGHT);
  text(nf((int)month, 2, 0), 785, height-25);
}

void drawTimeSeq(String mDate) {
  String[] datelist = mDate.split(" ");
  float month = Float.parseFloat(datelist[0].substring(5,7));
  float day = Float.parseFloat(datelist[0].substring(8, 10));
  
  noStroke();
  fill(palette[1]);
  float cx = map(day + dayCount[(int)month], 1, 365, calOriginX+5, calEndX-5); // Days
  float cy = map(0, 0, 386, calOriginY, calEndY);
  
  if (cx == prevCX) { // Same date
    numOfPhotos++;
  } else {
    numOfPhotos = 0;
    prevCX = cx;
  }
  
  // Time rect
  float tx = map(day + dayCount[(int)month], 1, 365, calOriginX+5, calEndX-5);
  fill(palette[2], 100);
  rect(tx, 588, 5, 5);
}

void keyPressed() {
  if (key == 's') {
    //save("/Volumes/PYTHON/photosall/03Abstract/" + "abstract-num.png");
    print("Saved");
  }
}

// Photos in simple bar graph
//void drawCalendarAxis(int mRow, PVector mScreenLoc, String mDate) {
//  String[] datelist = mDate.split(" ");
//  float month = Float.parseFloat(datelist[0].substring(5,7));
//  float day = Float.parseFloat(datelist[0].substring(8, 10));
//  
//  //line(0, 550, width, 550);
//  float cx = map(day + dayCount[(int)month], 1, 365, calOriginX, calEndX); // Days
//  float cy = map(0, 0, 386, calOriginY, calEndY);;
//  if (cx == prevCX) { // Same date
//    cy = map(numOfPhotos++, 0, 386, calOriginY, calEndY); // Number of photos. Note, 386, max count (jan 31)
//    ellipse(cx, cy, 0.1, 0.1);
//  } else {
//    numOfPhotos = 0;
//    prevCX = cx;
//  }
//}
