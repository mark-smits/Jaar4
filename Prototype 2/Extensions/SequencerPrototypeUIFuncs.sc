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

+ SequencerUIPrototype {

	// functions handling UI tasks

	initPage1 {
		// generate UI
		sliders = [];
		compositeViews = [];
		plotters = [];
		knobViews = [];
		knobLists = [];
		labelLists = [];
		text = [];
		pageCompositeViews[0].asView.decorator_(FlowLayout(pageCompositeViews[0].bounds, 0@0, 10@10));

		// colors
		activeColor = Color.grey(0.6);
		inactiveColor = Color.grey(0.3);
		stepColor = Color.white;
		probabilityActiveColor = Color.new(0, 1, 1, 0.5); // Color.grey(0.75, 0.5); // these should have been thinner bars with alpha 1.0
		probabilityInactiveColor = Color.grey(0.4, 0.5);
		bipolarPositiveColor1 = Color.fromHexString("#CF5F3A");
		bipolarNegativeColor1 = Color.fromHexString("#0F4557");
		bipolarPositiveColor2 = Color.fromHexString("#EBBC6F");
		bipolarNegativeColor2 = Color.fromHexString("#361D2E");
		articulationColor1 = Color.fromHexString("#4F5D2F");
		articulationColor2 = Color.fromHexString("#EBBC6F");
		articulationColor3 = Color.fromHexString("#361D2E");

		colorLists = [ // general structure: step color, value colors, probability colors, macro colors
			[stepColor, activeColor, bipolarNegativeColor2, bipolarPositiveColor2, bipolarNegativeColor1, bipolarPositiveColor1], // pitch
			[stepColor, activeColor, inactiveColor, probabilityActiveColor, probabilityInactiveColor], // velocity
			[stepColor, activeColor, probabilityActiveColor, probabilityInactiveColor], // octaves
			[stepColor, articulationColor1, articulationColor2, articulationColor3], // articulation
			[stepColor, articulationColor1, articulationColor2], // ornamentation
			[stepColor, activeColor], // timing
		];

		3.do({
			|index|

			// add titles
			2.do({
				|index2|
				text = text ++ TextView(pageCompositeViews[0], Rect(
					globalMargin + ((index/3).floor * (titleWidth + globalMargin)),
					25 + (125*index.mod(3)),
					titleWidth,
					20));
				text[2 * index + index2].setString("test");
			});

			// add graphs
			2.do({
				|index2|
				compositeViews = compositeViews ++ [
					CompositeView(
						pageCompositeViews[0],
						Rect(
							0, //globalMargin + ((index/3).floor * (plotWidth + globalMargin) ),
							0, //50 + (125*index.mod(3)),
							plotWidth,
							plotHeight)
				).background_(Color.black).resize_(5)];

				plotters = plotters ++ [Plotter("plot", parent: compositeViews[2 * index + index2]).plotMode = \bars];
				plotters[2 * index + index2].value = [ 0!64, ({1.0.rand}!64 ++ [0]) ];
				plotters[2 * index + index2].plotColor = colorLists[2 * index + index2];
				plotters[2 * index + index2].superpose_(true);
				plotters[2 * index + index2].minval = 0;
			});

			// add knobs
			2.do({
				|index2|
				knobViews = knobViews ++ [
					CompositeView(
						pageCompositeViews[0],
						Rect(0, 0, plotWidth, 85)
					).background_(Color.grey).resize_(5);
				];
				knobViews[2 * index + index2].decorator_(
					FlowLayout(knobViews[2 * index + index2].bounds, (plotWidth - 30 - (knobSize * 4))/2@10, 10@10)
				);
				knobLists = knobLists ++ [{Knob.new(
					knobViews[2 * index + index2],
					Rect(0, 0, knobSize, knobSize))
				.action_({ |ez| ("value: " ++ ez.value.asString).postln })
				.mode_(\vert)
				.value_(0.5)
				}!4];

				labelLists = labelLists ++ [{TextView(
					knobViews[2 * index + index2],
					Rect(0, 0, labelWidth, labelHeight)
				)}!4];
			});
		});

		// change some knob values
		6.do({
			|index|
			[
				[3],
				[],
				[2, 3],
				[0, 1, 2, 3],
				[0, 1, 2, 3],
				[0, 1, 2, 3],
			].at(index).do({
				|input, index2|
				knobLists[index][input].value = 0.0;
				knobVals[index][input] = 0.0;
			});
			[
				[],
				[1],
				[1],
				[],
				[],
				[],
			].at(index).do({
				|input, index2|
				knobLists[index][input].value = 1.0;
				knobVals[index][input] = 1.0;
			});
		});

		// add actions to knobs
		knobLists.do({
			arg list, index;
			list.do({
				arg knob, index2;
				var func;
				func = {};
				switch(index,
					0, {
						// pitch
						switch(index2,
							0, { func = {|val| this.pitchRandKnobFunc(val)}; },
							1, { func = {|val| this.pitchStepsKnobFunc(val)}; },
							2, { func = {|val| this.pitchConfirmingKnobFunc(val)}; },
						)
					},
					1, {
						// velocity
						switch(index2,
							0, { func = {|val| this.velocityDensityKnobFunc(val)}; },
							1, { func = {|val| this.velocityProbabilityKnobFunc(val)}; },
							2, { func = {|val| this.velocitySyncopationKnobFunc(val)}; },
							3, { func = {|val| this.velocityDynamicsKnobFunc(val)}; },
						)
					},
					2, {
						// octaves
						switch(index2,
							0, { func = {|val| this.octaveDensityKnobFunc(val)}; },
							1, { func = {|val| this.octaveProbabilityKnobFunc(val)}; },
							3, { func = {|val| this.octaveOffsetKnobFunc(val)}; },
						)
					},
					3, {
						// articulation
						switch(index2,
							0, { func = {|val| this.articulationStaccatoKnobFunc(val)}; },
							1, { func = {|val| this.articulationSlideKnobFunc(val)}; },
							2, { func = {|val| this.articulationAccentKnobFunc(val)}; },
						)
					},
					4, {
						// ornamentation
						switch(index2,
							0, { func = {|val| this.ornamentationGraceNoteKnobFunc(val)}; },
							1, { func = {|val| this.ornamentationFigureKnobFunc(val)}; },
						)
					},
					5, {
						// timing
						switch(index2,
							0, { func = {|val| this.timingSwingKnobFunc(val)}; },
							1, { func = {|val| this.timingRubatoKnobFunc(val)}; },
						)
					},
				);
				knob.action_({
					|knobSelf|
					func.value(knobSelf.value);
					knobVals[index][index2].postln;
				});
			});
		});

		labelLists.do({
			arg list, index;
			list.do({
				arg label, index2;
				label.string = [
					["rand", "steps", "conf", ""],
					["dens", "prob", "sync", "dyn"],
					["dens", "prob", "", "offset"],
					["stac", "slide", "acc", ""],
					["gr n", "fig", "poly", ""],
					["swing", "rub", "", ""],
				].at(index).at(index2);
			});
		});
	}

}