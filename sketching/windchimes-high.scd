/*
Wind chimes,


*/

(
SynthDef(\windchime_high, {
    arg out = 0, freq = 220, sustain = 4, init_rate = 20,
	atk = 0.001, sus = 0.6, rel = 0.2, pan = 0, amp = -6.dbamp;

    var amps = [ 0.1, 0.2, 0.3, 0.17 ];
    var rings = [ 15, 17, 10, 5 ];
    var harmonics = freq * [ 1, 2.70863, 5.18345, 8.32374 ];

    var env, impulse, sig, sig_h, sig_l, rate, mix_sig;


    env = EnvGen.kr(
        Env.linen(atk, sus, rel, 1, -4),
		timeScale: sustain
    );

	rate = XLine.kr(init_rate, 0.01, sustain);
	impulse = Decay.ar(
        Dust.ar(rate),
        0.03,
        ClipNoise.ar(0.01)
    );

	impulse = impulse * env;

	env = EnvGen.kr(
        Env.linen(atk, sus, rel, 1, -4),
		timeScale: sustain*2,
		levelScale: amp,
		doneAction: 2
    );
    sig = Klank.ar(
        // specs
        `[harmonics, amps, rings],
        // input
        impulse
    );

	mix_sig = SinOsc.kr( rate.linlin(init_rate, 0.01, init_rate, 0) );
	sig_l = LPF.ar( sig, harmonics[3] );
	sig_l = sig_l * mix_sig.linlin(-1,1, 0,0.7);
	sig_h = RHPF.ar( sig, harmonics[2], 0.2 );
	sig_h = sig_h * mix_sig.linlin(-1,1,0.9,0);
	sig = Mix( [ sig_l, sig_h ] );
	sig = sig * env;
	sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;
)



(
Pdef(\windchimes_high,
	Pbind(
		\instrument, \windchime_high,
		\root, 0,
		\octave, Pwhite(6, 7, inf),
		\degree, Prand([0,3,4,5,7], inf),

		\dur, Pwalk([
			Pseq([1,1,1,1]*0.25, 1),
			Pseq([1,1,0.5,0.25,0.25,1]*0.25, 1),
			Pseq([1,1,2,0.125,0.125,0.25,0.125,0.25,0.125,0.5]*0.25, 1),
			Pseq([1,1,1,1]*0.125, 2),
			Pseq([1,1,1,1]*0.125, 4),
			Pseq([1,1,1,1]*0.125, 8),
			Pseq([1]*0.0625, 16),
			Pseq([0.5,0.5,0.25,0.5,0.25]*0.25, 1),
			Pseq([0.25,0.5,0.25,0.5,0.5]*0.125, 2),
			Pseq([0.25,0.5,0.25,0.5,0.5]*0.25, 1),
			Pseq([1]*0.0625, 16),
			Pseq([1,8,1,2]*0.5,1),
			Pseq([1,8,1,2]*0.25,1),
			Pseq([1,4,1,0.5,0.5,2]*0.5,1),
			Pseq([1,0.5,0.5,1,2,2,1]*0.25,1),
			Pseq([1,0.25,0.5,0.25,1,0.5,0.5,0.25,0.75,1,2]*0.5,1),
			Pseq([1,8,1,2],1),
			Pseq([1,3],1),
			Pseq([3,1],1),
			Pseq([1,2,1],1),
			Pseq([1,1,0.5,0.5,1],1),
			Pseq([2,2],2),
			Pseq([1],4),
			Pseq([2],4),
			Pseq([4],1)
		],
		Pwrand(
			[-6, -2, -1, 0, 1, 2, 5],
			[0.1, 0.5, 0.25, 0.1, 0.25, 0.5, 0.2].normalizeSum, inf),
		Pseq([1, -1], inf),
		),
		\init_rate, Pwhite(0.01, 4, inf),
		\sustain, 2,
		// \db, Pexprand( -24, -1, inf)
		\db, Pbrown( -24, -6, 0.5, inf)
	)
).play;
)
