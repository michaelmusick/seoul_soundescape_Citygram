/**************************************************************

 Project: Citygram - Seoul Soundescape Installation

  Author: The Citygram Team
   Email: thp1@nyu.edu
   Email: michael@michaelmusick.com

 Created: October 22nd, 2017

   Notes: Data Handling from CG_Bridge.app

**************************************************************/


/*****************************************************
DATA EXAMPLES


~cgData[~dataPtr] =
(
1186: (
'FD_SpectralCentroid': (
'min': 56.192840576172,
'max': 137.00576782227,
'avg': 80.632247924805
),
'time': 1506489283,
'FD_SpectralFlatness': (
'min': 149.61347961426,
'max': 593.07214355469,
'avg': 307.48669433594
),
'TD_TemporalCentroid': (
'min': 438.37475585938,
'max': 566.162109375,
'avg': 510.4541015625
),
'TD_RMS': (
'min': 0.00011242365144426,
'max': 0.00075567944440991,
'avg': 0.00032108792220242
),
'TD_ZCR': (
'avg': 107.28260803223,
'max': 236,
'min': 66
)
),

1257: (
// etc
)
)

// To Access: ~cgData[0][1186][\TD_RMS][\avg] -> return RMS avg for RSD#1186

*****************************************************
~cgGroupData[~dataPtr] =
(
'activeRSDs': 21,
'FD_SpectralSpread': (
'max': 1941853.75,
'min': 0.11982896178961,
'avg': 120023.08511454
),
'FD_SpectralCentroid': (
'max': 631.08825683594,
'min': 15.335188865662,
'avg': 163.88853236607
),
'FD_SpectralFlatness': (
'max': 6163.6000976562,
'min': 0.0025704214349389,
'avg': 513.28233830182
),
'TD_TemporalCentroid': (
'max': 2889.2829589844,
'min': 91.820152282715,
'avg': 1114.3681393578
),
'TD_RMS': (
'max': 0.20308877527714,
'min': 3.5658933484228e-05,
'avg': 0.0047855373004928
),
'TD_ZCR': (
'max': 0.20308877527714,
'min': 3.5658933484228e-05,
'avg': 0.0047855373004928
)
)

To Acces: ~cgGroupData[0][\activeRSDs]  -> returns active number of RSDs
To Access: ~cgGroupData[0][\TD_RMS][\avg] -> returns avg for RSDs in data dump


*****************************************************/


