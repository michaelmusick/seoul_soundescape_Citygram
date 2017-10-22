~der[2].dump

~cgData[0][~der[2].asInteger][~der[3].asSymbol]
~cgData[0][~der[2].asInteger].keysValuesDo({|key, item, num| key.postln; item.postln; num.postln;})
(
~cgData[0].keysValuesDo( {|key, item, num|

	key.postln;
	item.postln;
	// item[\FD_SpectralCentroid][\min].postln;
	num.postln;
	"".postln;
})
)

a = 2;
a = a + 2

a = {|val| val.postln;}

a.(3)

~cgData[0][1488].keysValuesDo({|key, item, num| key.postln; item.postln; num.postln;})
~cgData[0][1186][\TD_ZCR][\avg]
~cgData[3].asString
~cgData[3].size
~cgData.size
~cgData[1][1433].size

~der[3].asSymbol == 'time'

~cgData[0].keysValuesDo({|key, item, num| key.postln; item.postln; num.postln;})



a = ();

b = List.new();

a[~der[2]] = ~der[3]

a[~der[1]] = ~der[3]


a.keysValuesDo({|key, item, num| key.postln; item.postln; num.postln;})



~cgData

~dataPtr = 1;



~der[2].asInteger > 0



(
if( ~cgData[~dataPtr][~der[2]].isNil, {
	~cgData[~dataPtr][~der[2]] = ();
});


if( ~cgData[~dataPtr][~der[2]][~der[3]].isNil, {
	~cgData[~dataPtr][~der[2]][~der[3]] = ();
});

~cgData[~dataPtr][~der[2]][~der[3]][~der[4]] = 4;


)

~cgData[0][1488]

a

~cgGroupData[3].asString

~cgGroupData[3].keysValuesDo({|key, item, num| key.postln; item.postln; "".postln;})
