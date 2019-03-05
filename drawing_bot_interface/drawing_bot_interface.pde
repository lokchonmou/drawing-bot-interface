import geomerative.*;
import processing.serial.*;
import processing.video.*;
import gab.opencv.*;    //need OpenCV for Processing 0.5.4, Author Greg Borenstein
import static javax.swing.JOptionPane.*;


//Import serial library for arduino GRBL
Serial myPort;
boolean oked = true;       //use hold the serial feed back ok

//RShape is a library that can display SVG
RShape grp;
RPoint[][] pointPaths;

// video and OpenCV object use in live cam and photo mode
Capture video;
OpenCV opencv;
Histogram histogram;

int pages=0;                 //hold the GUI pages
boolean debug = true;


void setup() {
    size(620, 720);  //the screen display a drawing area 310X360mm
    pixelDensity(displayDensity());
    frameRate(600);

    serialSelect();
    while(true){
        if (myPort.available() > 0) {
            String myString = myPort.readStringUntil('\n');
            if (myString != null) {
                myString = trim(myString);
                if (myString.contains("Grbl")){
                    println(myString);
                    break;
                }
            }
        }
    }

    p0.setup();

    // use to init the SVG library, can't do it in SVG page
    RG.init(this);
    RG.setDpi(300);
    RG.ignoreStyles(true);
}

void draw() {
    switch (pages){
        case 0: p0.draw(); break;
        case 1: p1.draw(); break;
        case 2: p2.draw(); break;
        case 3: p3.draw(); break;
        case 4: p4.draw(); break;
        case 5: p5.draw(); break;
        case 6: p6.draw(); break;
        case 99: p99.draw(); break;
    }
}

void mousePressed() {
    switch(pages){
        case 0: p0.mousePressed(); break;
        case 1: p1.mousePressed(); break;
        case 2: p2.mousePressed(); break;
        case 3: p3.mousePressed(); break;
        case 4: p4.mousePressed(); break;
        case 5: p5.mousePressed(); break;
        case 6: p6.mousePressed(); break;
    }
}

void mouseDragged() {
    switch(pages){
        case 1: p1.mouseDragged(); break;
        case 2: p2.mouseDragged(); break;
        case 6: p6.mouseDragged(); break;
    }
}

void mouseReleased() {
    switch(pages){
        case 1: p1.mouseReleased(); break;
        case 2: p2.mouseReleased(); break;
        case 6: p6.mouseReleased(); break;
    }
}

void mouseWheel(MouseEvent event) {
    switch(pages){
        case 1: p1.mouseWheel(event); break;
        case 2: p2.mouseWheel(event); break;
        case 6: p6.mouseWheel(event); break;
    }
}

void keyPressed(){
    switch(pages){
        case 1: p1.keyPressed(); break;
        case 2: p2.keyPressed(); break;
        case 3: p3.keyPressed(); break;
        case 4: p4.keyPressed(); break;
        case 5: p5.keyPressed(); break;
        case 6: p6.keyPressed(); break;
    }
}

//void serialEvent(Serial p){
//    //p99.serialEvent(p);
//}


