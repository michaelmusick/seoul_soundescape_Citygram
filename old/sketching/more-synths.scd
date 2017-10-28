s.makeWindow

(
{
var delay1, delay2, source;

//k from -1 to 1
	//
//in samples
delay1= 100;
delay2= 40;

source= SinOsc.ar(200, mul: 0.5)*EnvGen.ar(Env([1,1,0],[(delay1+delay2)/SampleRate.ir,0.0]), Impulse.kr(MouseY.kr(1,4)));

TwoTube.ar(source,MouseX.kr(-1,1),0.99,delay1,delay2);
}.play

)



(
SynthDef("windchime", {
    arg out = 0, freq = 220, length = 4, i_rate = 20,
	atk = 0.001, sus = 0.6, rel = 0.2, pan = 0;

    var amps = [ 0.1, 0.2, 0.3, 0.17 ];
    var rings = [ 15, 17, 10, 5 ];
    var harmonics = freq * [ 1, 2.7086330935, 5.1834532374, 8.3237410072 ];

    var env, impulse, sig;


    env = EnvGen.kr(
        Env.linen(atk, sus, rel, 1, -4),
		timeScale: length
    );

	impulse = Decay.ar(
        Dust.ar(XLine.kr(i_rate, 0.01, length)),
        0.03,
        ClipNoise.ar(0.01)
    );
	impulse = impulse * env;

	env = EnvGen.kr(
        Env.linen(atk, sus, rel, 1, -4),
		timeScale: length*2,
		doneAction: 2
    );
    sig = Klank.ar(
        // specs
        `[harmonics, amps, rings],
        // input
        impulse
    );
	sig = sig * env;
	sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;
)

~freq = 200;
(
r = Routine{
    var sustain = 8, transition = 3, overlap = 4;
    var period = transition * 2 + sustain / overlap;


    inf.do{
		// var freqArr =  [1, 2.68, 5.11, 8.11]*~freq ;
        Synth("windchime", [

            \pan, 1.0.rand2,
            \freqs, rrand(200, 800),
        ]);
        period.wait;
    }
};
r.play;
)
s.plotTree
r.stop;    // stop spawning new synths

s.meter
