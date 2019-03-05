class welcomePage {
  Button startButton, settingButton, liveCamButton;
  int buttonWidth = 150, buttonHeight = 50, tSize = 14;

  boolean fileSelected = false, firstRun = false;
  welcomePage() {
  }

  void setup() {

    startButton = new Button(width/2, int((float)height*.7), buttonWidth, buttonHeight, "START", tSize);
    liveCamButton = new Button(width/2, int((float)height*.8), buttonWidth, buttonHeight, "LIVE CAM", tSize);
    settingButton = new Button(width/2, int((float)height*.9), buttonWidth, buttonHeight, "SETTING", tSize);

  }

  void draw() {
    drawGrid();

    fill(#000000);
    textAlign(CENTER, CENTER);
    textSize(52);
    text("DRAWING & PHOTO \nsender and maker \n FOR GRBL \n DRAWING MACHINE", width/2, height/3);

    buttonWidth = 150;
    buttonHeight = 50;
    tSize = 14;
    startButton.display();
    if (startButton.overRect()) {
      fill(#FF0000);
      textAlign(LEFT, LEFT);
      textSize(12);
      text("file support .dxf, .svg., jpg, .png", mouseX, mouseY);
    }
    liveCamButton.display();
    settingButton.display();
  }

  public void mousePressed() {
    if (startButton.mousePressed()) {
      if (!fileSelected) {
        if (!firstRun) {
          selectInput("Select a file to process:", "FileSelected");
          firstRun = true;
        }
      }
    }

    if(liveCamButton.mousePressed()){
        if (!firstRun) {
            pages=4;
            p4.setup();
            firstRun = true;
        }
    }

    if (settingButton.mousePressed()){
        pages = 3;
        p3.setup();
    }
  }
}
