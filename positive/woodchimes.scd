
(
SynthDef(\woodBlock, {|freq = 220, amp = 0.1, sustain = 1, bright = 1, pan = 0, out=0|
	var partials = [1, 2.572, 4.644, 6.984, 9.723, 12];
	var sig = Array.fill(6, {|i|
		var i_sig = SinOsc.ar(
			partials[i]*freq,
			rrand(0,2pi),
			(1+(bright*((i/5)-1)))/(i**2.5+1)
		);
		var i_env = EnvGen.kr(
			Env.perc(0.06/(i+1),
				sustain/(i+1),
				amp
			),
			doneAction: (i==0).asInt * 2
		);
		i_sig*i_env;
	}).sum;

	2.do({ sig = AllpassN.ar(sig, 0.050, [0.050.rand, 0.050.rand], 1) });
	sig = Mix(sig);

	Out.ar(out, Pan2.ar(sig*(-9).dbamp, pan));
}).add;
);




(
Pdef(\woodchimes,
	Pbind(
		\instrument, \woodBlock,
		\root, 0,
		\octave, Pwhite(4,5,inf),
		\degree, Prand([0,3,4,5,7], inf),
		\freq, Pfunc { |ev| ev.use(ev[\freq]) },
		\dur, Pdef(\chimePatterns),
		\sustain, 1,
		\db, Pdef(\woodChime_db),
		\amp, Pfunc { |ev| ev.use(ev[\amp]) },
		// \type, Pwrand([\note, \rest], [0.5, 0.5], inf),
		\out, ~main.posBus,
		// \blah, Pfuncn({ |ev| ev.postln; }, inf)

	)
).play;
);


