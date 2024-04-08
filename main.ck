/* Analog Ranges */
940 => int lightLowerBound; // iphone flashlight directly on sensor
1021 => int lightUpperBound; // hand covering sensor
25 => int lightThreshold; // 940 + 25 = play note
14 => int buttonBound;

6 => int numPins; // number of analog pins on the arduino uno
100 => int maxVolume; //integers for mapping purposes... 
0 => int minVolume; 

[60, 62, 64, 65, 67, 69, 71] @=> int baseNotes[]; // C, D, E, F, G, A, B

fun int[] getNoteAndVolume(int sensor, int sensorVal) {
    if (sensorVal >= 1022) 
    {
        return [-1, -1]; /* Pullup pin val + noise */
    }

    /* If button press */
    if (sensorVal <= buttonBound + 1 && sensorVal >= buttonBound -1) 
    {
        return [baseNotes[sensor], maxVolume];
    }

    /* If it is a light sensor */
    if (sensorVal <= lightUpperBound && sensorVal >= lightLowerBound) 
    {
        /* If hand is covering sensor */
        if (sensorVal > lightLowerBound + lightThreshold) 
        {
            return [baseNotes[sensor], map(sensorVal, lightLowerBound + lightThreshold, lightUpperBound, minVolume, maxVolume)];
        }
        else 
        {
            return [-1, -1];
        }
    }

    return [-1, -1];
}

fun int map(int value, int fromLow, int fromHigh, int toLow, int toHigh) 
{ 
    if (value <= fromLow) 
    {
        return toLow;
    }
    if (value >= fromHigh) 
    {
        return toHigh;
    }
    return (value - fromLow) * (toHigh - toLow) / (fromHigh - fromLow) + toLow;
}

fun int handleMotion(int motionVal) 
{
    return map(motionVal, 0, 5, -2, 2);
}

SinOsc s[numPins];
for (0 => int i; i < numPins; i++) 
{
    s[i] => dac;
    s[i].gain(0);
}

fun void play(StringTokenizer t) 
{
    Std.atoi(t.next()) => int motionVal; // digital read special case, always sent first int this context. Val 0-40
    for (0 => int i; i < numPins; i++) 
    {
        Std.atoi(t.next()) => int sensorVal;
        getNoteAndVolume(i, sensorVal) @=> int noteAndVolume[];
        noteAndVolume[0] => int note;
        noteAndVolume[1] => int volume;
        if (note == -1) 
        { 
            0.0 => s[i].freq;
            0.0 => s[i].gain;
            continue;
        }
        chout<= handleMotion(motionVal) <= IO.newline();
        note + (12 * handleMotion(motionVal)) => int newNote; // map it to a new octave
        Std.mtof( newNote ) => s[i].freq;
        volume / 100.0 => s[i].gain;
        chout <= "note: " <= newNote <= " volume: " <= volume <= IO.newline();
        1::ms => now;
    }
}

fun SerialIO setup()
{
    SerialIO.list() @=> string list[];
    (me.args() ? me.arg(0) => Std.atoi : 0) => int device;

    if(device >= list.cap()) 
    {
        cherr <= "serial device #" <= device <= " not available\n";
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
            play(tok);
        }
    }
}

setup() @=> SerialIO serial;
main(serial);