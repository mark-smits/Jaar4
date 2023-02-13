+ SequencerPrototype {

	// functions generating gate information

	calcGateStaccatoArray {
		gateStaccatoArray = 0!64!dimensionSize;
		(dimensionSize-1).do({
			|index|
			var ratio, order;
			ratio = (index.asFloat + 1.0)/(dimensionSize-1);
			order = (0..15).scramble;
			4.do({
				|index2|
				order = order.scramble; // uncomment to randomize root note positions from one bar to the next
				(ratio*16).asInteger.do({
					|index3|
					gateStaccatoArray[index+1][ order[index3] + (index2*16) ] = 1;
				});
			});
		});
	}

	calcGateSlideArray {
		gateSlideArray = 0!64!dimensionSize;
		(dimensionSize-1).do({
			|index|
			var ratio, order;
			ratio = (index.asFloat + 1.0)/(dimensionSize-1);
			order = (0..15).scramble;
			4.do({
				|index2|
				order = order.scramble; // uncomment to randomize root note positions from one bar to the next
				(ratio*16).asInteger.do({
					|index3|
					gateSlideArray[index+1][ order[index3] + (index2*16) ] = 1;
				});
			});
		});
	}
}