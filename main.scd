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
~main.mainOutput = Bus.audio(s,2);



/*********************************************
LOAD ALL OTHER FILES
*********************************************/
{
	"about to load files".postln;
	// 4.0.wait;
	"Loading /common/*.scd".postln;
	~thisPath = ~thisPath +/+ "ss9/");
	(~main.dir +/+ "common/*.scd").loadPaths;
	4.0.wait;
	("Loading /species_" ++ ~main.speciesNum ++"/*.scd").postln;
	(~main.dir +/+ "species_" ++ ~main.speciesNum ++ "/*.scd").loadPaths;
	4.0.wait;
	"starting main out".postln;
	~main.mainOut = Synth(\mainOutput, addAction: \addToTail);
}.fork;
)
