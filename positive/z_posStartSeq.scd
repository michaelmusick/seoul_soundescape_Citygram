(
{
	if( ~voice==0, {
		0.5.wait;
		Pdef(\chirping_sparrow).play;
		0.5.wait;
		Pdef(\yellow_warbler).play;
		0.5.wait;
		Pdef(\orchard_oriele).play;
		0.5.wait;
		Pdef(\cassins_kingbird).play;
		0.5.wait;
		Pdef(\windchimes_high).play;
		0.5.wait;
	});

	Pdef(\windchimes).play;
	0.5.wait;
	Pdef(\woodchimes).play;

}.fork;
);


(
if( ~voice==0, {
	~birdCheck = Task({
		inf.do({
			0.5.wait;
			if(Pdef(\chirping_sparrow).isPlaying.not, {	Pdef(\chirping_sparrow).play; });
			0.5.wait;
			if(Pdef(\yellow_warbler).isPlaying.not, {	Pdef(\yellow_warbler).play; });
			0.5.wait;
			if(Pdef(\orchard_oriele).isPlaying.not, {	Pdef(\orchard_oriele).play; });
			0.5.wait;
			if(Pdef(\cassins_kingbird).isPlaying.not, {	Pdef(\cassins_kingbird).play; });


			10.0.wait;
		});
	}).start;
});
);