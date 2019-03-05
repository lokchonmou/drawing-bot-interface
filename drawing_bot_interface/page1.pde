class svgDrapingPage {
    boolean locked;
    Button backButton, printButton;
    float scale=1, scaleStart=0, moveX, moveY, xOffset, yOffset, angle;
    PrintWriter output;

    svgDrapingPage() {
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
            drawPath();
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
            println("SVG start print");
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
        if (p0.fileSelected) grp.translate(moveX, moveY);
        moveX = moveY = 0;
    }

    public void mouseWheel(MouseEvent event) {
        float e = event.getCount();
        scale=1+0.05*e;
        grp.scale(scale, grp.getBottomLeft().x, grp.getBottomLeft().y);
    }

    public void keyPressed() {
        if (key =='R' || key == 'r') {
            angle = (angle>=3)?0:angle+1;
            grp.rotate(PI/2, grp.getCenter());
        }
        if (keyCode == ENTER){
            println("SVG start print");
            outputGcode();
            p99.lineCount = 0;
            pages = 99;
            p99.setup();
        }
    }



    void drawPath() {
        pointPaths = grp.getPointsInPaths();
        for (int i = 0; i<pointPaths.length; i++) {
            if (pointPaths[i] != null) {
                strokeWeight(1);
                stroke(#FF0000);

                beginShape();
                for (int j = 0; j<pointPaths[i].length; j++) {
                    noFill();
                    vertex(pointPaths[i][j].x, pointPaths[i][j].y);
                    ellipse(pointPaths[i][j].x, pointPaths[i][j].y, 1, 1);

                }
                endShape();
            }
        }
    }

    void outputGcode() {
        boolean posMoved = false;
        drawPath();

        //output.println("$X");
        p3.machineGcodeSetting(output);

        moveX = grp.getBottomLeft().x;
        moveY = grp.getBottomLeft().y;
        grp.translate(-moveX, moveY);
        grp.scale(11.81, grp.getBottomLeft().x, grp.getBottomLeft().y);

        pointPaths = grp.getPointsInPaths();
        for (int i = 0; i<pointPaths.length; i++) {
            if (pointPaths[i] != null) {
                for (int j = 0; j<pointPaths[i].length; j++) {
                    pointPaths[i][j].x = (pointPaths[i][j].x)/2.0/11.81+moveX/2.0;
                    pointPaths[i][j].y = (pointPaths[i][j].y)/2.0/11.81+moveY/2.0;

                    if (j == 0) output.println("G1 "+"X"+ nf(pointPaths[i][j].x,0,2) + " Y" +nf(pointPaths[i][j].y,0,2) + " F"+p3.feedRate+"\nM03 S"+p3.penDown+"\nG4 P0.3");
                    else output.println("X"+ nf(pointPaths[i][j].x,0,2) + " Y" +nf(pointPaths[i][j].y,0,2)); // Write the coordinate to the file

                    posMoved = true;
                }
            }

            output.println("M03 S"+p3.penUp+"\nG4 P0.3");
            posMoved = false;
        }
        output.println("G0 X0 Y0");
        output.flush();
        output.close();
        if (debug) println("ready to draw");
        grp.scale(1.0/11.81, grp.getBottomLeft().x, grp.getBottomLeft().y);
        grp.translate(moveX, -moveY);
    }
}
