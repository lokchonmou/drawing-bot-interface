class photoDrapingPage {
    boolean locked;
    Button backButton, printButton;
    float zoom=1, scale=1, viewcenterX, viewcenterY, moveX, moveY, xOffset, yOffset, angle;
    PrintWriter output;
    ArrayList<ArrayList<Contour>> displayContours;

    photoDrapingPage(){}

    void setup(){

        if (p4.contours.size() == 0) displayContours = p5.contours;
        else if (p5.contours.size() == 0) displayContours = p4.contours;
        viewcenterX=984/3.937*2/2;
        viewcenterY=int(984*p4.photoRatio)/3.937*2/2;
        surface.setResizable(true);
        surface.setSize(620, 720);
        redraw();
        surface.setResizable(false);

        int buttonWidth = 80, buttonHeight = 50, tSize=14;
        backButton = new Button(int((float)width*.9), int((float)height*.9), buttonWidth, buttonHeight, "BACK", tSize);
        printButton = new Button(int((float)width*.9), int((float)height*.8), buttonWidth, buttonHeight, "PRINT", tSize);
        output = createWriter("positions.txt");
    }

    void draw(){
        drawGrid();
        drawPhoto();
        backButton.display();
        printButton.display();

        textAlign(LEFT);
        textSize(12);
        fill(#009900);
        text("Drag the mouse to move and zoom, use R or r to rotate", 0, 24);


    }

    public void mousePressed(){
        locked = true;
        xOffset = mouseX-moveX;
        yOffset = mouseY-moveY;

        if (printButton.mousePressed()){println("photo ready to print");outputGcode();pages=99;p99.setup();}
        if (backButton.mousePressed()){pages = 0;p0.fileSelected = false; p0.firstRun = false;}
    }

    public void mouseDragged(){
        if (locked) {
            moveX = mouseX - xOffset;
            moveY = mouseY-yOffset;
        }
    }

    public void mouseReleased(){
        locked = false;

    }

    public void mouseWheel(MouseEvent event){
        float e = event.getCount();
        zoom*=1+0.05*e;
    }

    public void keyPressed(){
        if (key == 'R' || key =='r')
        angle = (angle>=3)?0: angle+1;
        if (keyCode == ENTER){println("photo ready to print");outputGcode();p99.setup();pages=99;}
    }

    void drawPhoto(){
        pushMatrix();

        translate(viewcenterX, viewcenterY);
        translate(moveX,moveY);
        rotate(PI/2*angle);
        scale(zoom);
        translate(-viewcenterX, -viewcenterY);

        for (int i = 0; i<=3; i++) {
            for (Contour contour : displayContours.get(i)) {
                noFill();
                strokeWeight(0.5/zoom);
                stroke(#500000);
                beginShape();
                for (PVector point : contour.getPoints())
                vertex(point.x/3.937*2, point.y/3.937*2);
                endShape();
            }
        }

        popMatrix();
    }

    void outputGcode(){
        boolean posMoved = false;
        drawPhoto();

        //output.println("$X");
        p3.machineGcodeSetting(output);

        for (int i = 0; i<=3; i++) {
            for (Contour contour : displayContours.get(i)) {

                for (PVector point : contour.getPoints()){
                    PVector realP = point;
                    realP.mult(1./3.937 * 2.);

                    realP.add(new PVector(-viewcenterX, -viewcenterY));
                    realP.mult(zoom);
                    realP.rotate(PI/2*angle);
                    realP.add(new PVector(moveX, moveY));
                    realP.add(new PVector(viewcenterX, viewcenterY));

                    if (posMoved == false) {
                        output.println("G1 " + "X"+ nf(realP.x/2,0,2) + " Y" + nf(realP.y/2,0,2)+ " F"+p3.feedRate+"\nM03 S"+p3.penDown+"\nG4 P0.3");
                        posMoved = true;
                    }
                    else output.println("X"+ nf(realP.x/2,0,2) + " Y" + nf(realP.y/2,0,2));
                }
                output.println("M03 S"+p3.penUp+"\nG4 P0.3");
                posMoved = false;
            }
        }
        output.println("G0 X0 Y0");
        output.flush();
        output.close();
        if (debug) println("ready to draw");
    }
}
