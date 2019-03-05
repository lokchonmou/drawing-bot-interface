class settingPage{
    int penUp = 190, penDown = 160, feedRate=8000;
    boolean invert_x=false, invert_y=false;
    PrintWriter conf;
    String[] setting;
    Button penUpPlus, penUpMinus, penDownPlus, penDownMinus,
    feedRatePlus, feedRateMinus,invertXButton, invertYButton,
    setZeroButton, goZeroButton, backButton;
    Button UPButton, DOWNButton, LEFTButton, RIGHTButton;

    settingPage(){}

    void setup(){
        drawGrid();

        setting = loadStrings("configuration.txt");
        penUp = int(setting[0]);
        penDown = int(setting[1]);
        feedRate = int(setting[2]);
        invert_x = boolean(setting[3]);
        invert_y = boolean(setting[4]);

        int buttonWidth = 80, buttonHeight = 50, tSize=18;
        penUpPlus = new Button(int((float)width*.5), int((float)height*.1), buttonWidth, buttonHeight, "+", tSize);
        penDownPlus = new Button(int((float)width*.5), int((float)height*.2), buttonWidth, buttonHeight, "+", tSize);
        feedRatePlus = new Button(int((float)width*.5), int((float)height*.3), buttonWidth, buttonHeight, "+", tSize);

        penUpMinus = new Button(int((float)width*.7), int((float)height*.1), buttonWidth, buttonHeight, "-", tSize);
        penDownMinus = new Button(int((float)width*.7), int((float)height*.2), buttonWidth, buttonHeight, "-", tSize);
        feedRateMinus = new Button(int((float)width*.7), int((float)height*.3), buttonWidth, buttonHeight, "-", tSize);

        setZeroButton = new Button(int((float)width*.8), int((float)height*.5), buttonWidth, buttonHeight, "SET\nZERO", 14);
        goZeroButton = new Button(int((float)width*.8), int((float)height*.6), buttonWidth, buttonHeight, "GO\nZERO", 14);
        backButton = new Button(int((float)width*.9), int((float)height*.9), buttonWidth, buttonHeight, "BACK", tSize);

        buttonWidth = 50; tSize = 12;
        invertXButton = new Button(int((float)width*.3), int((float)height*.5), buttonWidth, buttonHeight, "", tSize, true);
        invertYButton = new Button(int((float)width*.3), int((float)height*.6), buttonWidth, buttonHeight, "", tSize, true);

        LEFTButton = new Button(int((float)width*.4), int((float)height*.8), buttonWidth, buttonHeight, "LEFT", tSize);
        RIGHTButton = new Button(int((float)width*.6), int((float)height*.8), buttonWidth, buttonHeight, "RIGHT", tSize);
        UPButton = new Button(int((float)width*.5), int((float)height*.7), buttonWidth, buttonHeight, "UP", tSize);
        DOWNButton  = new Button(int((float)width*.5), int((float)height*.8), buttonWidth, buttonHeight, "DOWN", tSize);
    }

    void draw(){
        drawGrid();

        textSize(18);
        textAlign(CENTER, CENTER);
        fill(0);
        text("pen up\n"+penUp, int((float)width*.3), (float)height*.1);
        text("pen down\n"+penDown, int((float)width*.3), (float)height*.2);
        text("feed rate\n"+feedRate, int((float)width*.3), (float)height*.3);
        text("Invert X axis", int((float)width*.45), (float)height*.5);
        text("Invert Y axis", int((float)width*.45), (float)height*.6);

        penUpPlus.display();
        penDownPlus.display();
        feedRatePlus.display();

        penUpMinus.display();
        penDownMinus.display();
        feedRateMinus.display();

        invertXButton.isChecked = invert_x;
        invertYButton.isChecked = invert_y;
        invertXButton.display();
        invertYButton.display();

        setZeroButton.display();
        goZeroButton.display();
        backButton.display();

        UPButton.display();
        DOWNButton.display();
        LEFTButton.display();
        RIGHTButton.display();
    }

    public void mousePressed() {
        if(penUpPlus.mousePressed())    { penUp+=3;penUp = constrain(penUp, 0, 255);myPort.write("M03 S"+ penUp +'\n');if(debug)println("M03 S"+ penUp +'\n');}
        if(penUpMinus.mousePressed())   { penUp-=3;penUp = constrain(penUp, 0, 255);myPort.write("M03 S"+ penUp +'\n');if(debug)println("M03 S"+ penUp +'\n');}

        if(penDownPlus.mousePressed())  { penDown+=3;penDown = constrain(penDown, 0, 255);myPort.write("M03 S"+ penDown +'\n');if(debug)println("M03 S"+ penDown +'\n');}
        if(penDownMinus.mousePressed()) { penDown-=3;penDown = constrain(penDown, 0, 255);myPort.write("M03 S"+ penDown +'\n');if(debug)println("M03 S"+ penDown +'\n');}

        if(feedRatePlus.mousePressed()) {feedRate+=200;feedRate = constrain(feedRate,0,10000);if(debug)println("feedRate="+feedRate);}
        if(feedRateMinus.mousePressed()){feedRate-=200;feedRate = constrain(feedRate,0,10000);if(debug)println("feedRate="+feedRate);}

        if(invertXButton.mousePressed()){invert_x = !invert_x;if (!invert_x && !invert_y) myPort.write("$3 = " + 0 + '\n');if (!invert_x && invert_y) myPort.write("$3 = " + 2+ '\n');if (invert_x && !invert_y) myPort.write("$3 = " + 1+ '\n');if (invert_x && invert_y) myPort.write("$3 = " + 3+ '\n');}
        if(invertYButton.mousePressed()){invert_y= !invert_y;if (!invert_x && !invert_y) myPort.write("$3 = " + 0 + '\n');if (!invert_x && invert_y) myPort.write("$3 = " + 2+ '\n');if (invert_x && !invert_y) myPort.write("$3 = " + 1+ '\n');if (invert_x && invert_y) myPort.write("$3 = " + 3+ '\n');}

        if(setZeroButton.mousePressed()){myPort.write("G92 X0 Y0 Z0"+ '\n');if(debug)println("G92 X0 Y0 Z0"+ '\n');}

        if(goZeroButton.mousePressed()) {myPort.write("G0 X0 Y0 Z0"+'\n');if(debug)println("G0 X0 Y0 Z0"+'\n');}

        if(backButton.mousePressed()){conf = createWriter("configuration.txt");conf.println(penUp);conf.println(penDown);conf.println(feedRate);conf.println(invert_x);conf.println(invert_y);conf.flush();conf.close();pages = 0;if(debug)println("SAVED");}

        if(UPButton.mousePressed()){myPort.write("G91 \n G0 Y10 \n G90 \n");if(debug)println("G91 \n G0 Y10 \n G90 \n");}
        if(DOWNButton.mousePressed()){myPort.write("G91 \n G0 Y-10 \n G90 \n");if(debug)println("G91 \n G0 Y-10 \n G90 \n");}
        if(LEFTButton.mousePressed()){myPort.write("G91 \n G0 X-10 \n G90 \n");if(debug)println("G91 \n G0 X-10 \n G90 \n");}
        if(RIGHTButton.mousePressed()){myPort.write("G91 \n G0 X10 \n G90 \n");if(debug)println("G91 \n G0 X10 \n G90 \n");}
    }

    public void keyPressed(){
        if (key == CODED){
            if (keyCode == UP){myPort.write("G91 \n G0 Y10 \n G90 \n");if(debug)println("G91 \n G0 Y10 \n G90 \n");}
            if (keyCode == DOWN){myPort.write("G91 \n G0 Y-10 \n G90 \n");if(debug)println("G91 \n G0 Y-10 \n G90 \n");}
            if (keyCode == LEFT){myPort.write("G91 \n G0 X-10 \n G90 \n");if(debug)println("G91 \n G0 X-10 \n G90 \n");}
            if (keyCode == RIGHT){myPort.write("G91 \n G0 X10 \n G90 \n");if(debug)println("G91 \n G0 X10 \n G90 \n");}
        }
    }

    void machineGcodeSetting(PrintWriter _output){
        _output.println("G90");
        _output.println("$30=255");
        _output.println("$32=0");
        _output.println("$31=0");
        _output.println("$100=78.74");
        _output.println("$101=78.74");
        _output.println("$102=78.74");
        _output.println("$110=8000");
        _output.println("$111=8000");
        _output.println("$112=3000");
        _output.println("$120=500");
        _output.println("$121=500");
        _output.println("G92 X0 Y0");
        _output.println("M03 S"+p3.penUp);
        _output.println("G4 P0.3");
    }

}
