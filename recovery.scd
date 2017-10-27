~main.serverCheck = Task({
	inf.do({
		if( (s.serverRunning.not || s.unresponsive), {
			~boot.();
		});
		1.0.wait;
	});
}).start;

~boot = {
	{
		"stopped, trying to restart".postln;
		~routineGliss.stop;
		~main.serverCheck.stop;
		Pdef.removeAll;
		OSCdef.freeAll;
		Server.hardFreeAll;
		1.0.wait;
		Server.killAll;


		10.wait;
		s.boot( recover: true );
		10.wait;
		s.waitForBoot(
			{
				(~thisPath +/+ "start.scd").loadPaths;
			},
			limit: 10
		);
	}.fork;
};