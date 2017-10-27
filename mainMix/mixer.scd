/**************************************************************

Project: Citygram - Seoul Soundescape Installation

Author: The Citygram Team
Email: thp1@nyu.edu
Email: michael@michaelmusick.com

Created: October 22nd, 2017

Notes: Handles the mixing and managment of the three voice layers

**************************************************************/


~main.negRange = [0,0.2];
~main.neutRange = [0.1,0.65];
~main.posRange = [0.5,1.0];

// memory length, in mins
~main.memoryLength = ( 120 ) * 60;
if( (~main.rsdHist).isNil, { ~main.rsdHist = Array.newClear(~main.memoryLength); });
~main.rsdHistIdx = 0;
~main.rsdHistFull = false;
~main.maxRSDs = 0;
~main.minRSDs = 1000000;
~main.numActiveRSDs = 0;
(
OSCdef(\updateMix, {
	|msg, time, addr|

	var ptr = msg[1];
	var activeRSDs;
	var pos=0.3, neg=0.3, neut=0.3;

	var mixVal = 0;

	if( ~cgGroupData[ptr][\activeRSDs].notNil, {
		activeRSDs = ~cgGroupData[ptr][\activeRSDs];
		// ("active RSDs: " + activeRSDs).postln;
		~main.numActiveRSDs = activeRSDs;

		~main.rsdHist.put(~main.rsdHistIdx, activeRSDs);

		if( ~main.rsdHistFull, {
			~main.maxRSDs = ~main.rsdHist[~main.rsdHist.maxIndex];
			~main.minRSDs = ~main.rsdHist[~main.rsdHist.minIndex];
			// "rsdHist Full".postln;
		},{
			var idx, tempArr;
			tempArr = ~main.rsdHist.copySeries(0, 1, ~main.rsdHistIdx);
			idx = tempArr.maxIndex;
			~main.maxRSDs = tempArr[idx];
			idx = tempArr.minIndex;
			~main.minRSDs = tempArr[idx];
			if( ~main.rsdHistIdx + 1 == ~main.memoryLength, {
				~main.rsdHistFull = true;
			});
			// "rsdHist filling...".postln;
		});

		~main.rsdHistIdx = (~main.rsdHistIdx + 1) % ~main.memoryLength;

		// ADJUST MIX FOR POS?NEUT?NEG
		mixVal = activeRSDs.linlin(~main.minRSDs, ~main.maxRSDs, 0, 1);
		mixVal.postln;

		pos  = mixVal.linlin(
			~main.posRange[0], ~main.posRange[1],
			0,                 1,
			\minmax
		);
		neg  = mixVal.linlin(
			~main.negRange[0], ~main.negRange[1],
			1,                 0,
			\minmax
		);
		neut = (
			mixVal.clip(
				~main.neutRange[0], ~main.neutRange[1]
		).linlin(
				~main.neutRange[0], ~main.neutRange[1],
				0,                  1
		) * pi ).sin.clip(0,1);
		~main.mainOut.set(\posLevel, pos, \neutLevel, neut, \negLevel, neg);

		("pos: "+pos).postln;
		("neut: "+neut).postln;
		("neg: "+neg).postln;
	});


},
\newDataReady,
NetAddr.localAddr
);
);

/*

~main.mainOut.get(\negLevel, {|val| val.postln;});
*/

"starting main out".postln;
~main.mainOut = SynthDef(\mixerSynth, {
	arg neutIn, posIn, negIn, out = 0, neutLevel = 0.3, posLevel = 0.3, negLevel = 0.3, lagTime = 2;

	var posSig, neutSig, negSig, mainSig;

	// get signals
	posSig  = In.ar(posIn, 2);
	neutSig = In.ar(neutIn, 2);
	negSig  = In.ar(negIn, 2);

	// ease in to new levels
	posLevel  = posLevel.lag(lagTime);
	negLevel  = negLevel.lag(lagTime);
	neutLevel = neutLevel.lag(lagTime);

	// mix signals
	posSig  = posSig  * posLevel.sqrt;
	neutSig = neutSig * neutLevel.sqrt;
	negSig  = negSig  * negLevel.sqrt;

	mainSig = Mix([ posSig, neutSig, negSig ]);

	// any signal processing for mastering, goes here

	mainSig = Limiter.ar( mainSig, 0.99, 0.01 );

	Out.ar( out, mainSig );
}).play( args: [
	\neutIn, ~main.neutralBus,
	\posIn, ~main.posBus,
	\negIn, ~main.negBus,
	\out, ~main.mainOutput
],
addAction: \addToTail
);