(

// ---------------------------------------------------------------
//                    Global Variables
// ---------------------------------------------------------------
var computeAvg;

// Open a UDP Port to recieve data from CG_Bridge.app
~osc_portIn = 9999;
thisProcess.openUDPPort(~osc_portIn);


// ---------------------------------------------------------------
//                    Cleanup
// ---------------------------------------------------------------
// insure that nothing is left.
thisProcess.removeOSCRecvFunc(~cg_data_func);


// ---------------------------------------------------------------
//                    Data Handler Functions
// ---------------------------------------------------------------
// Data is stored within environment dictionaries

// A data struct to hold Individual RSD data
~cgData = Array.fill(4, {()});
// a data struct to hold group data
~cgGroupData = Array.fill(4, {()});
// a pointer to move through the 4 array positions
~dataPtr = 0;


/********************    MAIN FUNCTION    ********************/
// This is called by SC EVERYTIME a new OSC msg comes in
~cg_data_func = {
	arg msg, time, addr, recvPort;

	// TEST PRINT
	// 	msg.postln;
	// 	time.postln;
	// 	addr.postln;
	// 	recvPort.postln;
	// });

	// Case = switch statement or multi-if
	case(

		/* CHECK IF END OF DATA PACKET FROM SERVER */
		{ msg[0] == '/citygram/endPacket' },
		{
			// REMOVE RSDS THAT HAD NO VALUE AND SLIPPED THROUGH
			~cgData[~dataPtr].keysValuesDo({
				|key, item, num|
				if( item.size <= 1, {
					~cgData[~dataPtr].removeAt(key);
				} )
			});

			// create a new lazyenvironment to store group RSD data
			~cgGroupData[~dataPtr] = (
				// number of active RSDs
				\activeRSDs: ~cgData[~dataPtr].size;
			);

			// Computer and assign avg/min/max or each feature to group environment
			computeAvg.(\TD_ZCR, ~cgData[~dataPtr], ~cgGroupData[~dataPtr]);
			computeAvg.(\FD_SpectralFlatness, ~cgData[~dataPtr], ~cgGroupData[~dataPtr]);
			computeAvg.(\FD_SpectralSpread, ~cgData[~dataPtr], ~cgGroupData[~dataPtr]);
			computeAvg.(\FD_SpectralCentroid, ~cgData[~dataPtr], ~cgGroupData[~dataPtr]);
			computeAvg.(\TD_TemporalCentroid, ~cgData[~dataPtr], ~cgGroupData[~dataPtr]);
			computeAvg.(\TD_RMS, ~cgData[~dataPtr], ~cgGroupData[~dataPtr]);


			// let other processes know new data is ready
			NetAddr.localAddr.sendMsg(\newDataReady, ~dataPtr);

			// increment data pointer
			~dataPtr = (~dataPtr + 1) % ~cgData.size;
		},

		/* General OSC Data Handling */
		{ msg[0].asString.contains("/citygram") },
		{
			// create an array of info from OSC addr
			// Will look like ->
			// [ "", citygram, RSD-ID, Feature, value-type ]
			// [   , citygram, 1447,   TD_RMS,  avg        ]
			// [   , citygram, 1447,   time   ]
			var msgDets = msg[0].asString.split($/);

			// TEST PRINT
			// msg.postln;
			// time.postln;
			// addr.postln;
			// recvPort.postln;

			// Check that data is valid
			if( msgDets[2].asInteger > 0 && msg[1].asFloat != 0 && msg[1].notNil, {
				// Get RSD ID Number
				var rsdId = msgDets[2].asInteger;
				// initialize temp envir var
				var envir = ();

				// if nil, then no data has come in yet
				if( ~cgData[~dataPtr][rsdId].isNil, {
					// create nested environment to store data
					~cgData[~dataPtr][rsdId] = ();
				});
				// grab a reference to the specific environment
				envir = ~cgData[~dataPtr][rsdId];

				// if any feature OTHER THAN 'time'
				if( msgDets[3].asSymbol != 'time', {
					// get feature name
					var feat = msgDets[3].asSymbol;
					// feat.postln;

					// if no data has come in yet, create nested environment for storage
					if( envir[feat].isNil, {
						envir[feat] = ();
					});

					// store min, max, avg data values in environment
					if( msgDets[4].notNil, {
						var minMaxAvg = msgDets[4].asSymbol;
						envir[feat][minMaxAvg] = msg[1].asFloat;
					});
				});

				// if feature is a timestamp
				if( msgDets[3].asSymbol == 'time', {
					// msg.postln;
					envir['time'] = msg[1].asFloat;
				});

			});
		} // END -> General OSC Data Handling
	); // END -> Case
};

/* Find/Compute avg & min/max for each feature */
/* This is for all RSDs in a server data dump */
computeAvg = {
	arg feat, data, groupData;
	var avg = 0, cnt = 0, max = 0, min = 100000;

	// for each RSD
	data.keysValuesDo({
		|key, item, num|

		// check that the feature value is not empty
		if( item[feat].notNil, {

			// computer average for feature
			if( item[feat][\avg].notNil, {
				// item[feat][\avg].postln;
				avg = avg + item[feat][\avg].asFloat;
				cnt = cnt + 1;
			});

			// find min for feature
			if( item[feat][\min].notNil, {
				if( item[feat][\min].asFloat < min, {
					min = item[feat][\min].asFloat;
				})
			});

			// find the max for the feature
			if( item[feat][\max].notNil, {
				if( item[feat][\max].asFloat > max, {
					max = item[feat][\max].asFloat;
				})
			});
		});
	});

	// compute avg
	avg = avg / cnt;

	// if avg == 0, then data was bad
	if( avg > 0, {
		// store data in group data
		groupData[feat] = ( avg: avg, min: min, max: max );
	});
};


// ---------------------------------------------------------------
//                    Start OSC listener
// ---------------------------------------------------------------
thisProcess.addOSCRecvFunc(~cg_data_func);

)


/*
// STOP PROCESSING
thisProcess.removeOSCRecvFunc(~cg_data_func);
*/