(
var maxGrainDensity = 100;

var interpValues, updateFeature;

var cntNodes       = 0;
var t0             = 0;
var numOfBuffers   = 4;
var bufferIdxWrite = 0;
var bufferIdxRead  = 0;
var buffersReady   = false;
var maxNumOfNodes  = 100000;
var prevNodeId     = -1;

// four features, 3 vals (min, avg, max)
var numOfFeatures    = 6;
var featureMinAvgMax = Array.fillND([numOfFeatures, 3], { arg a; 0; });

// number of max RSDs
var nodes = [
  Array.fill(maxNumOfNodes, featureMinAvgMax),
  Array.fill(maxNumOfNodes, featureMinAvgMax),
  Array.fill(maxNumOfNodes, featureMinAvgMax),
  Array.fill(maxNumOfNodes, featureMinAvgMax)
];

var nodeIds = [
  Array.fill(maxNumOfNodes, featureMinAvgMax),
  Array.fill(maxNumOfNodes, featureMinAvgMax),
  Array.fill(maxNumOfNodes, featureMinAvgMax),
  Array.fill(maxNumOfNodes, featureMinAvgMax)
];

var numOfNodes = Array.fill(numOfBuffers, 0);

var portIn = 9999;
var spectralFlatness = 5,
    spectralSpread   = 4,
    spectralCentroid = 3,
    zcr              = 2,
    temporalCentroid = 1,
    rms              = 0;

var meanFeatValsPrev = Array.fill(numOfFeatures, 0).postln;
var sampsPerSec   = 4;
var upsampledVals = Array.fillND([numOfFeatures, sampsPerSec], { arg a; 0; });
var processIdx    = 0;

/////////////////////////////////////////

SynthDef.new("Sinescape",
	{
		arg outBus = 0, density = 50, bwFreqStart = 100.0,
		    amp = 30, effectBus, direct = 0.5, ampMaster = 0.5;
		var sig, scalerDensity = 0.050, scalerAmp = 10;

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
}).add;

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
}).add;

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
).add;

/////////////////////////////////////////

updateFeature = { arg inStr, inVal, featureIdx;
	var pKey;
	pKey = inStr.split($/).drop(1)[1].asInteger;

	if((pKey != prevNodeId),{
	  //pKey.postln;

	  nodeIds[bufferIdxWrite][cntNodes] = pKey; // update pKeys for each buffer
	  prevNodeId = pKey;                   // store prev pKey for counting nodes
	  cntNodes   = cntNodes + 1;
	}, {});

	// pKey.postln;
	// featureIdx.postln;

	if (inStr.find("min").isNil,{
	  if (inStr.find("max").isNil,
		{ nodes[bufferIdxWrite][pKey][featureIdx][1] = inVal; },  // avg
		{ nodes[bufferIdxWrite][pKey][featureIdx][2] = inVal; }); // max
	},{ nodes[bufferIdxWrite][pKey][featureIdx][0] = inVal; });   // min
};

interpValues = { arg feature, theName;
	if (feature.isNil,
	{  },
	{
		//theName.postln;
		//feature.postln;
	})
};

thisProcess.openUDPPort(portIn); // open UDP port to listen to OSC

