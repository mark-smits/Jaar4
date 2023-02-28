+ SequencerPrototype {

	// functions for updating the dictionary for the UI

	updateDictArrays {
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
		paramDict[\timingArray] = timingArray;
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
		// mutations
		paramDict[\pitchMutation] = pitchMutation;
		paramDict[\velocityMutation] = velocityMutation;
		paramDict[\octaveMutation] = octaveMutation;
		paramDict[\articulationMutation] = articulationMutation;
		paramDict[\ornamentationMutation] = ornamentationMutation;
		// arrays
		paramDict[\timingArray] = timingArray;
	}

	updateDictIndices {
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
		// arrays
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
		// lengths
		paramDict[\pitchReset] = (63.0*p1MiniKnobVals[0][0] + 1.001).asInteger;
		paramDict[\octaveReset] =  (63.0*p1MiniKnobVals[2][0] + 1.001).asInteger;
		paramDict[\velocityReset] = (63.0*p1MiniKnobVals[1][0] + 1.001).asInteger;
		paramDict[\articulationReset] = (63.0*p1MiniKnobVals[3][0] + 1.001).asInteger;
		paramDict[\ornamentationReset] = (63.0*p1MiniKnobVals[4][0] + 1.001).asInteger;
		// mutations
		paramDict[\pitchMutation] = (4.0*p1MiniKnobVals[0][1] - 0.001).asInteger;
		paramDict[\velocityMutation] = (4.0*p1MiniKnobVals[1][1] - 0.001).asInteger;
		paramDict[\octaveMutation] = (4.0*p1MiniKnobVals[2][1] - 0.001).asInteger;
		paramDict[\articulationMutation] = (4.0*p1MiniKnobVals[3][1] - 0.001).asInteger;
		paramDict[\ornamentationMutation] = (4.0*p1MiniKnobVals[4][1] - 0.001).asInteger;
	}

	updateDictMacros {
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

	updateDictResets {
		paramDict[\pitchReset] = (63.0*p1MiniKnobVals[0][0] + 1.001).asInteger;
		paramDict[\octaveReset] =  (63.0*p1MiniKnobVals[2][0] + 1.001).asInteger;
		paramDict[\velocityReset] = (63.0*p1MiniKnobVals[1][0] + 1.001).asInteger;
		paramDict[\articulationReset] = (63.0*p1MiniKnobVals[3][0] + 1.001).asInteger;
		paramDict[\ornamentationReset] = (63.0*p1MiniKnobVals[4][0] + 1.001).asInteger;
	}

	updateDictMutations {
		paramDict[\pitchMutation] = (4.0*p1MiniKnobVals[0][1] - 0.001).asInteger;
		paramDict[\velocityMutation] = (4.0*p1MiniKnobVals[1][1] - 0.001).asInteger;
		paramDict[\octaveMutation] = (4.0*p1MiniKnobVals[2][1] - 0.001).asInteger;
		paramDict[\articulationMutation] = (4.0*p1MiniKnobVals[3][1] - 0.001).asInteger;
		paramDict[\ornamentationMutation] = (4.0*p1MiniKnobVals[4][1] - 0.001).asInteger;
	}

	updateDictLocks {
		paramDict[\pitchLockPulses] = p3MiniKnobVals[0][0];
		paramDict[\pitchLockRotation] = p3MiniKnobVals[0][1];
		paramDict[\pitchSequenceReset] = (63.99*p3MiniKnobVals[0][2]+1).asInteger;
		paramDict[\velocityLockPulses] = p3MiniKnobVals[1][0];
		paramDict[\velocityLockRotation] = p3MiniKnobVals[1][1];
		paramDict[\velocitySequenceReset] = (63.99*p3MiniKnobVals[1][2]+1).asInteger;
		paramDict[\octaveLockPulses] = p3MiniKnobVals[2][0];
		paramDict[\octaveLockRotation] = p3MiniKnobVals[2][1];
		paramDict[\octaveSequenceReset] =(63.99* p3MiniKnobVals[2][2]+1).asInteger;
		paramDict[\articulationLockPulses] = p3MiniKnobVals[3][0];
		paramDict[\articulationLockRotation] = p3MiniKnobVals[3][1];
		paramDict[\articulationSequenceReset] = (63.99*p3MiniKnobVals[3][2]+1).asInteger;
		paramDict[\ornamentationLockPulses] = p3MiniKnobVals[4][0];
		paramDict[\ornamentationLockRotation] = p3MiniKnobVals[4][1];
		paramDict[\ornamentationSequenceReset] = (63.99*p3MiniKnobVals[4][2]+1).asInteger;
		paramDict[\timingLockPulses] = p3MiniKnobVals[5][0];
		paramDict[\timingLockRotation] = p3MiniKnobVals[5][1];
		paramDict[\timingSequenceReset] = (63.99*p3MiniKnobVals[5][2]+1).asInteger;
	}
}