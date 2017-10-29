/*

//ExFunction1: Impulse using constant "e" as argument (try 5e3, 9e3)
~neg1 = SynthDef(\neg1, {
	arg out=0, amp = 0.05;
	var sig, t;
	t=PulseCount.ar(Impulse.ar(2e3));
	sig = HPF.ar(GVerb.ar(((t*0.7)&(t>>2.99)) | ((t*1.1)&(t>>11)) | ((t*22)&(t>>11.1))-3%256)/127-1, 20).tanh/2;

	sig = sig * LFNoise1.kr(LFNoise1.kr(1).linlin(-1,1,0,4)).clip(0,1);
	sig = sig * amp;
	sig = Pan2.ar(sig, 0);

	Out.ar(out, sig);
}).play( args: [
	\out, ~main.negBus

]);*/


//ExFunction2a: Impulse using array as argument
~neg2 = SynthDef(\neg2, {
	arg out = 0, amp = 0.01;
	var sig, t;

	t=PulseCount.ar(Impulse.ar([3000, 1990]));

	sig = HPF.ar(
		GVerb.ar(
			((t*2.7)&(t>>9.99)) | ((t*1.1)&(t>>11)) | ((t*22)&(t>>11.1))-3%256
		) / 127-1,
		20
	).tanh/2;


	sig = sig * LFNoise1.kr(LFNoise1.kr(1).linlin(-1,1,0,4)).linlin(-1,1,0,1).clip(0,1);
	sig = sig * amp;
	Out.ar(out, sig);
}).play( args: [
	\out, ~main.negBus
]);


/*
~neg2.free

*/


//Exfunction2b: Impulse using variable control value as argument (here, MouseX)
//play{t=PulseCount.ar(Impulse.ar(MouseX.kr(0.00001, 20000))); d=HPF.ar(GVerb.ar(((t*2.7)&(t>>2.99)) | ((t*1.1)&(t>>11)) | ((t*22)&(t>>11.1))-3%256)/127-1, 20).tanh/2}


//---------------------------------------
//UGen REFERENCES
//PulseCount: http://doc.sccode.org/Classes/PulseCount.html
//Impulse: http://doc.sccode.org/Classes/Impulse.html
//HPF: http://doc.sccode.org/Classes/HPF.html
//GVerb: http://doc.sccode.org/Classes/GVerb.html

