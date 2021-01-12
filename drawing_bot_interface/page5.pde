class photoPage{

    int[] limit= new int[3];
    PImage src, temp;
    PrintWriter output;
    float photoRatio;
    int counter;
    ArrayList<ArrayList<Contour>> contours = new ArrayList<ArrayList<Contour>>();

    boolean photoSelected, posMoved;

    int buttonWidth = 150, buttonHeight = 50, tSize = 14;
    Button backButton;

    photoPage(){}

    void setup(){
        for (int i=0; i < 4; i++) contours.add(new ArrayList<Contour>());
        output = createWriter("positions.txt");
        backButton = new Button(int((float)width*.9), int((float)height*.9), buttonWidth, buttonHeight,"BACK",tSize);
    }

    void draw(){
        if (photoSelected){
            if (counter <=2){
                int max = (int)map(mouseX, 0, width, 0, 255);
                limit[0]=max*3/4;
                limit[1]=max/2;
                limit[2]=max/4;
                drawh();
                backButton.display();
            }
            else if (counter == 3){
                draw_shadow();
                screen_output();
                backButton.display();
            }
        }

    }

    public void mousePressed(){
        if (counter <= 2){
            if(backButton.mousePressed()){
                pages = 0;
                photoSelected = false;
                p0.firstRun = false;
                p0.fileSelected = false;
                surface.setResizable(true);
                surface.setSize(620, 720);
                redraw();
                surface.setResizable(false);
                contours.clear();
                p0.setup();
            }
        }
        else if (counter == 3){
            if(backButton.mousePressed()) counter = (counter<3)?counter+1:0;
        }
    }

    public void keyPressed(){
        if (key == ' ') counter = (counter<3)?counter+1:0;
        if (key == ENTER){pages = 6; p6.setup();}
    }

    void drawh() {
        opencv.loadImage(src);
        opencv.useColor(HSB);
        opencv.setGray(opencv.getB().clone());
        opencv.threshold(limit[counter]);
        image(opencv.getOutput(), 0, 0, width, height);
        histogram = opencv.findHistogram(opencv.getB(), 255);

        stroke(#00FF00);
        strokeWeight(.5);
        histogram.draw(0, height -230, width, 200);
        fill(#FF0000);
        stroke(#FF0000);
        line(0, height-30, width, height-30);
        text("Brightness", 0, height - (textAscent() + textDescent()));

        float ll = map(limit[0], 0, 255, 0, width);
        float lsl = map(limit[1], 0, 255, 0, width);
        float ul = map(limit[2], 0, 255, 0, width);

        stroke(255, 0, 0);
        fill(255, 0, 0);
        strokeWeight(2);

        ellipse(ll, height-30, 3, 3 );
        text(limit[0], ll-10, height-15);
        ellipse(lsl, height-30, 3, 3 );
        text(limit[1], lsl+10, height-15);
        ellipse(ul, height-30, 3, 3 );
        text(limit[2], ul+10, height-15);
        textSize(12);
        text("Move mouseX to adjust, press SPACEBAR 3 times to comfrim", width/2, 16);
    }

    void draw_shadow() {
        noFill();

        for (int i=0; i<=2; i++) {
            opencv.loadImage(src);
            opencv.useColor(HSB);

            opencv.setGray(opencv.getB().clone());
            opencv.threshold(limit[i]);
            background(#FFFFFF);
            image(opencv.getOutput(), 0, 0, width, height);

            stroke(#FFFFFF);
            strokeWeight(2);
            if (i ==0){
                for (int j=0; j <=width*2; j+=5)
                line(j, 0, 0, j);
                save("limit_1.bmp");
            }
            if (i ==1){
                for (int j=0; j <=width; j+=5) {
                    line(j, 0, width, width-j);
                    line(0, j, width-j, width);
                }
                save("limit_2.bmp");
            }
            if (i ==2) {
                strokeWeight(2.5);
                for (int j=0; j <=width; j+=4)
                line(0, j, width, j);
                save("limit_3.bmp");
            }
        }
    }

    void screen_output() {
        background(#FFFFFF);

        for (int i = 0; i<=3; i++) {
            if (i==0) temp= loadImage("limit_1.bmp");
            else if (i==1) temp = loadImage("limit_2.bmp");
            else if (i==2) temp = loadImage("limit_3.bmp");

            if (i==3){
                opencv.loadImage(src);
                opencv.findCannyEdges(mouseX, mouseY);
            }
            else{
                temp.resize(width, height);
                opencv.loadImage(temp);
                opencv.threshold(200);
                opencv.getOutput();
            }

            contours.set(i, opencv.findContours());
            for (Contour contour : contours.get(i)) {
                noFill();
                strokeWeight(0.5);
                stroke(#000000);
                beginShape();
                int limitArea = (i<=2)?10:0;
                if (contour.area() > limitArea) {
                    for (PVector point : contour.getPoints()) {
                        vertex(point.x, point.y);
                    }
                    endShape();
                }
            }
        }

        fill(#FF0000);
        textAlign(CENTER);
        textSize(12);
        text("move mouseX and mouseY to adjust, press ENTER to draw \n Press SPACEBAR to go back", width/2, 16);
        //image(logo_show, 0, 0, 74*5, 23*5);
        image(src, width-200, 0, 200, int(200*photoRatio));
    }

}
