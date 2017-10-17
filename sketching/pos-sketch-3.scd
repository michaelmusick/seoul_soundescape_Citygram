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

	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

TempoClock.default.tempo = 88/60;


(
Pdef(\woodchimes,
	Pbind(
		\instrument, \woodBlock,
		\degree, Prand([0,3,4,5,7], inf),
		\octave, Pwhite(4,5,inf),
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
		\sustain, 1,
		// \db, Pexprand( -24, -1, inf)
		\db, Pbrown( -24, -1, 0.5, inf)
	)
).play;
)
