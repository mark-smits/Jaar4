+ SequencerPrototype {

	// functions mutating existing information arrays

	resetMutations{
		this.resetPitchMutation;
		this.resetVelocityMutation;
		this.resetOctaveMutation;
		this.resetGateMutation;
		this.resetArticulationMutation;
		this.resetOrnamentationMutation;
		//mutatedTimingArray,
	}

	resetPitchMutation {
		mutatedPitchArray = Array.newFrom(pitchArray.collect({ |input| input.collect({ |input2| input2 }) }));
		mutatedPitchConfirmingArray = Array.newFrom(pitchConfirmingArray.collect({ |input| input.collect({ |input2| input2 }) }));
		mutatedPitchStepsArray = Array.newFrom(pitchStepsArray.collect({ |input| input.collect({ |input2| input2 }) }));
	}

	resetOctaveMutation {
		mutatedOctaveArray = Array.newFrom(octaveArray.collect({ |input| input.collect({ |input2| input2 }) }));

	}

	resetVelocityMutation {
		mutatedVelocityArray = Array.newFrom(velocityArray.collect({ |input| input.collect({ |input2| input2 }) }));
		mutatedVelocitySyncopationArray = Array.newFrom(velocitySyncopationArray.collect({ |input| input.collect({ |input2| input2 }) }));
		mutatedVelocityAccentArray = Array.newFrom(velocityAccentArray.collect({ |input| input.collect({ |input2| input2 }) }));
		mutatedVelocityDynamicsArray = Array.newFrom(velocityDynamicsArray.collect({ |input| input.collect({ |input2| input2 }) }));
	}

	resetGateMutation {
		//mutatedGatelengthArray,
		mutatedGateStaccatoArray = Array.newFrom(gateStaccatoArray.collect({ |input| input.collect({ |input2| input2 }) }));
		mutatedGateSlideArray = Array.newFrom(gateSlideArray.collect({ |input| input.collect({ |input2| input2 }) }));
	}

	resetArticulationMutation {
		mutatedArticulationAccentArray = Array.newFrom(articulationAccentArray.collect({ |input| input.collect({ |input2| input2 }) }));
		mutatedArticulationSlideArray = Array.newFrom(articulationSlideArray.collect({ |input| input.collect({ |input2| input2 }) }));
		mutatedArticulationStaccatoArray = Array.newFrom(articulationStaccatoArray.collect({ |input| input.collect({ |input2| input2 }) }));
	}

	resetOrnamentationMutation {
		mutatedOrnamentationGraceNoteArray = Array.newFrom(ornamentationGraceNoteArray.collect({ |input| input.collect({ |input2| input2 }) }));
		mutatedOrnamentationFigureArray = Array.newFrom(ornamentationFigureArray.collect({ |input| input.collect({ |input2| input2 }) }));
	}

	generalMutate {
		arg arrayIn, amount; // 1, 2 or 3
		var arrayOut;
		arrayOut = Array.newFrom(arrayIn);
		arrayIn.do({
			arg array, index;
			4.do({
				|index2|
				var partialArray;
				partialArray = array[ ( (0..15) + (index2*16) ) ];
				if(amount == 1, {
					var pos1, pos2;
					pos1 = 16.rand;
					pos2 = 16.rand;
					partialArray = partialArray.swap(pos1, pos2);
				}, {
					if(amount == 2, {
						var pos1, pos2;
						pos1 = 16.rand;
						pos2 = 16.rand;
						partialArray = partialArray.swap(pos1, pos2);
						pos1 = 16.rand;
						pos2 = 16.rand;
						partialArray = partialArray.swap(pos1, pos2);
					}, {
						partialArray = partialArray.scramble;
					});
				});
				partialArray.do({
					arg item, index3;
					array[index3 + (16*index2)] = item;
				})
			});
			arrayOut[index] = array;
		});
		^arrayOut;
	}

	mutateVelocitySyncopation {
		arg arrayIn, amount; // 1, 2 or 3
		var arrayOut;
		arrayOut = Array.newFrom(arrayIn);
		arrayIn.do({
			arg array, index;
			4.do({
				|index2|
				var partialArray;
				partialArray = array[ ( (0..15) + (index2*16) ) ];
				if(amount == 1, {
					var pos1, pos2;
					pos1 = 8.rand;
					pos2 = 8.rand;
					partialArray = partialArray.swap(2*pos1, 2*pos2);
					partialArray = partialArray.swap(2*pos1+1, 2*pos2+1);
				}, {
					if(amount == 2, {
						var pos1, pos2;
						pos1 = 8.rand;
						pos2 = 8.rand;
						partialArray = partialArray.swap(2*pos1, 2*pos2);
						partialArray = partialArray.swap(2*pos1+1, 2*pos2+1);
						pos1 = 8.rand;
						pos2 = 8.rand;
						partialArray = partialArray.swap(2*pos1, 2*pos2);
						partialArray = partialArray.swap(2*pos1+1, 2*pos2+1);
					}, {
						var partialArrayBuffer;
						partialArrayBuffer = Array.newFrom(partialArray);
						(0..7).scramble.do({
							arg item, index3;
							partialArray[index3*2] = partialArrayBuffer[item*2];
							partialArray[index3*2+1] = partialArrayBuffer[item*2+1];
						});
					});
				});
				partialArray.do({
					arg item, index3;
					array[index3 + (16*index2)] = item;
				})
			});
			arrayOut[index] = array;
		});
		^arrayOut;
	}

	mutatePitch {
		arg amount; // 1, 2 or 3
		mutatedPitchArray = this.generalMutate(mutatedPitchArray, amount);
		mutatedPitchConfirmingArray = this.generalMutate(mutatedPitchConfirmingArray, amount);
		mutatedPitchStepsArray = this.generalMutate(mutatedPitchStepsArray, amount);
	}

	mutateOctave {
		arg amount; // 1, 2 or 3
		mutatedOctaveArray = this.generalMutate(mutatedOctaveArray, amount);
	}

	mutateVelocity {
		arg amount; // 1, 2 or 3
		mutatedVelocityArray = this.generalMutate(mutatedVelocityArray, amount);
		mutatedVelocitySyncopationArray = this.mutateVelocitySyncopation(mutatedVelocitySyncopationArray, amount);
		mutatedVelocityAccentArray = this.generalMutate(mutatedVelocityAccentArray, amount);
		mutatedVelocityDynamicsArray = this.mutateVelocitySyncopation(mutatedVelocityDynamicsArray, amount);
	}

	mutateGate {
		arg amount; // 1, 2 or 3
		//mutatedGatelengthArray,
		mutatedGateStaccatoArray = this.generalMutate(mutatedGateStaccatoArray, amount);
		mutatedGateSlideArray = this.generalMutate(mutatedGateSlideArray, amount);
	}

	mutateArticulation {
		arg amount;
		mutatedArticulationAccentArray = this.generalMutate(mutatedArticulationAccentArray, amount);
		mutatedArticulationSlideArray = this.generalMutate(mutatedArticulationSlideArray, amount);
		mutatedArticulationStaccatoArray = this.generalMutate(mutatedArticulationStaccatoArray, amount);
	}

	mutateOrnamentation {
		arg amount;
		mutatedOrnamentationGraceNoteArray = this.generalMutate(mutatedOrnamentationGraceNoteArray, amount);
		mutatedOrnamentationFigureArray = this.generalMutate(mutatedOrnamentationFigureArray, amount);
	}

	getMutatedPitchArray {
		^mutatedPitchArray;
	}

	getMutatedPitchConfirmingArray {
		^mutatedPitchConfirmingArray;
	}

	getMutatedPitchStepsArray {
		^mutatedPitchStepsArray;
	}

	getMutatedOctaveArray {
		^mutatedOctaveArray;
	}

	getMutatedVelocityArray {
		^mutatedVelocityArray;
	}

	getMutatedVelocityAccentArray {
		^mutatedVelocityAccentArray;
	}

	getMutatedVelocitySyncopationArray {
		^mutatedVelocitySyncopationArray;
	}

	getMutatedGateStaccatoArray {
		^mutatedGateStaccatoArray;
	}

	getMutatedGateSlideArray {
		^mutatedGateSlideArray;
	}

	getMutatedArticulationAccentArray {
		^mutatedArticulationAccentArray;
	}

	getMutatedArticulationSlideArray {
		^mutatedArticulationSlideArray;
	}

	getMutatedArticulationStaccatoArray {
		^mutatedArticulationStaccatoArray;
	}
}