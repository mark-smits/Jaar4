+ SequencerPrototype {

	// functions generating octave information

	calcOctaveArray {
		var oct, order, array, chance = 90;
		octaveArray = 0!64!dimensionSize;
		order = (0..15).scramble;
		order = order ++ order.scramble;
		order = order ++ order.scramble;
		array = 0!64;
		64.do({
			|index|
			oct = 0;
			if(100.rand<chance.linlin(0,dimensionSize,10,30),{ oct = oct+1 });
			if(100.rand<chance.linlin(0,dimensionSize,10,30),{ oct = oct+1 });
			array[index] = oct * [-1, -1, 0, 1, 1].choose;
		});
		(dimensionSize-1).do({
			|index|
			var ratio;
			ratio = (index.asFloat + 1.0)/(dimensionSize-1);
			octaveArray[dimensionSize - index - 1] = array.collect({ |in| in; });
			4.do({
				|index2|
				(ratio*16).asInteger.do({
					|index3|
					octaveArray[dimensionSize - index - 1][ order[index3] + (index2*16) ] = 0; // uncomment for consistent root note positions from one bar to the next
					// octaveArray[dimensionSize - index - 1][ order[index3 + (index2*16)] + (index2*16) ] = 0; // uncomment for randomized root note positions from one bar to the next
				});
			});
		});
	}
}