/*******************************************************

Manage the opening and loading of all other files.






*******************************************************/



/******************************************************************
      Author: Michael Musick
       Email: michael@michaelmusick.com

     Project:
        File: start.scd

     Version: 1.0
      M&Year: Feb 2016

 Description: Start File for SC and Sonic Space 10
       Notes:

******************************************************************/


(
// Buffer.freeAll;
o = Server.default.options;
o.memSize = 2**19;
// o.numInputBusChannels  = 1;
// o.numOutputBusChannels = 1;
// o.numBuffers = 4096;

{
	"\ngetting ready to boot\n".postln;
	s.boot;
	"waiting 30 seconds for things to calm down\n\n".postln;
	30.wait;
	s.doWhenBooted({
		"\n\nTest the system\n".postln;
		/*(~test = {
			Mix(
				SinOsc.ar([400, 404], mul: 0.4)
			) * Linen.kr(Impulse.kr(0), doneAction: 2)
		}.play;);*/
		2.wait;
		// 7.wait;
		// ~thisPath = Document.current.dir;
		~thisPath = "/home/pi/seoul_CG/";

		(~thisPath +/+ "/main.scd").loadPaths;
	});
}.fork;

);
