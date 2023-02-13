+ SequencerPrototype {

	// functions generating velocity information

	calcVelocityArray {
		var order;
		velocityArray = 0!64!dimensionSize;
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
					velocityArray[index+1][ order[index3] + (index2*16) ] = 1; // uncomment for consistent positions from one bar to the next
					// velocityArray[index+1][ order[index3 + (index2*16)] + (index2*16) ] = 1; // uncomment for randomized positions from one bar to the next
				});
			});
		});
	}

	calcVelocityAccentArray {
		velocityAccentArray = 0!64!dimensionSize;
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
					velocityAccentArray[index+1][ order[index3] + (index2*16) ] = 1;
				});
			});
		});
	}

	calcVelocitySyncopationArray {
		var order;
		order = (0..7).scramble;
		// ones kill the note if it has a gate, zeros let it pass
		velocitySyncopationArray = 0!64!dimensionSize;
		(dimensionSize/2).asInteger.do({
			|index|
			var ratio;
			ratio = (index.asFloat + 1)/(dimensionSize - 1)*2.0;
			4.do({
				|index2|
				(ratio*8).asInteger.do({
					|index3|
					velocitySyncopationArray[ (dimensionSize/2).ceil + index ][ (order[index3]*2) + (index2*16) ] = 1;
					velocitySyncopationArray[ (dimensionSize/2).ceil - index - 2][ (order[index3]*2+1) + (index2*16) ] = 1;
				})
			});
		});
	}

	calcVelocityDynamicsArray {
		// two sided dynamics clockwise accents only 8th notes, counterclockwise does both 8th & 16th
		var order1, order2, array1, array2;
		order1 = (0..7).scramble * 2;
		order2 = [(0..7).scramble*2, (0..7).scramble*2+1].lace(16);
		velocityDynamicsArray = 1.0!64!dimensionSize;
		array1 = {0.4.rand}!16; array2 = {0.4.rand}!16;
		{[3, 4, 5].choose}.value.do({
			|index|
			array1[ order1[index] ] = array1[ order1[index] ] + 0.6;
		});
		{[4, 5, 6].choose}.value.do({
			|index|
			array2[ order2[index] ] = array2[ order2[index] ] + 0.6;
		});
		array1 = (array1 ++ array1 ++ array1 ++ array1);
		array2 = (array2 ++ array2 ++ array2 ++ array2);
		(dimensionSize/2).asInteger.do({
			|index|
			var percentage;
			percentage = (index + 1) / (dimensionSize/2).asInteger;
			velocityDynamicsArray[ (dimensionSize/2).ceil + index ] = (array1 * percentage) + (1.0 - percentage);
			velocityDynamicsArray[ (dimensionSize/2).ceil - index - 2] = (array2 * percentage) + (1.0 - percentage);
		});
	}
}