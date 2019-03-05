class SerialStreamingPage {
    int BUFFER_SIZE = 128;
    long lineCount=-1;                   //hold the counter of GCODE file send to machine
    long okFeedBack =-1;                 //how many ok is feedback to system
    long errorFeedBack = 0;
    String[] gcodes;
    boolean streaming = false;
    boolean waiting = false;
    IntList charCounter = new IntList();    //mark down the char number in each gcodes lines

    int RX_BUFFER_SIZE = 127;
    int RX_BUFFER_CODE = 15;


    SerialStreamingPage() {
    }

    void setup() {
        long timer;
        noLoop();
        gcodes = loadStrings("positions.txt");
        if (gcodes != null) {
            streaming = true;
            myPort.clear();
            for (int i=0; i<=14; i++) toSerialOutput(i);    //first 15 rows is machine setting, such take some time to send
            while(okFeedBack+errorFeedBack<14) mySerialEvent(myPort);
            
            println("ready to streaming");
            timer = millis();
            for (int lineCount=14; lineCount<gcodes.length -1; lineCount++){
                String grblOut=gcodes[lineCount];
                charCounter.append(grblOut.length()+1); //do forget the '\n'
                waiting = true;
                while (sum(charCounter) >= RX_BUFFER_SIZE || charCounter.size() >=RX_BUFFER_CODE){
                    mySerialEvent(myPort);
                    if (!waiting) {charCounter.remove(0); break;}
                }
                toSerialOutput(lineCount);
            }
            while(lineCount > okFeedBack+errorFeedBack) {
               mySerialEvent(myPort);
            }

            println("print end. Used:"+(millis()-timer)/1000.+"seconds");
        }
    }




    void draw() {}


    void mySerialEvent(Serial p) {
        if (p.available() > 0) {
            String myString = p.readStringUntil('\n');
            if (myString != null) {
                myString = trim(myString);
                if (!myString.contains("ok"))println(myString);

                if (streaming) {
                    if (myString.contains("ok")) {
                        okFeedBack++;
                        waiting = false;
                    }
                    else if (myString.contains("error")) {
                        errorFeedBack++;
                        waiting = false;
                    }
                }
            }
        }
    }


    void toSerialOutput(int _line) {
        String displayText = "";
        if (gcodes != null) displayText = nf(float(_line)/float(gcodes.length-1)*100, 0, 4) + '%'+ ' '+ ':'+gcodes[_line];
        println(displayText);
        myPort.write(gcodes[_line]+'\n');
    }

    int sum(IntList _list){
        int value=0;
        for (int i=0; i<_list.size(); i++)
        value += _list.get(i);
        return value;
    }
}
