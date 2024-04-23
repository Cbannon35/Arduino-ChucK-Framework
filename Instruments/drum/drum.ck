SndBuf kick => Gain master => dac;
SndBuf snare => master;
SndBuf hat => master;
SndBuf cowbell => master;
SndBuf ride => master;
SndBuf tom => master;

me.dir()+ "assets/Acoustic_Closed_Hat_08.wav" => hat.read;
me.dir()+ "assets/Acoustic_Kick_08.wav" => kick.read;
me.dir()+ "assets/Acoustic_Snare_01.wav" => snare.read;
me.dir()+ "assets/Acoustic_Cowbell_01.wav" => cowbell.read;
me.dir()+ "assets/Acoustic_Ride_Short_02.wav" => ride.read;
me.dir()+ "assets/Acoustic_Low_Tom_01.wav" => tom.read;

500.0 :: ms => dur tempo;
0.0 => master.gain;
6 => int numPins;
20 => int historyLength;
int baseVals[numPins];
int pinHistory[numPins][historyLength];

40 => int triggerThresh;
300.0 => float range;

fun SndBuf index_to_sound(int index)
{
    if(index == 0) return kick;
    else if(index == 1) return snare;
    else if(index == 2) return hat;
    else if(index == 3) return cowbell;
    else if(index == 4) return ride;
    else if (index == 5) return tom;
    else return kick;
}

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
            // Is ON!
            chout <= "ON: " <= i <= " " <= diff <= IO.newline();
            if (state[i] == 0) {
                0 => index_to_sound(i).pos;
                1 => state[i];
            }
        } else {
            0 => state[i];
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
    0.5 => master.gain;
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