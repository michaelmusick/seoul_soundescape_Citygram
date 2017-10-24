/**************************************************************

 Project: Citygram - Seoul Soundescape Installation

  Author: The Citygram Team
   Email: thp1@nyu.edu
   Email: michael@michaelmusick.com

 Created: October 22nd, 2017

   Notes: MAIN Start File for Seoul Soundescapes Installation

**************************************************************/


/*********************************************
Main File and System Variables
*********************************************/
(

// Define the environment variable for the entire system
~main = ();

~thisPath = Document.current.dir;


/*********************************************
SYSTEM WIDE BUSES
*********************************************/
~main.mainOutput = 0;
~main.neutralBus = Bus.audio(s, 2);
~main.posBus     = Bus.audio(s, 2);
~main.negBus     = Bus.audio(s, 2);



/*********************************************
LOAD ALL OTHER FILES
*********************************************/
{
	"about to load files".postln;
	// 4.0.wait;

	"Loading Positive Layer".postln;
	(~thisPath +/+ "positive/*.scd").loadPaths;
	2.0.wait;

	"Loading Neutral Layer".postln;
	(~thisPath +/+ "neutral/*.scd").loadPaths;
	2.0.wait;

	"Loading Negative Layer".postln;
	(~thisPath +/+ "negative/*.scd").loadPaths;
	2.0.wait;

	"Loading Main Mixer".postln;
	(~thisPath +/+ "mainMix/*.scd").loadPaths;
	2.0.wait;

	"Loading CG_Bridge".postln;
	(~thisPath +/+ "cg_bridge.scd").loadPaths;

}.fork;
)
