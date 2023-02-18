+ SequencerPrototype {

	// functions for updating the dictionary for the UI

	updateDict1 {
		// update the arrays for the UI
		paramDict[\mutatedPitchArray] = mutatedPitchArray;
		paramDict[\mutatedPitchConfirmingArray] = mutatedPitchConfirmingArray;
		paramDict[\mutatedPitchStepsArray] = mutatedPitchStepsArray;
		paramDict[\mutatedOctaveArray] = mutatedOctaveArray;
		paramDict[\mutatedVelocityArray] = mutatedVelocityArray;
		paramDict[\mutatedVelocitySyncopationArray] = mutatedVelocitySyncopationArray;
		paramDict[\mutatedVelocityDynamicsArray] = mutatedVelocityDynamicsArray;
		paramDict[\mutatedArticulationStaccatoArray] = mutatedArticulationStaccatoArray;
		paramDict[\mutatedArticulationSlideArray] = mutatedArticulationSlideArray;
		paramDict[\mutatedArticulationAccentArray] = mutatedArticulationAccentArray;
		paramDict[\mutatedOrnamentationGraceNoteArray] = mutatedOrnamentationGraceNoteArray;
		paramDict[\mutatedOrnamentationFigureArray] = mutatedOrnamentationFigureArray;
	}

	updateDict2 {
		// initial dimensions
		// dimensions (0-15)
		paramDict[\dimensionSize] = dimensionSize;
		paramDict[\pitchRandom] = pitchRandom;
		paramDict[\pitchSteps] = pitchSteps;
		paramDict[\pitchConfirming] = pitchConfirming;
		paramDict[\pitchTonality] = pitchTonality;
		paramDict[\octaveDensity] = octaveDensity;
		paramDict[\octaveProbability] = octaveProbability;
		paramDict[\octaveOffset] = octave_offset;
		paramDict[\velocitySyncopation] = velocitySyncopation;
		paramDict[\velocityDensity] = velocityDensity;
		paramDict[\velocityProbability] = velocityProbability;
		paramDict[\velocityDynamics] = velocityDynamics;
		paramDict[\articulationStaccatoDensity] = articulationStaccatoDensity;
		paramDict[\articulationSlideDensity] = articulationSlideDensity;
		paramDict[\articulationAccentDensity] = articulationAccentDensity;
		paramDict[\ornamentationGraceNotes] = ornamentationGraceNotes;
		paramDict[\ornamentationFigures] = ornamentationFigures;
		paramDict[\ornamentationPolyphony] = ornamentationPolyphony;
		paramDict[\timingSwing] = timingSwing;
		paramDict[\timingRubato] = timingRubato;
		// indices
		paramDict[\pitchIndex] = pitchIndex;
		paramDict[\octaveIndex] = octaveIndex;
		paramDict[\velocityIndex] = velocityIndex;
		paramDict[\articulationIndex] = articulationIndex;
		paramDict[\ornamentationIndex] = ornamentationIndex;
		paramDict[\timingIndex] = timingIndex;
		paramDict[\pitchReset] = pitchReset;
		paramDict[\velocityReset] = velocityReset;
		paramDict[\octaveReset] = octaveReset;
		paramDict[\articulationReset] = articulationReset;
		paramDict[\ornamentationReset] = ornamentationReset;
		paramDict[\timingReset] = timingReset;
		// arrays
		paramDict[\timingArray] = timingArray;
	}

	updateDict3 {
		// just indices for the UI
		paramDict[\pitchIndex] = pitchIndex;
		paramDict[\octaveIndex] = octaveIndex;
		paramDict[\velocityIndex] = velocityIndex;
		paramDict[\articulationIndex] = articulationIndex;
		paramDict[\ornamentationIndex] = ornamentationIndex;
		paramDict[\timingIndex] = timingIndex;
	}
}

+ SequencerUIPrototype {

	updateDict {
		//paramDict[\dimensionSize] = dimensionSize;
		paramDict[\pitchRandom] = (paramDict[\dimensionSize]*p1KnobVals[0][0] - 0.001).asInteger;
		paramDict[\pitchSteps] = (paramDict[\dimensionSize]*p1KnobVals[0][1] - 0.001).asInteger;
		paramDict[\pitchConfirming] = (paramDict[\dimensionSize]*p1KnobVals[0][2] - 0.001).asInteger;
		//paramDict[\pitchTonality] = pitchTonality;
		paramDict[\octaveDensity] = (paramDict[\dimensionSize]*p1KnobVals[2][0] - 0.001).asInteger;
		paramDict[\octaveProbability] = (paramDict[\dimensionSize]*p1KnobVals[2][1] - 0.001).asInteger;
		paramDict[\octaveOffset] = [24, 36, 48, 60, 72].at((4.999*p1KnobVals[2][3]).asInteger);
		paramDict[\velocitySyncopation] = (paramDict[\dimensionSize]*p1KnobVals[1][2] - 0.001).asInteger;
		paramDict[\velocityDensity] = (paramDict[\dimensionSize]*p1KnobVals[1][0] - 0.001).asInteger;
		paramDict[\velocityProbability] = p1KnobVals[1][1];
		paramDict[\velocityDynamics] = (paramDict[\dimensionSize]*p1KnobVals[1][3] - 0.001).asInteger;
		paramDict[\articulationStaccatoDensity] = (paramDict[\dimensionSize]*p1KnobVals[3][0] - 0.001).asInteger;
		paramDict[\articulationSlideDensity] = (paramDict[\dimensionSize]*p1KnobVals[3][1] - 0.001).asInteger;
		paramDict[\articulationAccentDensity] = (paramDict[\dimensionSize]*p1KnobVals[3][2] - 0.001).asInteger;
		paramDict[\ornamentationGraceNotes] = (paramDict[\dimensionSize]*p1KnobVals[4][0] - 0.001).asInteger;
		paramDict[\ornamentationFigures] = (paramDict[\dimensionSize]*p1KnobVals[4][1] - 0.001).asInteger;
		paramDict[\ornamentationPolyphony] = (paramDict[\dimensionSize]*p1KnobVals[4][2] - 0.001).asInteger;
		paramDict[\timingSwing] = p1KnobVals[5][0];
		paramDict[\timingRubato] = p1KnobVals[5][1];
	}
}