// Probably all throw away...


(
SynthDef(\chimes, {
	arg freq = 60.midicps, dur = 1, amp = -24.dbamp, gate = 1, envType = 0, pan = 0;
	var sig, env;
	var carfreq = freq;
	var modfreq = [freq, freq*0.98, freq*1.01];
	var modidx = 3;
	var modphase = 0;


	env = Env.adsr(
		attackTime: 0.01,
		decayTime: 0.1,
		sustainLevel: 0.8,
		releaseTime: 1,
		peakLevel: 1,
		curve: -4
	);


	env = EnvGen.kr(env, gate:gate, levelScale:amp, timeScale:dur, doneAction:2);
	modidx = modidx * env;
	sig = PMOsc.ar( carfreq, modfreq, modidx, modphase );
	sig = [sig, SinOsc.ar(freq*2, 0, mul: env)];
	sig.size.postln;
	sig = sig * env;
	sig = Mix(sig);
	sig = Mix(sig);
	sig = Pan2.ar( sig, pos: pan );

	Out.ar(0, sig);
}).add;
)
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
				amp/2
			),
			doneAction: (i==0).asInt * 2
		);
		i_sig*i_env;
	}).sum;

	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)
~test = ().play;
~test[\instrument] = '\woodBlock'
~test.freq = 60.midicps

~test = Pbind(\instrument, \chimes, \degree, Pwhite(0, 7, inf), \dur, 1.5, \db, -9, \sustain, 0.1).play;




~test = (name: '\1');
~test.degree = PatternProxy(Pwhite(0, 1, inf));
~test.dur= PatternProxy(Pn(1.0, inf));
~test.sus = PatternProxy(Pn(0.2, inf));
~test.db = PatternProxy(Pn(-24, inf));
~test.inst = '\chimes';

(
Pdef(\1,
	Pbind(
		\instrument, ~test.inst,
		\degree, ~test.degree,
		\dur, ~test.dur,
		\sustain, ~test.sus,
		\db, ~test.db
	)
).play;
)

Pbindef(\1, \instrument, \woodBlock)

Pdef(~test.name).play;

~test.db.source = Pn(-3,inf);
~test.degree.source = Pwhite(0,7,inf);
~test.sus.source = Pn(1.1, inf)




(
Pdef(~test.name,
	item: Pbind(
		\instrument, ~test.inst,
		\degree, ~test.degree,
		\dur, ~test.dur,
		// \sustain, ~test.sus,
		\db, ~test.db,
		\length, 0.5
	)
);
)











{200.0.rrand(4000)}.dup(12)

([1].addAll( {200.0.rrand(4000)}.dup(12) )).size
