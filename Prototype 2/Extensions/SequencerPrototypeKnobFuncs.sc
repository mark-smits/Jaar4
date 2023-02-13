+ SequencerPrototype {

	// functions to be added to knobs

	pitchRandKnobFunc {
		arg val;
		this.setPitchRandom(val);
		this.updatePlotters;
	}

	pitchStepsKnobFunc {
		arg val;
		this.setPitchSteps(val);
		this.updatePlotters;
	}

	pitchConfirmingKnobFunc {
		arg val;
		this.setPitchConfirming(val);
		this.updatePlotters;
	}

	velocityDensityKnobFunc {
		arg val;
		this.setVelocityDensity(val);
		this.updatePlotters;
	}

	velocityProbabilityKnobFunc {
		arg val;
		this.setVelocityProbability(val);
		this.updatePlotters;
	}

	velocitySyncopationKnobFunc {
		arg val;
		this.setVelocitySyncopation(val);
		this.updatePlotters;
	}

	velocityDynamicsKnobFunc {
		arg val;
		this.setVelocityDynamics(val);
		this.updatePlotters;
	}

	octaveDensityKnobFunc {
		arg val;
		this.setOctaveDensity(val);
		this.updatePlotters;
	}

	octaveProbabilityKnobFunc {
		arg val;
		this.setOctaveProbability(val);
		this.updatePlotters;
	}

	octaveOffsetKnobFunc {
		arg val;
		this.setOctaveOffset(val);
		// this.updatePlotters;
	}

	articulationStaccatoKnobFunc {
		arg val;
		this.setArticulationStaccatoDensity(val);
		this.updatePlotters;
	}

	articulationSlideKnobFunc {
		arg val;
		this.setArticulationSlideDensity(val);
		this.updatePlotters;
	}

	articulationAccentKnobFunc {
		arg val;
		this.setArticulationAccentDensity(val);
		this.updatePlotters;
	}

	ornamentationGraceNoteKnobFunc {
		arg val;
		this.setOrnamentationGraceNotes(val);
		this.updatePlotters;
	}

	ornamentationFigureKnobFunc {
		arg val;
		this.setOrnamentationFigures(val);
		this.updatePlotters;
	}

	timingSwingKnobFunc {
		arg val;
		this.setTimingSwing(val);
		this.updatePlotters;
	}

	timingRubatoKnobFunc {
		arg val;
		this.setTimingRubato(val);
		this.updatePlotters;
	}
}

+ SequencerUIPrototype {

	// functions to be added to knobs

	pitchRandKnobFunc {
		arg val;
		knobVals[0][0] = val;
	}

	pitchStepsKnobFunc {
		arg val;
		knobVals[0][1] = val;
	}

	pitchConfirmingKnobFunc {
		arg val;
		knobVals[0][2] = val;
	}

	velocityDensityKnobFunc {
		arg val;
		knobVals[1][0] = val;
	}

	velocityProbabilityKnobFunc {
		arg val;
		knobVals[1][1] = val;
	}

	velocitySyncopationKnobFunc {
		arg val;
		knobVals[1][2] = val;
	}

	velocityDynamicsKnobFunc {
		arg val;
		knobVals[1][3] = val;
	}

	octaveDensityKnobFunc {
		arg val;
		knobVals[2][0] = val;
	}

	octaveProbabilityKnobFunc {
		arg val;
		knobVals[2][1] = val;
	}

	octaveOffsetKnobFunc {
		arg val;
		knobVals[2][3] = val;
	}

	articulationStaccatoKnobFunc {
		arg val;
		knobVals[3][0] = val;
	}

	articulationSlideKnobFunc {
		arg val;
		knobVals[3][1] = val;
	}

	articulationAccentKnobFunc {
		arg val;
		knobVals[3][2] = val;
	}

	ornamentationGraceNoteKnobFunc {
		arg val;
		knobVals[4][0] = val;
	}

	ornamentationFigureKnobFunc {
		arg val;
		knobVals[4][1] = val;
	}

	timingSwingKnobFunc {
		arg val;
		knobVals[5][0] = val;
	}

	timingRubatoKnobFunc {
		arg val;
		knobVals[5][1] = val;
	}
}