f = { |msg, time, addr|
  if((msg[0] != '/status.reply') && (msg[0] != '/citygram/time') && (msg[0] != '/citygram/endPacket'),{
    var msgStr = msg[0].asCompileString; // stringify

		// msgStr.split($/).drop(1)[1].postln;

	// sort the features, then sort min, avg, max
	if (msgStr.find("FD_SpectralFlatness").isNil,{
		if (msgStr.find("FD_SpectralSpread").isNil,{
			if (msgStr.find("FD_SpectralCentroid").isNil,{
				if (msgStr.find("TD_ZCR").isNil,{
					if (msgStr.find("TD_TemporalCentroid").isNil,{
						if (msgStr.find("TD_RMS").isNil,{},
						{ updateFeature.value(msgStr, msg[1], rms); });
					},{ updateFeature.value(msgStr, msg[1], temporalCentroid); });
				},{ updateFeature.value(msgStr, msg[1], zcr); });
			},{ updateFeature.value(msgStr, msg[1], spectralCentroid); });
		},{ updateFeature.value(msgStr, msg[1], spectralSpread); });
	},{ updateFeature.value(msgStr, msg[1], spectralFlatness); });

	// interpVals = [prevVal, msg[1]].resamp1(60);
  }, {
	if ((msg[0] == '/citygram/endPacket'), {
	  var temp;
	  temp = Main.elapsedTime-t0;

	  "\n".postln;
	  ("sec elapsed: " ++ temp).postln;

	  t0 = Main.elapsedTime;

	  numOfNodes[bufferIdxWrite] = cntNodes;

	  //numOfNodes.copyRange(0, numOfNodes[0]).postln;
	  ("num of nodes: " ++ cntNodes).postln;
	  cntNodes = 0;

	  // buffer write
	  //bufferIdxWrite.postln;
	  bufferIdxWrite = bufferIdxWrite + 1;
	  bufferIdxWrite = bufferIdxWrite % numOfBuffers;

	  // buffer read
	  bufferIdxRead = bufferIdxRead + 1;
	  bufferIdxRead = bufferIdxRead % numOfBuffers;
	  // bufferIdxRead.postln;

	  // wait for one cycle before making read buffer ready
	  if ((bufferIdxWrite == 0), {buffersReady = true}, {});
	  //buffersReady.postln;

	  if ((buffersReady == true), {
        var pKeysInBuff;
        var numOfNodesTmp;
        var theMean, theSum, meanScale;

		~processFeat.pause;

        theSum = 0;
		meanScale = 3000/20;

		pKeysInBuff   =  nodeIds[bufferIdxRead].copyRange(0, numOfNodes[bufferIdxRead]);
		numOfNodesTmp = pKeysInBuff.size;
		//("pKeysInBuff: " ++ pKeysInBuff).postln;

		if (numOfNodesTmp == 0, { numOfNodesTmp = 1}, {});

		// compute average rms from streaming nodes
        pKeysInBuff.do ({
		 arg item, index;

		  theSum = theSum + nodes[bufferIdxRead][index][rms][2];
		  //nodes[bufferIdxRead][index][rms][1].postln;
          //("index: " ++ index ++ " item: " ++ item).postln;
		});

		theMean = theSum/numOfNodesTmp;

		if (theMean > 50, {theMean = 50}, {});

		// interpolate
	    upsampledVals[rms] =
		  [meanFeatValsPrev[rms], theMean].resamp1(sampsPerSec)*numOfNodes[bufferIdxRead]*meanScale;
		  //[meanFeatValsPrev[rms], theMean].resamp1(sampsPerSec)*numOfNodes[bufferIdxRead]/10*2.5;

		// update history
        meanFeatValsPrev[rms] = theMean;
        //("mean rms: " ++ theMean).postln;

		processIdx = 0;       // reset process idx
		~processFeat.resume;  // resume processor

		// nodes[bufferIdxRead][100][rms][1].postln;
		// nodeIds[bufferIdxRead].copyRange(0, numOfNodes[bufferIdxRead]).postln;
	  }, {});

	  prevNodeId = -1; // reset

	  "packetEnd".postln;
	},{});
  });
};

// ---------------------------------------------------------------
//                   Process/control installation synth
// ---------------------------------------------------------------
~processFeat = Task({
  inf.do({
	var temp;
    temp = 1;

	// filter out nil, inf, and compress
	if (upsampledVals[rms][processIdx] == nil, {
      temp = nil;
	},
	{
	  if(upsampledVals[rms][processIdx] == inf, {
		temp = nil;
	  },{
		if (upsampledVals[rms][processIdx] > maxGrainDensity, {
		  temp = maxGrainDensity;
		},
		{
		  temp = upsampledVals[rms][processIdx];
		});

	  });
	}
	);

	("value before and after: " ++ upsampledVals[rms][processIdx] ++ ", " ++ temp).postln;
	("processing sample: " ++ temp).postln;

	~synthDrops.set("density", temp); // grain desnity: 0.0 ... 100.0;

	processIdx = processIdx + 1;
	(1/sampsPerSec).wait;
  })}, TempoClock
);

// ---------------------------------------------------------------
//                              Start audio
// ---------------------------------------------------------------
(
~bussMix = Bus.audio(s, 2);

// run synths
~synthReverb   = Synth.new("myReverb", [inBus: ~bussMix]);

~synthDrops    = Synth.before(~synthReverb, "Sinescape",
	[effectBus: ~bussMix, bwFreqStart: 120, density: 1, amp: 30]);

~synthAmbiance = Synth.before(~synthReverb, "Sinescape",
	[effectBus: ~bussMix, bwFreqStart: 8, density: 3, direct: 0.2, amp: 50]);

~synthGliss    = Synth.before(~synthReverb, "sinGliss", [effectBus: ~bussMix]);

// add routine for gliss
~routineGliss = Routine({
    var delta, freqRand, mpy = 1;

    loop {
        delta = rrand(1, 30.0)*mpy;
		freqRand = 1000.0.rand + 20.0;
		"Gliss trigger ".post; delta.postln;
		//~synthGliss.set("impulseFreq", 0.001+(1.0.rand)/4);

		Synth.before(~synthReverb, "sinGliss",
			[effectBus: ~bussMix, freq: freqRand, freqDecay: freqRand]);
        delta.yield;
    }
});

~routineGliss.play;
);

// ---------------------------------------------------------------
//                    Start OSC listener
// ---------------------------------------------------------------
thisProcess.addOSCRecvFunc(f);

)