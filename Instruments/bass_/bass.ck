// BEGIN BASS STUFF
StifKarp inst => dac;
[0, 3, 4, 1, 5, 4, 3, 3] @=> int bass[];
// END BASS STUFF

// 500.0 :: ms => dur tempo;
6 => int numPins;
20 => int historyLength;
int baseVals[numPins];
int pinHistory[numPins][historyLength];
20 => int triggerThresh;
300.0 => float range;

fun SerialIO setup()
{
    SerialIO.list() @=> string list[];
    (me.args() ? me.arg(0) => Std.atoi : 0) => int device;

    if(device >= list.cap()) 
    {
        chout <= "serial device #" <= device <= " not available\n";
        me.exit(); 
    }

    SerialIO serial;
    if(!serial.open(device, SerialIO.B9600, SerialIO.ASCII)) 
    {
        chout <= "unable to open serial device '" <= list[device] <= "'\n";
        me.exit();
    }
    
    return serial;
}

/* @CITATION:
 * https://github.com/bonniee/illumaphone/blob/master/cuppy.ck
 */
fun void calibrate(SerialIO s) {

    20 => int numLaps;
    5 => int throwAways;
    20 => int historyLength;

    for (0 => int i; i < throwAways; i++) {
        s.onLine() => now;
        s.getLine() => string line;
    }
    5::ms => now;

    for (0 => int lap; lap < numLaps; lap++) {
        s.onLine() => now;
        s.getLine() => string line;
        if(line$Object != null) {
            StringTokenizer tok;
            tok.set(line);

            for (0 => int i; i < numPins; i++) {
                // Fill history with default values
                Std.atoi(tok.next()) => int pinVal;

                for (0 => int j; j < historyLength; j++) {
                    pinVal => pinHistory[i][j];
                }
                // Store a 1D base vals array, too.
                pinVal + baseVals[i] => baseVals[i];

            }

        }
    }
    for (0 => int i; i < numPins; i++) {
        <<< baseVals[i] >>>;
        baseVals[i] / numLaps => baseVals[i];
        <<< baseVals[i] >>>;
        <<< "=======" >>>;
    }
    <<< "DONE CALIBRATING" >>>;

}

0 => int bufferIndex;
int state[numPins];
for (0 => int i; i < numPins; i++) 
{
    0 => state[i];
}
fun void processLine(StringTokenizer tok) {
    for (0 => int i; i < numPins; i++) {
        Std.atoi(tok.next()) => int newVal;
        newVal => pinHistory[i][bufferIndex];
        
        int oldVal;
        if (bufferIndex == 0) {
            pinHistory[i][historyLength - 1] => oldVal;
        }
        else {
            pinHistory[i][bufferIndex - 1] => oldVal;
        }
        
        Std.abs(newVal - baseVals[i]) => int diff;


        if (diff >= triggerThresh) {
            chout <= "ON: " <= i <= " " <= diff <= IO.newline();
            bass[i] => int note;
            Std.mtof( 3*12 + 7 + note ) => inst.freq; //7 semitones from C is G
            if (state[i] == 0) {
                inst.noteOn( 0.7 ); //play a note
                // inst.sustain(1.0);
            }
            1 => state[i];
        } else {
            0 => state[i];
            // inst.noteOff ( 0.0 );
        }
    } 
            
    // Advance buffer index
    bufferIndex + 1 => bufferIndex;
    if (bufferIndex >= historyLength) {
        0 => bufferIndex;
    }
    
}

fun void main(SerialIO s)
{
    while(true)
    {
        s.onLine() => now;
        s.getLine() => string line;
        if(line$Object != null)
        {
            chout <= "raw: " <= line <= IO.newline();
            StringTokenizer tok;
            tok.set(line);
            processLine(tok);
        }
    }
}

setup() @=> SerialIO serial;
calibrate(serial);
main(serial);