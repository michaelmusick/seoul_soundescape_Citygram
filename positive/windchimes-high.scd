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

    var env, impulse, imp2, sig, sig_h, sig_l, rate, mix_sig;


    env = EnvGen.kr(
        Env.linen(atk, sus, rel, 1, -4),
		timeScale: sustain
    );

	rate = XLine.kr(init_rate, 0.01, sustain);
	imp2 = Impulse.ar(0.1);
	impulse = Dust.ar(rate);
	impulse = Mix([imp2, impulse]);
	impulse = Decay.ar(
        impulse,
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
);



(
Pdef(\windchimes_high,
	Pbind(
		\instrument, \windchime_high,
		\root, 0,
		\octave, Prand([6, 7], inf),
		\degree, Prand([0,3,4,5,7], inf),
		\freq, Pfunc { |ev| ev.use(ev[\freq]) },
		\dur, Pdef(\chimePatterns),
		\init_rate, Pwhite(0.01, 4, inf),
		\sustain, 2,
		\db, Pdef(\highChime_db),
		\amp, Pfunc { |ev| ev.use(ev[\amp]) },
		\out, ~main.posBus,
		// \blah, Pfuncn({ |ev| ev.postln; }, inf)
	)
);
);
