
/******************************************************************
Author: Michael Musick
Email: michael@michaelmusick.com

Project:
File: start.scd

Version: 1.0
M&Year: Feb 2016

Description: Manage the opening and loading of all other files.
Notes:

******************************************************************/


(
// Buffer.freeAll;
o = Server.default.options;
o.memSize = 2**19;

o.verbosity = -2;

// o.numInputBusChannels  = 1;
// o.numOutputBusChannels = 1;
// o.numBuffers = 4096;

~platform = \rpi;
Platform.case(
	\osx, { ~platform = \osx }
);
if( ~platform == \rpi, {
	~thisPath = "/home/pi/seoul_CG/";
}, {
	~thisPath = "/Users/musick/creative_git/sound-e-scape/";
});

// ~thisPath.postln;


{
	// "\ngetting ready to boot\n".postln;
	s.boot;
	// "waiting 30 seconds for things to calm down\n\n".postln;
	if(~platform != \osx, {
		30.wait;
	});
	s.doWhenBooted({
		// "\n\nTest the system\n".postln;
		(~test = {
			Mix(
				SinOsc.ar([400, 404], mul: 0.1)
			) * Linen.kr(Impulse.kr(0), doneAction: 2)
		}.play;);
		2.wait;
		// 7.wait;


		(~thisPath +/+ "/main.scd").loadPaths;
	});
}.fork;

);
