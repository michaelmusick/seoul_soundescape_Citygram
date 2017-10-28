/*
Wind chimes,


*/

(
SynthDef(\windchime, {
    arg out = 0, freq = 220, sustain = 4, init_rate = 20,
	atk = 0.001, sus = 0.6, rel = 0.2, pan = 0, hardLev = 2;

    var amps = [ 0.1, 0.2, 0.3, 0.17 ];
    var rings = [ 15, 17, 10, 5 ];
    var harmonics = freq * [ 1, 2.7086330935, 5.1834532374, 8.3237410072 ];

    var env, impulse, sig, sig_h, sig_l, rate, mix_sig;


    env = EnvGen.kr(
        Env.linen(atk, sus, rel, 1, -4),
		timeScale: sustain
    );

	rate = XLine.kr(init_rate, 0.01, sustain);

	impulse = Impulse.ar(0.1);
	impulse = Decay.ar(
        impulse,
        0.03,
        ClipNoise.ar(0.01)
    );


	impulse = CombC.ar(
		impulse,
		harmonics[0].reciprocal,
		harmonics[0].reciprocal,
		0.01
	);
	impulse = RLPF.ar( impulse, harmonics[3]*4, 0.99 );
	impulse = impulse * env;

	env = EnvGen.kr(
        Env.linen(atk, sus, rel, 1, -4),
		timeScale: sustain*2,
		doneAction: 2
    );
    sig = Klank.ar(
        // specs
        `[harmonics, amps, rings],
        // input
        impulse
    );

	mix_sig = SinOsc.kr( rate.linlin(init_rate, 0.01, 0.5, 0) );
	sig_l = LPF.ar( sig, harmonics[3] );
	sig_l = sig_l * mix_sig.linlin(-1,1, 0,0.8);
	sig_h = RHPF.ar( sig, harmonics[2], 0.2 );
	sig_h = sig_h * mix_sig.linlin(-1,1,0.5,0);
	sig = Mix( [ sig_l, sig_h ] );
	sig = sig * env * hardLev;
	sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;
);



(
Pdef(\windchimes,
	Pbind(
		\instrument, \windchime,
		\root, 0,
		\octave, 3,
		\degree, Pdef(\scale),
		\freq, Pfunc { |ev| ev.use(ev[\freq]) },
		\dur, Pdef(\chimePatterns),
		\init_rate, Pwhite(0.01, 4, inf),
		\sustain, 3,
		\db, Pdef(\midChime_db),
		\amp, Pfunc { |ev| ev.use(ev[\amp]) },
		\type, Pfuncn({
			|event|
			if( (
				(s.peakCPU < ~main.maxPeakCPU) &&
				(s.avgCPU < ~main.maxAvgCPU)
			),
			{
				\note
			}, {
				\rest
			});
		}, inf),
		\out, ~main.posBus,
		// \blah, Pfuncn({ |ev| ev.postln; }, inf)


	)
);
);
