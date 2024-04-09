SndBuf sound => Pan2 pan => dac;

me.dir()+"assets/Acoustic_Closed_Hat_08.wav" => sound.read;

while(true)
{
    // Math.random2f(0.1,1.0) => sound.gain;
    1.0 => sound.gain;
    // Math.random2f(0.1,1.0) => pan.pan;
    Math.random2f(0.2, 1.8) => sound.rate;
    // sound.play();
    0 => sound.pos;
    500.0 :: ms => now;
}