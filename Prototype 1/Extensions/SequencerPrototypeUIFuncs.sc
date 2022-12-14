+ SequencerPrototype {

	// functions handling UI tasks

	setFocusColor {
		arg index;
		knobViews.do({
			|view|
			view.background = Color.grey;
		});
		if((index > -1).and(index < 6), {
			knobViews[index].background = Color.cyan;
		});
		window.refresh;
	}

	updatePlotters {
		var values;
		6.do({
			arg index, step, size;

			size = [
				pitchReset,
				velocityReset,
				octaveReset,
				articulationReset,
				ornamentationReset,
				timingReset
			].at(index);

			/*
			old code
			values = [0!size,
				[ // TODO: fix the displayed values
					mutatedPitchArray[pitchRandom],
					mutatedVelocityArray[velocityDensity],
					mutatedOctaveArray[octaveDensity],
					mutatedVelocityAccentArray[velocityAccent],
					mutatedVelocitySyncopationArray[velocitySyncopation],
					timingArray
				].at(index).at( (0..(size-1)) ) ++ [0] // to make the last step visible in the bar chart
			];
			*/

			switch(index,
				0, { values = this.getValuesForPitchPlot },
				1, { values = this.getValuesForVelocityPlot },
				2, { values = this.getValuesForOctavePlot },
				3, { values = this.getValuesForArticulationPlot },
				4, { values = this.getValuesForOrnamentationPlot },
				5, { values = timingArray },
			);
			if(index < 5, {
				var buffervalues;
				buffervalues = [0!size];
				values.do({
					arg valueList, valIndex;
					buffervalues = buffervalues ++ [valueList.at( (0..(size-1)) ) ++ [0]];
				});
				values = buffervalues;
			}, {
				values = [0!size, values.at( (0..(size-1)) ) ++ [0]]; // to make the last step visible in the bar chart
			});

			step = [
				pitchIndex,
				velocityIndex,
				octaveIndex,
				articulationIndex,
				ornamentationIndex,
				timingIndex
			].at(index);
			if(step < size, {
				values[0][step] = 1 * [1, 2, 2, 2, 2, 2, 2, 1].at(index);
			});

			plotters[index].value = values;
		});
		this.textFunc;
		window.refresh;
	}

	textFunc {
		text.do({
			arg tbox, index;
			var stringText;
			stringText = [
				"Pitch",
				"Velocity",
				"Octaves",
				"Articulation",
				"Ornamentation",
				"Timing"
			].at(index);
			stringText = stringText ++ " (step: " ++
			([
				pitchIndex,
				velocityIndex,
				octaveIndex,
				articulationIndex,
				ornamentationIndex,
				timingIndex
			].at(index) + 1).asInteger.asString ++ "/" ++
			[
				pitchReset,
				velocityReset,
				octaveReset,
				articulationReset,
				ornamentationReset,
				timingReset
			].at(index).asString ++
			")";
			if(index < 5, {
				stringText = stringText ++ "; (mutation: " ++
				[
					pitchMutation,
					velocityMutation,
					octaveMutation,
					articulationMutation,
					ornamentationMutation
				].at(index).asString ++
				")";
			});
			tbox.string = stringText;
		});
	}

	getValuesForPitchPlot {
		// todo: implement pitch functions & display multiple macros on the same step
		var pitch, bipolar2pos, bipolar2neg, bipolar1pos, bipolar1neg;
		pitch = mutatedPitchArray[pitchRandom];
		bipolar2pos = 0!64; bipolar2neg = 0!64;
		bipolar1pos = 0!64; bipolar1neg = 0!64;

		if(mutatedPitchStepsArray[pitchSteps].sum > 0, {
			bipolar1pos = (mutatedPitchStepsArray[pitchSteps]).abs;
		}, {
			bipolar1neg = (mutatedPitchStepsArray[pitchSteps]).abs;
		});

		if(mutatedPitchConfirmingArray[pitchConfirming].sum > 0, {
			bipolar2pos = (mutatedPitchConfirmingArray[pitchConfirming]).abs + bipolar1pos + bipolar1neg;
		}, {
			bipolar2neg = (mutatedPitchConfirmingArray[pitchConfirming]).abs + bipolar1pos + bipolar1neg;
		});

		^[pitch, bipolar2pos * -0.15, bipolar2neg * -0.15, bipolar1pos * -0.15, bipolar1neg * -0.15];
	}

	getValuesForVelocityPlot {
		// todo: implement probability functions, dynamics & display syncopation acurately
		var velocity, dynamics, syncopation, probability, probTrigs;
		velocity = mutatedVelocityArray[velocityDensity] * mutatedVelocityDynamicsArray[velocityDynamics];
		syncopation = mutatedVelocitySyncopationArray[velocitySyncopation];
		syncopation = syncopation * velocity;
		probability = 0; // velocityProbability/(dimensionSize - 1.0); // use these if there are probabilities per step, for a global probability a single knob should suffice
		^[velocity, syncopation, (2.0*probability)!64, 0!64];
	}

	getValuesForOctavePlot {
		// todo: implement probability functions and display
		var octave, probability;
		octave = mutatedOctaveArray[octaveDensity];
		probability = 0; // octaveProbability/(dimensionSize - 1.0); // use these if there are probabilities per step, for a global probability a single knob should suffice
		^[octave, (2.0*probability)!64, 0!64];
	}

	getValuesForArticulationPlot {
		// todo: implement articulation
		var accent, slide, staccato;
		accent = mutatedArticulationAccentArray[articulationAccentDensity];
		staccato = mutatedArticulationStaccatoArray[articulationStaccatoDensity];
		slide = mutatedArticulationSlideArray[articulationSlideDensity];
		accent = accent + staccato + slide;
		staccato = staccato + slide;
		^[accent, staccato, slide]*0.5;
	}

	getValuesForOrnamentationPlot {
		// todo: implement ornamentation
		var graceNotes, figures;
		graceNotes = mutatedOrnamentationGraceNoteArray[ornamentationGraceNotes];
		figures = mutatedOrnamentationFigureArray[ornamentationFigures];
		graceNotes = graceNotes + figures;
		^[graceNotes, figures]*0.5;
	}
}