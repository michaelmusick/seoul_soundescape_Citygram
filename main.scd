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
{

	// Define the environment variable for the entire system
	~main = ();

	/*********************************************
	SYSTEM WIDE ACTIVITY VARIABLES
	*********************************************/
	~main.activityLevel = 1;

	/*********************************************
	SYSTEM WIDE BUSES
	*********************************************/
	~main.mainOutput = 0;
	~main.neutralBus = Bus.audio(s, 2);
	~main.posBus     = Bus.audio(s, 2);
	~main.negBus     = Bus.audio(s, 2);

	/*********************************************
	SYSTEM SERVER SHUTDOWN CHECK!!
	*********************************************/
	~main.maxPeakCPU = 75;
	~main.maxAvgCPU = 70;



	/*********************************************
	LOAD ALL OTHER FILES
	*********************************************/

	"about to load files".postln;
	4.0.wait;

	"Loading Neutral Layer".postln;
	(~thisPath +/+ "neutral/*.scd").loadPaths;
	10.0.wait;

	"Loading Negative Layer".postln;
	(~thisPath +/+ "negative/*.scd").loadPaths;
	10.0.wait;

	"Loading Positive Layer".postln;
	(~thisPath +/+ "positive/*.scd").loadPaths;
	10.0.wait;

	"Loading Main Mixer".postln;
	(~thisPath +/+ "mainMix/*.scd").loadPaths;
	2.0.wait;

	"Loading CG_Bridge".postln;
	(~thisPath +/+ "cg_bridge.scd").loadPaths;
	2.0.wait;

	"Loading Recovery Loop".postln;
	(~thisPath +/+ "recovery.scd").loadPaths;
}.fork;
)
