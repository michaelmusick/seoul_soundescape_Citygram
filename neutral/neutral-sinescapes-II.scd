(

~neutral = ();
~neutral.synthsReady = [false, false, false];


// ---------------------------------------------------------------
//                   Process/control installation synth
// ---------------------------------------------------------------


OSCdef(\synthDropsUpdate, {
	var density = 1;

	if( ~cgGroupData[(~dataPtr-1)%~cgGroupData.size][\TD_RMS][\avg].notNil, {
		density = ~cgGroupData[(~dataPtr-1)%~cgGroupData.size][\TD_RMS][\avg];
		// ("rms: " + density).postln;
		density = density + 1;
		density = density.explin(1,2,0.1,100);
	});
	// ("Synthdrops desnity set to: " + density).postln;
	~synthDrops.set("density", density);
},
\newDataReady,
NetAddr.localAddr
);


// ---------------------------------------------------------------
//                              Synth Defs
// ---------------------------------------------------------------

SynthDef.new("Sinescape",
	{
		arg outBus = 0, density = 50, bwFreqStart = 100.0,
		amp = 30, effectBus, direct = 0.5, ampMaster = 0.5;
		var sig, scalerDensity = 0.050, scalerAmp = 10;

		// update density with "lag" or slide between values
		density = density.lag(1.0);
		// density.poll;

		// create resonance sound objects with dust
		sig = Mix.ar(
			Array.fill(20, {
				var resBwr, resMult = 0.003;

				// bandwidth setup
				resBwr = bwFreqStart + (12.rand)*bwFreqStart;

				Resonz.ar(Dust.ar(density*scalerDensity, amp*scalerAmp),
					[resBwr, resBwr*2, resBwr*3],
					[resMult, resMult/2, resMult/3])})
		);

		// sound ouput
		Out.ar(outBus, sig*direct*ampMaster);
		Out.ar(effectBus, sig*(1-direct)*ampMaster);
}).add(completionMsg: NetAddr.localAddr.sendMsg(\startNeutral, 0); );

SynthDef.new("sinGliss",
	{
		arg outBus = 0, effectBus, impulseFreq = 0.1,
		ampMaster = 0.2, freq = 220, freqDecay = 200;
		var imp, sig, direct = 0.5, attackTime = 0.1, decayTime = 1;

		imp = EnvGen.kr(Env.perc, 2.0, doneAction: 2)*SinOsc.ar([freq, freq*2, freq*3],0,0.1);

		sig = Decay2.ar(imp, attackTime, decayTime,
			SinOsc.ar(SinOsc.kr(0.01, 0, 110, freqDecay)));

		Out.ar(outBus, sig*direct*ampMaster);
		Out.ar(effectBus, sig*(1-direct)*ampMaster);
}).add(completionMsg: NetAddr.localAddr.sendMsg(\startNeutral, 1); );

SynthDef.new("myReverb",
	{
		arg outBus = 0, inBus, direct = 0.5, ampMaster = 0.2;
		var outDelay, sig, input;

		input = In.ar(inBus, 1);

		// reverb predelay time :
		outDelay = DelayN.ar(input, 0.048);

		// 7 length modulated comb delays in parallel :
		sig = Mix.ar(Array.fill(7,
			{CombL.ar(outDelay, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15/4) }));

		// two parallel chains of 4 allpass delays (8 total) :
		4.do({ sig = AllpassN.ar(sig, 0.050, [0.050.rand, 0.050.rand], 1) });
		Out.ar(outBus, sig*ampMaster);
	}
).add(completionMsg: NetAddr.localAddr.sendMsg(\startNeutral, 2); );


// add routine for gliss
~routineGliss = Routine({
	var delta, freqRand, mpy = 1;

	loop {
		delta = rrand(1, 30.0)*mpy;
		delta.yield;

		freqRand = 1000.0.rand + 20.0;
		// "Gliss trigger ".post; delta.postln;
		//~synthGliss.set("impulseFreq", 0.001+(1.0.rand)/4);

		Synth.before(~synthReverb, "sinGliss",
			[effectBus: ~bussMix, freq: freqRand, freqDecay: freqRand]);
	}
});


// ---------------------------------------------------------------
//                              Start audio
// ---------------------------------------------------------------

OSCdef(\startNeutral, {
	|msg, time, addr|

	var synthNum = msg[1];
	var ready = false;

	// msg.postln;
	// "working".postln;

	~neutral.synthsReady[synthNum.asInteger] = true;

	ready = (
		~neutral.synthsReady[0] &&
		~neutral.synthsReady[1] &&
		~neutral.synthsReady[2]
	);

	if( ready, { {
		1.0.wait;
		~bussMix = Bus.audio(s, 2);

		// run synths
		~synthReverb   = Synth.new("myReverb", [inBus: ~bussMix]
		);

		~synthDrops    = Synth.before(~synthReverb, "Sinescape",
			[effectBus: ~bussMix, bwFreqStart: 120, density: 1, amp: 30]
		);

		~synthAmbiance = Synth.before(~synthReverb, "Sinescape",
			[effectBus: ~bussMix, bwFreqStart: 8,
				density: 3, direct: 0.2, amp: 50]
		);

		~synthGliss    = Synth.before(~synthReverb, "sinGliss",
			[effectBus: ~bussMix]
		);

		~routineGliss.play;
	}.fork; });
},
\startNeutral,
NetAddr.localAddr
);




)
