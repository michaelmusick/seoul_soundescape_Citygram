(
c = Pdef(
	key: \main,
	item: Pbind(
		\instrument, \chimes,
		\scale, #[0, 2, 4, 5, 7, 9, 11],
		\root, Pdefn(\root, 0),
		\octave, Pdefn(\octave, 4),
		\degree, Pdefn(\degree),
		\attackTime, Pdefn(\attack, 0.5),
		\dur, Pdefn(\dur, 0.25),
		\length, Pdefn(\legato, 0.9),
		\pan, 0
	)
).play;


)


Pdefn(\dur, Prand([1, Pseq([0.25, 0.5, 0.25],1), 1, 1, 2], inf) );
Pdefn(\legato, 1)


Pbindef(\main, \instrument, \woodBlock)







// map features to the pattern
~dataTask = Task({
	inf.do({
		// pull the last 12 values [everything accept the 1st coefficient,
		//							which primarily maps to intensity]

		// voice 1
		d = ~cg_p.mfccVal[1..12];

		// get peaks from the 12 value array
		// this is a simple peak picking algorithm
		//  it just looks to see that a value is higher
		// than both of its neighbors
		g = Array.new(12);
		d.do({
			|val, pos, thresh=2|
			// first position
			if(pos==0, {
				if( (val>d[pos+1]),
					{pos.postln; g=g.add(pos);}
				)
			});
			// middle positions
			if((pos>0).and(pos<(d.size-2)), {
				if( (val>d[pos-1]).and(val>d[pos+1]),
					{pos.postln; g=g.add(pos);}
				)
			});
			// last position
			if(pos==(d.size-1), {
				if( (val>d[pos-1]),
					{pos.postln; g=g.add(pos);}
				)
			});
		});


		// assign the mfcc coefficients to a 0-12 scale degree map
		~cg_p.slopeVal.postln;

		if( ~cg_p.slopeVal>0.0002, {Pdefn(\degree1, Pseq( g, inf ) )} );
		if( (~cg_p.slopeVal<0.0002).and(~cg_p.slopeVal>(-0.0002)),
			{Pdefn(\degree1, Prand( g, inf ) )});
		if( ~cg_p.slopeVal<(-0.0002), {Pdefn(\degree1, Pseq( g.reverse, inf ) )});

		// Pdefn(\degree, Pseq( g, inf ) );

		// assign the centroid to the octave
		Pdefn(\octave1, (~cg_p.centroidVal / 1000).round);

		// spectralFlatness -> attackTime
		Pdefn(\attackTime1, ~cg_p.flatnessVal*2);

		// degree
		Pdefn(\degree1, ((~cg_p.crestVal/4)%8).round);

		// spectralFlux -> dur
		Pdefn(\dur1, Pn( Pconst(4+~cg_p.powerVal, Pwhite(1, 2, inf)*0.25 )));


		// voice c
		e = ~cg_c.mfccVal[1..12];

		// get peaks from the 12 value array
		// this is a simple peak picking algorithm
		//  it just looks to see that a value is higher
		// than both of its neighbors
		f = Array.new(12);
		e.do({
			|val, pos, thresh=2|
			// first position
			if(pos==0, {
				if( (val>e[pos+1]),
					{pos.postln; f=f.add(pos);}
				)
			});
			// middle positions
			if((pos>0).and(pos<(e.size-2)), {
				if( (val>e[pos-1]).and(val>e[pos+1]),
					{pos.postln; f=f.add(pos);}
				)
			});
			// last position
			if(pos==(e.size-1), {
				if( (val>e[pos-1]),
					{pos.postln; f=f.add(pos);}
				)
			});
		});


		// assign the mfcc coefficients to a 0-12 scae degree map
		~cg_c.slopeVal.postln;

		if( ~cg_c.slopeVal>0.0002, {Pdefn(\degree2, Pseq( f, inf ) )} );
		if( (~cg_c.slopeVal<0.0002).and(~cg_c.slopeVal>(-0.0002)),
			{Pdefn(\degree2, Prand( f, inf ) )});
		if( ~cg_c.slopeVal<(-0.0002), {Pdefn(\degree2, Pseq( f.reverse, inf ) )});

		// Pdefn(\degree, Pseq( g, inf ) );

		// assign the centroid to the octave
		Pdefn(\octave2, (~cg_c.centroidVal / 1000).round);

		// spectralFlatness -> attackTime
		Pdefn(\attackTime2, ~cg_c.flatnessVal*2);

		// degree
		Pdefn(\degree2, ((~cg_c.crestVal/4)%8).round);

		// spectralFlux -> dur
		Pdefn(\dur2, Pn( Pconst(4+~cg_c.powerVal, Pwhite(1, 2, inf)*0.25 )));


		0.5.wait;
	});
}).start;
)