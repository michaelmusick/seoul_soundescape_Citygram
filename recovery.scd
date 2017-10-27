~main.serverCheck = Task({
	inf.do({
		if( (s.serverRunning.not || s.unresponsive), {
			{
				"stopped, trying to restart".postln;
				Server.killAll;
				Pdef.removeAll;
				~routineGliss.stop;
				~main.serverCheck.stop;

				10.wait;
				s.boot;
				10.wait;
				s.doWhenBooted({
					~thisPath = "/home/pi/soundescape/";
					(~thisPath +/+ "/start.scd").loadPaths;
				});
			}.fork;
		});
		1.0.wait;
	});
}).start;