void serialSelect() {

    String COMx, COMlist = "";

    try {
        if (debug) printArray(Serial.list());
        int i = Serial.list().length;
        if (i != 0) {
            if (i >= 2) {
                // need to check which port the inst uses -
                // for now we'll just let the user decide
                for (int j = 0; j < i; ) {
                    COMlist += char(j+'0') + " = " + Serial.list()[j];
                    if (++j < i) COMlist += ",  ";
                }
                COMx = showInputDialog("Which COM port is correct? (0,1,..):\n"+COMlist);
                if (COMx == null) exit();
                if (COMx.isEmpty()) exit();
                i = int(COMx.toLowerCase().charAt(0) - '0') + 1;
            }
            String portName = Serial.list()[i-1];
            if (debug) println(portName);
            myPort = new Serial(this, portName, 115200); // change baud rate to your liking
            myPort.bufferUntil('\n'); // buffer until CR/LF appears, but not required..
            } else {
                showMessageDialog(frame, "Device is not connected to the PC");
                exit();
            }
        }
        catch (Exception e){ //Print the type of error
            showMessageDialog(frame, "COM port is not available (may\nbe in use by another program)");
            println("Error:", e);
            exit();
        }
    }

    void drawGrid() {
        background(204);
        stroke(0);
        textAlign(LEFT);
        textSize(12);
        for (int x=1; x<=35; x++) {
            strokeWeight(0.3);
            if (x %5 ==0) {
                strokeWeight(1);
                fill(0);
                text(x, 0, x*height/36);
            }
            line(0, x*height/36, width, x*height/36);
        }

        for (int y=1; y<=30; y++) {
            strokeWeight(0.3);
            if (y %5 ==0) {
                strokeWeight(1);
                fill(0);
                text(y, y*width/31, 12);
            }
            line( y*width/31, 0, y*width/31, height);
        }
        noFill();
        strokeWeight(2);
        stroke(#00CB23);
        rectMode(LEFT);
        rect(0, 0, 210*2, 297*2);
        rect(0, 0, 297*2, 210*2);
        stroke(#00AAFC);
        rect(0, 0, 297/2*2, 210*2);
        rect(0, 0, 210*2, 297/2*2);
    }

    void FileSelected(File selection) {
        if (selection == null) {
            if (debug) println("Window was closed or the user hit cancel.");
            } else {
                if (debug) println("User selected " + selection.getAbsolutePath());
                String s = selection.getAbsolutePath();
                s.subSequence(s.length()-4, s.length());
                if (s.subSequence(s.length()-4, s.length()).equals(".svg")
                || s.subSequence(s.length()-4, s.length()).equals(".SVG")) {
                    grp = RG.loadShape(selection.getAbsolutePath());
                    p0.fileSelected = true;
                    p1.setup();
                    pages = 1;
                }
                else if((s.subSequence(s.length()-4, s.length()).equals(".dxf")
                || s.subSequence(s.length()-4, s.length()).equals(".DXF"))){
                    p2.dxf = loadStrings(selection.getAbsolutePath());
                    p2.DXFImport();
                    p0.fileSelected = true;
                    p2.setup();
                    pages = 2;
                }
                else if(s.subSequence(s.length()-4, s.length()).equals(".jpg")
                || s.subSequence(s.length()-4, s.length()).equals(".JPG")
                || s.subSequence(s.length()-5, s.length()).equals(".jpeg")
                || s.subSequence(s.length()-5, s.length()).equals(".JPEG")
                || s.subSequence(s.length()-4, s.length()).equals(".png")
                || s.subSequence(s.length()-4, s.length()).equals(".PNG")){
                    p5.src = loadImage(selection.getAbsolutePath());
                    p0.fileSelected = true;
                    p5.photoRatio = float(p5.src.height)/float(p5.src.width);

                    surface.setResizable(true);
                    surface.setSize(984, int(984*p5.photoRatio)); //100dpi
                    p5.src.resize(width, height);

                    opencv = new OpenCV(this, p5.src);
                    p5.photoSelected = true;
                    redraw();
                    surface.setResizable(false);
                    p5.setup();
                    pages = 5;
                }
                else {
                    println("ERROR!!! PLEASE SELECT FILE TYPE: .svg, .dxf, .jpg, .png");
                    pages = 0;
                }
            }
        }

        void camSelect(){
            if (debug)println("working mode = live webcam mode\n"+Capture.list());

            video = new Capture(this, 1280, 720);
            video.start();
            p4.src = video.get();
            p4.photoRatio = float(p4.src.height)/float(p4.src.width);

            surface.setResizable(true);
            surface.setSize(984, int(984*p4.photoRatio));  //100dpi=3.937dpmm, 250mm*3.937dpmm= 984pixel
            p4.src.resize(width, height);

            opencv = new OpenCV(this,p4. src);
            p4.camSelected = true;
            redraw();
            surface.setResizable(false);
        }

        void closeCam(){
            video.stop();
        }

        void captureEvent(Capture c) {
            c.read();
        }
