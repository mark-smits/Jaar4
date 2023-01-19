+ SequencerPrototype {

	// functions generating pitch information

	calcPitchArray {
		var order;
		// pitchArray = {{1.0.rand}!64}!dimensionSize; // uncomment for randomized pitches for each array in randomness macro
		pitchArray = {1.0.rand}!64!dimensionSize; // uncomment for consistent pitches for each array in randomness macro
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
					pitchArray[index+1][ order[index3] + (index2*16) ] = 0.0; // uncomment for consistent root note positions from one bar to the next
					// pitchArray[index+1][ order[index3 + (index2*16)] + (index2*16) ] = 0.0; // uncomment for randomized root note positions from one bar to the next
				});
			});
		});
		pitchArray = pitchArray.reverse;
	}

	calcPitchConfirming {
		var permutation, permutation2;
		permutation = 16.0.factorial.rand.asInteger;
		permutation2 = 16.0.factorial.rand.asInteger;
		pitchConfirmingArray = 0!64!dimensionSize;
		(dimensionSize/2).asInteger.do({
			|index|
			var ratio, array, array2;
			ratio = (index.asFloat + 1)/(dimensionSize - 1)*2.0;
			array = 1!((ratio*16).asInteger) ++ (0!(16-((ratio*16).asInteger))).asArray;
			array2 = array.permute(permutation2);
			array = array.permute(permutation);
			pitchConfirmingArray[ (dimensionSize/2).ceil + index ] = array ++ array ++ array ++ array;
			pitchConfirmingArray[ (dimensionSize/2).ceil - index - 2 ] = (array2 ++ array2 ++ array2 ++ array2) * -1;
		});
	}

	calcPitchSteps {
		var permutation, permutation2;
		permutation = 16.0.factorial.rand.asInteger;
		permutation2 = 16.0.factorial.rand.asInteger;
		pitchStepsArray = 0!64!dimensionSize;
		(dimensionSize/2).asInteger.do({
			|index|
			var ratio, array, array2;
			ratio = (index.asFloat + 1.0)/(dimensionSize-1)*2.0;
			array = 1!((ratio*16).asInteger) ++ (0!(16-((ratio*16).asInteger))).asArray;
			array2 = array.permute(permutation2);
			array = array.permute(permutation);
			// if randomized is desired use: = array.scramble ++ array.scramble ++ array.scramble ++ array.scramble
			pitchStepsArray[ (dimensionSize/2).ceil + index ] = array ++ array ++ array ++ array;
			pitchStepsArray[ (dimensionSize/2).ceil - index - 2 ] = (array2 ++ array2 ++ array2 ++ array2) * -1;
		});
	}

	translateTonality {
		arg pitch, steps, confirming; // 0.0-1.0
		var index, note;

		pitch = pitch.clip(0.0, 1.0);
		index = pitch * (scale.size-1);
		index = index.asInteger;

		if(lastPitchIndex.isNil.not, {
			var diff;
			diff = index - lastPitchIndex;
			// calc jumps or steps
			if(steps == -1, {
				// force jump
				if(diff.abs < 2, {
					index = index + ([1, 2, 3].choose * diff.sign);
				});
			});
			if(steps == 1, {
				// force step
				index = lastPitchIndex + diff.sign;
			});
			index = index.clip(0, (scale.size-1));
		});

		if(confirming == -1, {
			// deny tonality
			if([7, 8, 9].includes(scale.size), { // penta scales are too small every note is confirming and larger scales than 8 notes (+ oct) are too big for conventional scale confirming
				if([2, 4, (scale.size-1)].includes(index), {
					// 3rd, 5th or octave are pushed down, root remains otherwise you're confirming a different scale
					index = index - 1;
				});
			});
		});
		if(confirming == 1, {
			// confirm tonality
			if([7, 8, 9].includes(scale.size), { // penta scales are too small every note is confirming and larger scales than 8 notes (+ oct) are too big for conventional scale confirming
				if([0, 2, 4, (scale.size-1)].includes(index).not, {
					index = index - 1;
				});
			});
		});

		note = root + octave_offset + scale[index];
		lastPitchIndex = index;
		^note;
	}
}