class Button{
    float xpos, ypos, bWidth, bHeight;
    String label;
    int tSize;
    boolean isChecked = false;
    boolean selfLock = false;

    Button (float x, float y, float bW, float bH, String l){
        xpos = x;
        ypos = y;
        bWidth = bW;
        bHeight = bH;
        label = l;
        tSize = 12;
    }
    Button (float x, float y, float bW, float bH, String l, int tS){
        xpos = x;
        ypos = y;
        bWidth = bW;
        bHeight = bH;
        label = l;
        tSize = tS;
    }

    Button (float x, float y, float bW, float bH, String l, int tS, boolean _selfLock){
        xpos = x;
        ypos = y;
        bWidth = bW;
        bHeight = bH;
        label = l;
        tSize = tS;
        selfLock = _selfLock;
    }

    public boolean mousePressed(){
        boolean isOverRect = overRect();
        if (isOverRect) {
            if (selfLock) isChecked = !isChecked;
        }
        return isOverRect;
    }

    void display(){
        rectMode(CENTER);
        strokeWeight(6);
        stroke(isChecked? #000000 : #89A3FF);
        fill(overRect()?#D6CF49:#FFFCA7);
        rect(xpos, ypos, bWidth, bHeight, 0, 10, 0, 10);
        fill(0);
        textSize(tSize);
        textAlign(CENTER, CENTER);
        text(label, xpos, ypos);
    }

    boolean overRect() {
        if (mouseX >= xpos-bWidth/2 && mouseX <= xpos+bWidth/2
            && mouseY >= ypos-bHeight/2 && mouseY <= ypos+bHeight/2) return true;
        else return false;
    }

}
