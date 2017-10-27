/******************************************************************
BIRDS
******************************************************************/





// =====================================================
// SYNTHDEFs - 'billbird' and 'billbigbird'
// =====================================================


(
SynthDef("billbird", { arg dur, freq, freqskew, amp, t_gate, pan=0, out=0;
	var freqenv, ampenv, freqenvctl, ampenvctl, sig;
	// make an empty 10 segment envelope
	freqenv = Env.newClear(10);
	ampenv = Env.newClear(10);
	// create a control argument array
	freqenvctl = NamedControl.kr(\freqenv, freqenv.asArray);
	ampenvctl = NamedControl.kr(\ampenv, ampenv.asArray);
	sig = SinOsc.ar(
		EnvGen.kr(freqenvctl, t_gate, freqskew, freq, dur),
		0,
		EnvGen.kr(ampenvctl, t_gate, amp, timeScale: dur, doneAction: 2)
	);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef("billbigbird", { arg dur, freq, freqskew, amp, t_gate, pan=0, out=0;
	var howmany = 20; // hard wire max number of partials
	var pnum = Array.fill(howmany, 0); // partial numbers (zero = 'silent' partials as default);
	var pamp = Array.fill(howmany, 1).normalizeSum; // partial amps
	var pnumctl = NamedControl.kr(\partialNumbers, pnum.asArray);
	var pampctl = NamedControl.kr(\partialAmps, pamp.asArray);
	var freqenv = Env.newClear(51);
	var ampenv = Env.newClear(51);
	var freqenvctl = NamedControl.kr(\freqenv, freqenv.asArray);
	var ampenvctl = NamedControl.kr(\ampenv, ampenv.asArray);

	// KLANG: partials, amplitudes, phases,
	var sig = DynKlang.ar(`[pnumctl, pampctl, nil],
		// KLANG: fundamental frequency
		EnvGen.kr(freqenvctl, t_gate, freqskew, freq, dur),
		0) // KLANG: offset
	* EnvGen.kr(ampenvctl, t_gate, amp, timeScale:
		dur, doneAction: 2); // amplitude envelope

	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef(\dummy, {Line.kr(0,1,0.0001,1,0,2)}).add;




// =====================================================
// GLOBAL VARIABLES
// =====================================================
~main_amp = Env([0, 1, 0.7, 1, 0], [0.25, 0.35, 0.15, 0.25], 'sine');

// =====================================================
// FUNCTIONS getLevels & getTimes
// =====================================================

// Rearrange breakpoint envelops from Bill
(
~getLevels = {arg array; array.clump(2).flop.at(1)};
~getTimes = {arg array; array.clump(2).flop.at(0).differentiate.drop(1)};
~getPartials = {arg array; array.clump(2).flop.at(0)}; // same as ~getLevels
~getPartialAmps = {arg array; array.clump(2).flop.at(1)};
);

);





//
// // Example 1:
// (
// x = Synth("billbird", [
// 	\t_gate, 1, \pan, pan,
// \out, ~main.posBus,
// 	\amp, 0.35,
// 	\freqenv, Env([0.8, 1, 0.3, 0], [0.15, 0.6, 0.25], 'sine'),
// 	\freqskew, 2400,
// 	\freq, 4000,
// 	\dur, 0.05,
// 	\ampenv, Env([0, 1, 0.7, 1, 0], [0.25, 0.35, 0.15, 0.25], 'sine')
// ]);
// )
//
// // Example 2:
// (
// x = Synth("billbigbird", [
// 	\dur, 0.2,
// 	\freq, 2000,
// 	\freqskew, 800,
// 	\amp, 0.2,
// 	\freqenv, Env([1, 0.8, 0.3, 0], [0.15, 0.6, 0.25], 'sine'),
// 	\ampenv, Env([0, 1, 0.1, 1, 0], [0.25, 0.25, 0.25, 0.25], 'sine'),
// 	\partialNumbers, [1,2,3],
// 	\partialAmps, [1,0.2,0.05],
// 	\t_gate, 1, \pan, pan,
// \out, ~main.posBus,
// ]);
// );









// ============================
// ===== CHIPPING SPARROW =====
// ============================

(
Pdef(\chirping_sparrow,
	Pbind(
		\instrument, \dummy,
		\dur, Pdef(\bird_durs),
		\root, 0,
		\octave, Prand([7,8], inf),
		\degree, Prand([0,3,4,5,7], inf),
		\freq, Pfunc { |ev| ev.use(ev[\freq]) },

		\der, Pfuncn({
			|event|
			var freq = event[\freq];
			var pan = rrand(-1, 1);


			// original chip-up freq-envelope from bill
			var chipup = [0, 0.8, 0.15, 1, 0.75, 0.3, 1, 0];
			var freqenv = Env(~getLevels.value(chipup), ~getTimes.value(chipup),
				'sine');
			if( ((s.peakCPU < ~main.maxPeakCPU) && (s.avgCPU < ~main.maxAvgCPU)), {
				Task({
					17.do({ // do this 17 times
						x = Synth("billbird", [
							\t_gate, 1, \pan, pan,
							\out, ~main.posBus,
							\amp, 0.05 * ~main.birdAmp,
							\freqenv, freqenv,
							\freqskew, 2400,
							\freq, freq,
							\dur, 0.05,
							\ampenv, ~main_amp,
						]);
						0.01.wait;
				})}).start; // play it!
			}, {
				"cpu too high!".postln;
			}
			);

		}, inf)
	)
);
);


// ============================
// ===== YELLOW WARBLER =======
// ============================


(
Pdef(\yellow_warbler,
	Pbind(
		\instrument, \dummy,
		\dur, Pdef(\bird_durs),
		\root, 0,
		\octave, Prand([7,8,9], inf),
		\degree, Prand([0,3,4,5,7], inf),
		\freq, Pfunc { |ev| ev.use(ev[\freq]) },

		\der, Pfuncn({
			|event|
			if( ((s.peakCPU < ~main.maxPeakCPU) && (s.avgCPU < ~main.maxAvgCPU)), {
				var freq = event[\freq];
				var pan = rrand(-1, 1);
				var warblerTask;
				var yellow_up, yellow_up_bill = [0, 0, 0.6, 1, 1, 0.5];
				var yellow_swirl, yellow_swirl_bill = [0, 1, 0.05, 1, 0.6, 0, 0.8, 0.3,
					1, 0.1];
				var yellow_down, yellow_down_bill = [0, 1, 1, 0];
				var yellow_last, yellow_last_bill = [0, 0, 0.3, 0.2, 0.8, 0.7, 1, 1];
				var swirl_amp, swirl_amp_bill = [0, 0, 0.9, 1, 1, 0];
				var main_amp = ~main_amp;
				var times_bill = [0, 0.23, 0.45, 0.62, 0.85, 1.05, 1.15, 1.25, 1.4];
				var yel_t = times_bill.differentiate;
				yellow_up = Env(~getLevels.value(yellow_up_bill),
					~getTimes.value(yellow_up_bill), 'sine');
				yellow_swirl = Env(~getLevels.value(yellow_swirl_bill),
					~getTimes.value(yellow_swirl_bill), 'sine');
				yellow_down = Env(~getLevels.value(yellow_down_bill),
					~getTimes.value(yellow_down_bill), 'sine');
				yellow_last = Env(~getLevels.value(yellow_last_bill),
					~getTimes.value(yellow_last_bill), 'sine');
				swirl_amp = Env(~getLevels.value(swirl_amp_bill),
					~getTimes.value(swirl_amp_bill), 'sine');

				Task({

					Synth("billbird", [
						\dur, 0.05, \freq, freq*1.12, \freqskew, 400,
						\amp, 0.05 * ~main.birdAmp, \freqenv, yellow_up,
						\ampenv, main_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					yel_t[1].wait;
					Synth("billbird", [
						\dur, 0.12, \freq, freq, \freqskew,
						1500, \amp, 0.15 * ~main.birdAmp, \freqenv, yellow_swirl,
						\ampenv, swirl_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					yel_t[2].wait;
					Synth("billbird", [
						\dur, 0.13, \freq, freq, \freqskew,
						1700, \amp, 0.17 * ~main.birdAmp, \freqenv, yellow_swirl,
						\ampenv, swirl_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					yel_t[3].wait;
					Synth("billbird", [
						\dur, 0.16, \freq, freq, \freqskew,
						2000, \amp, 0.20, \freqenv, yellow_swirl,
						\ampenv, swirl_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					yel_t[4].wait;
					Synth("billbird", [
						\dur, 0.15, \freq, freq, \freqskew,
						2000, \amp, 0.20 * ~main.birdAmp, \freqenv, yellow_swirl,
						\ampenv, swirl_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					yel_t[5].wait;
					Synth("billbird", [
						\dur, 0.075, \freq, freq*0.74,
						\freqskew, 1000, \amp, 0.20 * ~main.birdAmp,
						\freqenv, yellow_down,
						\ampenv, main_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					yel_t[6].wait;
					Synth("billbird", [
						\dur, 0.075, \freq, freq*0.74,
						\freqskew, 800, \amp, 0.15, \freqenv, yellow_down,
						\ampenv, main_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					yel_t[7].wait;
					Synth("billbird", [
						\dur, 0.075, \freq, freq*0.74,
						\freqskew, 800, \amp, 0.15 * ~main.birdAmp,
						\freqenv, yellow_down,
						\ampenv, main_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					yel_t[8].wait;
					Synth("billbird", [
						\dur, 0.2, \freq, freq*0.74,
						\freqskew, 2000, \amp, 0.2 * ~main.birdAmp,
						\freqenv, yellow_last,
						\ampenv, swirl_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
				}).start;
			}, {
				"cpu too high!".postln;
			}
			);
		}, inf)
	)
);
);





// ============================
// ===== ORCHARD ORIOLE =======
// ============================


(
Pdef(\orchard_oriele,
	Pbind(
		\instrument, \dummy,
		\dur, Pdef(\bird_durs),
		\root, 0,
		\octave, Prand([6,7,8], inf),
		\degree, Prand([0,3,4,5,7], inf),
		\freq, Pfunc { |ev| ev.use(ev[\freq]) },

		\der, Pfuncn({
			|event|
			if( ((s.peakCPU < ~main.maxPeakCPU) && (s.avgCPU < ~main.maxAvgCPU)), {
				var freq = event[\freq];
				var pan = rrand(-1, 1);

				var oriup, oriup_bill = [0, 0, 1, 1,];
				var oridwn, oridwn_bill = [0, 1, 1, 0];
				var oriupdwna, oriupdwna_bill = [0, 0, 0.6, 1, 1, 0.6];
				var oriupdwnb, oriupdwnb_bill = [0, 0.5, 0.3, 1, 1, 0];
				var oribiga, oribiga_bill = [0, 0.9, 0.15, 1, 0.4, 0.3, 0.6, 0.6, 0.85,
					0, 1, 0];
				var orimid, orimid_bill = [0, 1.00, 0.05, 0.50, 0.10, 1.00, 0.25, 0.00,
					0.85, 0.50, 1.00, 0.0];
				var oridwnup, oridwnup_bill = [0.00, 0.30, 0.25, 0.00, 1.00, 1.0];
				var oriamp, oriamp_bill = [0.00, 0.00, 0.10, 1.00, 1.00, 0.0];
				var main_amp = ~main_amp;
				var times_bill = [0.38, 0.41, 0.50, 0.65, 0.70, 1, 1.1, 1.3, 1.48, 1.65,
					1.7, 1.8, 1.92, 2.2, 2.28, 2.4] - 0.38; // from bill
				var ori_t = times_bill.differentiate; // get array of durations in between events

				oriup = Env(~getLevels.value(oriup_bill), ~getTimes.value(oriup_bill),
					'sine');
				oridwn = Env(~getLevels.value(oridwn_bill),
					~getTimes.value(oridwn_bill), 'sine');
				oriupdwna = Env(~getLevels.value(oriupdwna_bill),
					~getTimes.value(oriupdwna_bill), 'sine');
				oriupdwnb = Env(~getLevels.value(oriupdwnb_bill),
					~getTimes.value(oriupdwnb_bill), 'sine');
				oribiga = Env(~getLevels.value(oribiga_bill),
					~getTimes.value(oribiga_bill), 'sine');
				orimid = Env(~getLevels.value(orimid_bill),
					~getTimes.value(orimid_bill), 'sine');
				oridwnup = Env(~getLevels.value(oridwnup_bill),
					~getTimes.value(oridwnup_bill), 'sine');
				oriamp = Env(~getLevels.value(oriamp_bill),
					~getTimes.value(oriamp_bill), 'sine');

				Task({

					Synth("billbird", [
						\dur, 0.03, \freq, freq*1.85, \freqskew, 100,
						\amp, 0.5 * ~main.birdAmp,
						\freqenv, oridwn, \ampenv, main_amp,
						\t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[1].wait;
					Synth("billbird", [
						\dur, 0.05, \freq, freq*1.25, \freqskew,
						1000, \amp, 0.1 * ~main.birdAmp,
						\freqenv, oriup, \ampenv, main_amp,
						\t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[2].wait;
					Synth("billbigbird", [
						\dur, 0.1, \freq, freq, \freqskew,
						800, \amp, 0.2 * ~main.birdAmp,
						\freqenv, oriupdwna, \ampenv, main_amp,
						\partialNumbers, [1, 2, 3],
						\partialAmps, [1, 0.2, 0.5],
						\t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[3].wait;
					Synth("billbird", [
						\dur, 0.3, \freq, freq*1.95, \freqskew,
						1200, \amp, 0.1 * ~main.birdAmp,
						\freqenv, oridwn, \ampenv, main_amp,
						\t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[4].wait;
					Synth("billbigbird", [
						\dur, 0.21, \freq, freq,
						\freqskew, 1200, \amp, 0.15 * ~main.birdAmp,
						\freqenv, oribiga,
						\ampenv, main_amp,
						\partialNumbers, [1, 2],
						\partialAmps, [1, 0.05], \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[5].wait;
					Synth("billbird", [
						\dur, 0.05, \freq, freq*2.1, \freqskew,
						1000, \amp, 0.1 * ~main.birdAmp,
						\freqenv, oridwn,
						\ampenv, main_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[6].wait;
					Synth("billbigbird", [
						\dur, 0.1, \freq, freq, \freqskew,
						1000, \amp, 0.25 * ~main.birdAmp,
						\freqenv, orimid, \ampenv, main_amp,
						\partialNumbers, [1, 2],
						\partialAmps, [1, 0.05], \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[7].wait;
					Synth("billbigbird", [
						\dur, 0.1, \freq, freq, \freqskew,
						1000, \amp, 0.25 * ~main.birdAmp,
						\freqenv, orimid, \ampenv, main_amp,
						\partialNumbers, [1, 2],
						\partialAmps, [1, 0.05], \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[8].wait;
					Synth("billbird", [
						\dur, 0.1, \freq, freq*1.15, \freqskew,
						3200, \amp, 0.1 * ~main.birdAmp,
						\freqenv, oriupdwnb,
						\ampenv, oriamp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[9].wait;
					Synth("billbird", [
						\dur, 0.03, \freq, freq*0.9, \freqskew,
						300, \amp, 0.05 * ~main.birdAmp, \freqenv, oriup,
						\ampenv, main_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[10].wait;
					Synth("billbird", [
						\dur, 0.03, \freq, freq*1.1, \freqskew,
						100, \amp, 0.4 * ~main.birdAmp, \freqenv, oridwn,
						\ampenv, main_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[11].wait;
					Synth("billbird", [
						\dur, 0.07, \freq, freq*1.25, \freqskew,
						2000, \amp, 0.15 * ~main.birdAmp, \freqenv, oriupdwnb,
						\ampenv, oriamp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[12].wait;
					Synth("billbigbird", [
						\dur, 0.2, \freq, freq*1.2,
						\freqskew, 1200, \amp, 0.25 * ~main.birdAmp,
						\freqenv, oridwnup,
						\ampenv, main_amp,
						\partialNumbers, [1, 2],
						\partialAmps, [1, 0.04], \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[13].wait;
					Synth("billbird", [
						\dur, 0.02, \freq, freq*1.1, \freqskew,
						3000, \amp, 0.4 * ~main.birdAmp,
						\freqenv, oriup, \ampenv, main_amp,
						\t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[14].wait;
					Synth("billbird", [
						\dur, 0.02, \freq, freq*1.1, \freqskew,
						3000, \amp, 0.4 * ~main.birdAmp,
						\freqenv, oriup,
						\ampenv, main_amp, \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					ori_t[15].wait;
					Synth("billbigbird", [
						\dur, 0.17, \freq, freq,
						\freqskew, 1000, \amp, 0.2 * ~main.birdAmp,
						\freqenv, oriupdwna,
						\ampenv, main_amp,
						\partialNumbers, [1, 2],
						\partialAmps, [1, 0.04], \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
				}).start;
			}, {
				"cpu too high!".postln;
			}
			);
		}, inf)
	)
);
);


// ============================
// ==== CASSINS KINGBIRD ======
// ============================


(
Pdef(\cassins_kingbird,
	Pbind(
		\instrument, \dummy,
		\dur, Pdef(\bird_durs),
		\root, 0,
		\octave, Prand([6,7], inf),
		\degree, Prand([0,3,4,5,7], inf),
		\freq, Pfunc { |ev| ev.use(ev[\freq]) },

		\der, Pfuncn({
			|event|
			if( ((s.peakCPU < ~main.maxPeakCPU) && (s.avgCPU < ~main.maxAvgCPU)), {
				var freq = event[\freq];
				var pan = rrand(-1, 1);

				var kingfirst_bill = [0.00, 0.30, 0.45, 1.00, 0.90, 0.10, 1.00, 0.0];
				var kingsecond_bill = [0.00, 0.00, 0.02, 0.50, 0.04, 0.00, 0.06, 0.55,
					0.08, 0.05, 0.10, 0.60, 0.12, 0.05, 0.14, 0.65, 0.16, 0.10, 0.18, 0.70,
					0.20, 0.10, 0.22, 0.75, 0.24, 0.15, 0.26, 0.80, 0.28, 0.20, 0.30, 0.85,
					0.32, 0.25, 0.34, 0.90, 0.36, 0.30, 0.38, 0.95, 0.40, 0.40, 0.42, 1.00,
					0.44, 0.50, 0.46, 1.00, 0.48, 0.45, 0.50, 1.00, 0.52, 0.50, 0.54, 1.00,
					0.56, 0.40, 0.58, 0.95, 0.60, 0.40, 0.62, 0.90, 0.64, 0.40, 0.66, 0.85,
					0.68, 0.35, 0.70, 0.80, 0.72, 0.30, 0.74, 0.75, 0.76, 0.25, 0.78, 0.70,
					0.80, 0.20, 0.82, 0.65, 0.84, 0.10, 0.86, 0.60, 0.88, 0.00, 0.90, 0.55,
					0.92, 0.00, 0.94, 0.50, 0.96, 0.00, 1.00, 0.40];
				var main_amp = ~main_amp;
				var times_bill = [0.3, 0.12];
				var king_t = times_bill.differentiate; // get array of durations in between events

				var kingfirst = Env(~getLevels.value(kingfirst_bill),
					~getTimes.value(kingfirst_bill), 'sine');
				var kingsecond = Env(~getLevels.value(kingsecond_bill),
					~getTimes.value(kingsecond_bill), 'sine');

				Task({
					Synth("billbigbird", [
						\dur, 0.04, \freq, freq,
						\freqskew, 1200, \amp, 0.15 * ~main.birdAmp,
						\freqenv, kingfirst, \ampenv, main_amp,
						\partialNumbers, [1, 2, 3, 4],
						\partialAmps, [1, 0.5, 0, 0.2], \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
					king_t[1].wait;    Synth("billbigbird", [
						\dur, 0.18, \freq, freq,
						\freqskew, 900, \amp, 0.25 * ~main.birdAmp,
						\freqenv, kingsecond, \ampenv, main_amp,
						\partialNumbers, [1, 2, 3, 4],
						\partialAmps, [1, 0.01, 0, 0.1], \t_gate, 1, \pan, pan,
						\out, ~main.posBus
					]);
				}).start;
			}, {
				"cpu too high!".postln;
			}
			);
		}, inf)
	)
);
);




/*

FROM:
"http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/Arrays-as-SynthDef-arguments-for-the-birds-tp7061974p7104917.html"
*/