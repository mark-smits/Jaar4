+ SequencerPrototype {

	// functions for updating the dictionary for the UI

	updateDict1 {
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
		// dimensions (0-15)
		paramDict[\dimensionSize] = dimensionSize;
		paramDict[\pitchRandom] = pitchRandom;
		paramDict[\pitchSteps] = pitchSteps;
		paramDict[\pitchConfirming] = pitchConfirming;
		paramDict[\pitchTonality] = pitchTonality;
		paramDict[\octaveDensity] = octaveDensity;
		paramDict[\octaveProbability] = octaveProbability;
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
}