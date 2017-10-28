~main.serverCheck = Task({
	inf.do({
		if( (s.serverRunning.not || s.unresponsive), {
			{
				// "stopped, trying to restart".postln;
				~routineGliss.stop;
				~main.serverCheck.stop;
				Pdef.removeAll;
				OSCdef.freeAll;
				Server.hardFreeAll;
				Server.killAll;
				2.wait;
				thisProcess.recompile;


				// 10.wait;
				// s.boot;
				// 10.wait;
				// s.doWhenBooted({
				// 	(~thisPath +/+ "start.scd").loadPaths;
				// });
			}.fork;
		});
		1.0.wait;
	});
}).start;