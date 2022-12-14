+ SequencerPrototype {

	// functions generating articulation information

	calcArticulationStaccatoArray {
		var order;
		articulationStaccatoArray = 0!64!dimensionSize;
		order = (0..15).scramble;
		order = order ++ order.scramble;
		order = order ++ order.scramble;
		(dimensionSize-1).do({
			|index|
			var ratio;
			ratio = (index.asFloat + 1.0)/(dimensionSize-1);
			4.do({
				|index2|
				(ratio*16).asInteger.do({
					|index3|
					articulationStaccatoArray[index+1][ order[index3] + (index2*16) ] = 1; // uncomment for consistent positions from one bar to the next
					// articulationStaccatoArray[index+1][ order[index3 + (index2*16)] + (index2*16) ] = 1; // uncomment for randomized positions from one bar to the next
				});
			});
		});
	}

	calcArticulationSlideArray {
		var order;
		articulationSlideArray = 0!64!dimensionSize;
		order = (0..15).scramble;
		order = order ++ order.scramble;
		order = order ++ order.scramble;
		(dimensionSize-1).do({
			|index|
			var ratio;
			ratio = (index.asFloat + 1.0)/(dimensionSize-1);
			4.do({
				|index2|
				(ratio*16).asInteger.do({
					|index3|
					articulationSlideArray[index+1][ order[index3] + (index2*16) ] = 1; // uncomment for consistent positions from one bar to the next
					// articulationSlideArray[index+1][ order[index3 + (index2*16)] + (index2*16) ] = 1; // uncomment for randomized positions from one bar to the next
				});
			});
		});
	}

	calcArticulationAccentArray {
		var order;
		articulationAccentArray = 0!64!dimensionSize;
		order = (0..15).scramble;
		order = order ++ order.scramble;
		order = order ++ order.scramble;
		(dimensionSize-1).do({
			|index|
			var ratio;
			ratio = (index.asFloat + 1.0)/(dimensionSize-1);
			4.do({
				|index2|
				(ratio*16).asInteger.do({
					|index3|
					articulationAccentArray[index+1][ order[index3] + (index2*16) ] = 1; // uncomment for consistent positions from one bar to the next
					// articulationAccentArray[index+1][ order[index3 + (index2*16)] + (index2*16) ] = 1; // uncomment for randomized positions from one bar to the next
				});
			});
		});
	}
}