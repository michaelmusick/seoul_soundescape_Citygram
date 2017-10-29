
(
SynthDef(\woodBlock, {
	arg freq = 220, amp = 0.1, sustain = 1, bright = 1,
	pan = 0, out=0, hardLev = 1.5;
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
	sig = Mix(sig) * hardLev;

	Out.ar(out, Pan2.ar(sig*(-9).dbamp, pan));
}).add;
);


(
SynthDef(\saw_accent, {
	arg freq=440, ffreq=2000, rq=0.9, amp=0.6, gate=1, attackTime=1.5, out=0, pos = 0;
	var sig, env;

	// these are the note envelopes
	env = Env.adsr(
		attackTime: attackTime*0.1,
		decayTime: attackTime*0.9,
		sustainLevel: amp*0.9,
		peakLevel: amp
	);
	env = EnvGen.kr(
		envelope: env,
		gate: gate,
		doneAction: 2
	);

	// this is a signal generator
	sig = VarSaw.ar(
		freq: [freq*2, freq*2.01, freq, freq * 0.99],
		width: [0.2, 0.7, 0.9, 0.3].normalizeSum
	) * 0.05;

	// high pass filter and mix the signals down to one channel
	sig = HPF.ar( in: Mix(sig), freq: 30 );

	// resonant low pass filter
	sig = RLPF.ar( sig, freq: ffreq, rq: rq ) * env;
	sig = Pan2.ar( sig, pos = pos );

	// out
	// also multi-channel expansion to use both speakers
	Out.ar( out, sig );

}).add;

);



(
Pdef(\woodchimes,
	Pbind(
		// \instrument, \saw_accent,
		// \instrument, \woodBlock,
		\instrument, Pfunc { [\saw_accent, \woodBlock].choose },
		\root, 0,
		\octave, Pwhite(4,5,inf),
		\degree, Pdef(\scale),
		\freq, Pfunc { |ev| ev.use(ev[\freq]) },
		\ffreq, 1000,
		\dur, Pdef(\chimePatterns),
		\sustain, 2,
		\db, Pdef(\woodChime_db),
		\amp, Pfunc { |ev| ev.use(ev[\amp]) },
		// \type, Pwrand([\note, \rest], [0.5, 0.5], inf),
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

/*
Pdef(\woodchimes).play;
*/
