SndBuf kick => Gain main => dac;
SndBuf snare => main;
SndBuf hat => main;
SndBuf cowbell => main;
SndBuf ride => main;
SndBuf tom => main;

me.dir()+ "assets/Acoustic_Closed_Hat_08.wav" => hat.read;
me.dir()+ "assets/Acoustic_Kick_08.wav" => kick.read;
me.dir()+ "assets/Acoustic_Snare_01.wav" => snare.read;
me.dir()+ "assets/Acoustic_Cowbell_01.wav" => cowbell.read;
me.dir()+ "assets/Acoustic_Ride_Short_02.wav" => ride.read;
me.dir()+ "assets/Acoustic_Low_Tom_01.wav" => tom.read;

500.0 :: ms => dur tempo;
// 0.0 => main.gain;

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

0 => int beat;
while(true)
{
    // Math.random2f(0.1,1.0) => sound.gain;
    // 1.0 => sound.gain;
    // Math.random2f(0.1,1.0) => pan.pan;
    // Math.random2f(0.2, 1.8) => sound.rate;
    // sound.play();
    0 => index_to_sound(beat % 6).pos;
    beat++;
    tempo => now;
}