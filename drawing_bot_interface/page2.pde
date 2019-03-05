class dxfDrapingPage {
    String[] dxf;
    String[] vport;
    String[] entity;
    String[][] ent;
    String[][] code;

    float viewcenterX = 0;
    float viewcenterY = 0;
    float viewWidthX = 1;
    float viewWidthY = 1;
    float aspectRatio = 1;

    boolean locked;
    Button backButton, printButton;
    float zoom=1, scaleStart=0, moveX, moveY, xOffset, yOffset, angle;
    PrintWriter output;


    dxfDrapingPage() {
    }

    void setup() {
        int buttonWidth = 80, buttonHeight = 50, tSize=14;
        backButton = new Button(int((float)width*.9), int((float)height*.9), buttonWidth, buttonHeight, "BACK", tSize);
        printButton = new Button(int((float)width*.9), int((float)height*.8), buttonWidth, buttonHeight, "PRINT", tSize);
        output = createWriter("positions.txt");
    }

    void draw() {
        if (p0.fileSelected) {
            drawGrid();
            drawDXF();
            backButton.display();
            printButton.display();

            textAlign(LEFT);
            textSize(12);
            fill(#009900);
            text("Drag the mouse to move and zoom, use R or r to rotate", 0, 24);
        }
    }

    public void mousePressed() {
        locked = true;
        xOffset = mouseX-moveX;
        yOffset = mouseY-moveY;

        if (backButton.mousePressed() && p0.fileSelected && p0.firstRun) {
            pages = 0;
            p0.fileSelected = false;
            p0.firstRun = false;
        }

        if (printButton.mousePressed()) {
            println("DXF start print");
            outputGcode();
            p99.lineCount = 0;
            pages = 99;
            p99.setup();
        }
    }

    public void mouseDragged() {
        if (locked) {
            moveX = mouseX - xOffset;
            moveY = mouseY - yOffset;
        }
    }

    public void mouseReleased() {
        locked = false;
    }

    public void mouseWheel(MouseEvent event) {
        float e = event.getCount();
        zoom*=1+0.05*e;
    }

    public void keyPressed() {
        if (key == 'R' || key =='r')    angle = (angle>=3)?0: angle+1;
        if (keyCode == ENTER){
            println("SVG start print");
            outputGcode();
            p99.lineCount = 0;
            pages = 99;
            p99.setup();
        }
    }

    void DXFImport() {
        readDXF();
        viewcenterX = float(vport[0]);
        viewcenterY = float(vport[2]);
        viewWidthY = float(vport[28]);
        aspectRatio = float(vport[30]);
        viewWidthX = viewWidthY * aspectRatio;
        zoom = 2;
    }
    void drawDXF() {
        noFill();
        strokeWeight(1.5/zoom);
        stroke(#FF0000);
        ellipseMode(CENTER);
        noFill();

        pushMatrix();
        translate(moveX,moveY);
        translate(-viewcenterX, viewcenterY);
        rotate(PI/2*angle);
        scale(zoom);

        for (int i = 1; i < ent.length; i++) {
            if (ent[i][1].contains("LINE")) {
                stroke(#FF0000);
                line(float(ent[i][7]), -float(ent[i][9]), float(ent[i][13]), -float(ent[i][15]));
            }
            if (ent[i][1].contains("ARC")) {
                float SA, EA;
                SA = 360 - float(ent[i][17]);
                EA = 360 - float(ent[i][15]);
                boolean is_anticlockwise = SA > EA;
                if (is_anticlockwise) EA += 360;
                arc(float(ent[i][7]), -float(ent[i][9]), 2*float(ent[i][13]), 2*float(ent[i][13]), radians(SA), radians(EA));
            }
            if (ent[i][1].contains("CIRCLE")) {
                if (ent[i][5].contains("HID")) {
                    stroke(0, 200, 0);
                } else {
                    stroke(#FF0000);
                }
                ellipse(float(ent[i][7]), -float(ent[i][9]), 2*float(ent[i][13]), 2*float(ent[i][13]));
            }
        }
        popMatrix();
    }

    void readDXF() {

        vport = cutSection(dxf, "VPORT", "ENDTAB");
        vport = cutSection(vport, " 12", " 43");
        dxf = cutSection(dxf, "ENTITIES", "ENDSEC");

        int numEntities = 0;
        for (int i = 0; i < dxf.length; i++) {
            if (dxf[i].contains("  0")) {
                dxf[i] = "ENTITY";
                numEntities ++;
            }
        }
        String joindxf;
        joindxf = join(dxf, "~");

        entity = split(joindxf, "ENTITY");
        ent = new String[numEntities + 1][];
        for (int i = 0; i <= numEntities; i++) {
            ent[i] = split(entity[i], "~");
        }
    }

    String[] cutSection(String[] dxfs, String startcut, String endcut) {
        int cutS = -1;
        for (int i = 0; i < dxfs.length; i++) {
            if (dxfs[i].contains(startcut)) {
                cutS = i;
            }
        }
        if (cutS == -1) {
            println("SECTION " + startcut + " NOT FOUND.");
        }
        dxfs = subset(dxfs, cutS + 1);

        int cutF = -1;
        for (int i = 0; i < dxfs.length; i++) {
            if (dxfs[i].contains(endcut)) {
                cutF = i;
                break;
            }
        }
        if (cutF == -1) {
            println("SECTION NOT TERMINATED at " + endcut + ".");
        }
        return subset(dxfs, 0, cutF-1);
    }

    void outputGcode() {
        drawDXF();

        //output.println("$X");
        p3.machineGcodeSetting(output);

        for (int i = 1; i < ent.length; i++) {
            if (ent[i][1].contains("LINE")) {
                float real_x_start=0;
                real_x_start = float(ent[i][7])*cos(PI/2*angle)-(-float(ent[i][9]))*sin(PI/2*angle);//rotation
                real_x_start *= zoom;
                real_x_start += -viewcenterX + moveX;

                float real_y_start=0;
                real_y_start = float(ent[i][7])*sin(PI/2*angle)+(-float(ent[i][9]))*cos(PI/2*angle);//rotation
                real_y_start *= zoom;
                real_y_start += viewcenterY + moveY;

                float real_x_end=0;
                real_x_end = float(ent[i][13])*cos(PI/2*angle)-(-float(ent[i][15]))*sin(PI/2*angle);//rotation
                real_x_end *= zoom;
                real_x_end += -viewcenterX + moveX;

                float real_y_end=0;
                real_y_end = float(ent[i][13])*sin(PI/2*angle)+(-float(ent[i][15]))*cos(PI/2*angle);//rotation
                real_y_end *= zoom;
                real_y_end += viewcenterY + moveY;

                output.println("M03 S"+p3.penUp+"\nG4 P0.3");

                output.println("G1 " + "X"+ real_x_start/2 + " Y" +real_y_start/2 + " F" + p3.feedRate); // Write the coordinate to the file
                output.println("M03 S"+p3.penDown+"\nG4 P0.3");

                output.println("G1 " + "X"+ real_x_end/2 + " Y" +real_y_end/2 + " F" + p3.feedRate); // Write the coordinate to the file
            }

            if (ent[i][1].contains("ARC")) {
                float SA, EA;

                SA = 360 - float(ent[i][17]);
                EA = 360 - float(ent[i][15]);
                boolean is_anticlockwise = SA>EA;
                //if (is_anticlockwise) EA += 360;

                float real_x_start, real_y_start, real_x_end, real_y_end, real_center_x, real_center_y, radius;
                float orignal_center_x = float(ent[i][7]);
                float orignal_center_y = -float(ent[i][9]);
                radius = float(ent[i][13]);
                float orignal_x_start = orignal_center_x+radius*cos(radians(is_anticlockwise?SA:EA));
                float orignal_y_start = orignal_center_y+radius*sin(radians(is_anticlockwise?SA:EA));
                float orignal_x_end = orignal_center_x+radius*cos(radians(is_anticlockwise?EA:SA));
                float orignal_y_end = orignal_center_y+radius*sin(radians(is_anticlockwise?EA:SA));

                real_x_start = orignal_x_start*cos(PI/2*angle)-(orignal_y_start)*sin(PI/2*angle);//rotation
                real_x_start *= zoom;
                real_x_start += -viewcenterX + moveX;

                real_y_start = orignal_x_start*sin(PI/2*angle)+(orignal_y_start)*cos(PI/2*angle);//rotation
                real_y_start *= zoom;
                real_y_start += viewcenterY + moveY;

                real_x_end = orignal_x_end*cos(PI/2*angle)-(orignal_y_end)*sin(PI/2*angle);//rotation
                real_x_end *= zoom;
                real_x_end += -viewcenterX + moveX;

                real_y_end = orignal_x_end*sin(PI/2*angle)+(orignal_y_end)*cos(PI/2*angle);//rotation
                real_y_end *= zoom;
                real_y_end += viewcenterY + moveY;

                radius *=zoom;

                real_center_x = orignal_center_x * cos(PI/2*angle)- orignal_center_y*sin(PI/2*angle);
                real_center_x *= zoom;
                real_center_x +=-viewcenterX + moveX;

                real_center_y = orignal_center_x * sin(PI/2*angle)+ orignal_center_y*cos(PI/2*angle);
                real_center_y *= zoom;
                real_center_y += viewcenterY + moveY;

                float offset_x = real_center_x-real_x_start;
                float offset_y = real_center_y-real_y_start;

                output.println("M03 S"+p3.penUp+"\nG4 P0.3");
                output.println("G1 " + "X"+ real_x_start/2 + " Y" +real_y_start/2+ " F" + p3.feedRate); // Write the coordinate to the file
                output.println("M03 S"+p3.penDown+"\nG4 P0.3");
                output.println((is_anticlockwise?"G3":"G2 ") + "X"+ real_x_end/2+ " Y" +real_y_end/2 +" I"+ offset_x /2+ " J"+ offset_y /2 + " F" + p3.feedRate); // Write the coordinate to the file
            }

            if (ent[i][1].contains("CIRCLE")) {
                float real_x_start, real_y_start, real_x_end, real_y_end, real_center_x, real_center_y, radius;
                float orignal_center_x = float(ent[i][7]);
                float orignal_center_y = -float(ent[i][9]);
                radius = float(ent[i][13]);
                float orignal_x_start = orignal_center_x+radius*cos(0);
                float orignal_y_start = orignal_center_y+radius*sin(0);
                float orignal_x_end = orignal_center_x+radius*cos(TWO_PI);
                float orignal_y_end = orignal_center_y+radius*sin(TWO_PI);

                real_x_start = orignal_x_start*cos(PI/2*angle)-(orignal_y_start)*sin(PI/2*angle);//rotation
                real_x_start *= zoom;
                real_x_start += -viewcenterX + moveX;

                real_y_start = orignal_x_start*sin(PI/2*angle)+(orignal_y_start)*cos(PI/2*angle);//rotation
                real_y_start *= zoom;
                real_y_start += viewcenterY + moveY;

                real_x_end = orignal_x_end*cos(PI/2*angle)-(orignal_y_end)*sin(PI/2*angle);//rotation
                real_x_end *= zoom;
                real_x_end += -viewcenterX + moveX;

                real_y_end = orignal_x_end*sin(PI/2*angle)+(orignal_y_end)*cos(PI/2*angle);//rotation
                real_y_end *= zoom;
                real_y_end += viewcenterY + moveY;

                radius *=zoom;

                real_center_x = orignal_center_x * cos(PI/2*angle)- orignal_center_y*sin(PI/2*angle);
                real_center_x *= zoom;
                real_center_x +=-viewcenterX + moveX;

                real_center_y = orignal_center_x * sin(PI/2*angle)+ orignal_center_y*cos(PI/2*angle);
                real_center_y *= zoom;
                real_center_y += viewcenterY + moveY;

                float offset_x = real_center_x-real_x_start;
                float offset_y = real_center_y-real_y_start;

                output.println("M03 S"+p3.penUp+"\nG4 P0.3");
                output.println("G1 " + "X"+ real_x_start/2 + " Y" +real_y_start/2+ " F" + p3.feedRate); // Write the coordinate to the file
                output.println("M03 S"+p3.penDown+"\nG4 P0.3");
                output.println("G2 " + "X"+ real_x_end/2+ " Y" +real_y_end/2 +" I"+ offset_x /2+ " J"+ offset_y /2 + " F" + p3.feedRate); // Write the coordinate to the file
            }
        }

        //END and back to 0,0
        output.println("M03 S"+p3.penUp+"\nG4 P0.3");

        output.println("G0 X0 Y0");
        output.flush();
        output.close();
        if (debug) println("READY TO DRAW");
    }

}
