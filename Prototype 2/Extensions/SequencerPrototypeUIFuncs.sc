+ SequencerPrototype {

	// functions handling UI tasks

	updatePlotters {
		newUI.updateP1Plotters;
	}
}

+ SequencerUIPrototype {

	// functions handling UI tasks

	updateP1Plotters {
		var values;
		6.do({
			arg index, step, size, locks;

			size = [
				paramDict[\pitchReset],
				paramDict[\velocityReset],
				paramDict[\octaveReset],
				paramDict[\articulationReset],
				paramDict[\ornamentationReset],
				paramDict[\timingReset]
			].at(index);

			switch(index,
				0, { values = this.getValuesForPitchPlot },
				1, { values = this.getValuesForVelocityPlot },
				2, { values = this.getValuesForOctavePlot },
				3, { values = this.getValuesForArticulationPlot },
				4, { values = this.getValuesForOrnamentationPlot },
				5, { values = paramDict[\timingArray] },
			);

			if(index < 5, {
				var buffervalues;
				buffervalues = [0!(size.clip(1, 64))];
				values.do({
					arg valueList, valIndex;
					buffervalues = buffervalues ++ [valueList.at( (0..( (size-1).clip(0, 63) )) ) ++ [0]];
				});
				values = buffervalues;
			}, {
				values = [0!(size.clip(1, 64)), values.at( (0..( (size-1).clip(0, 63) ) ) ) ++ [0]]; // to make the last step visible in the bar chart
			});

			step = [
				paramDict[\pitchIndex],
				paramDict[\velocityIndex],
				paramDict[\octaveIndex],
				paramDict[\articulationIndex],
				paramDict[\ornamentationIndex],
				paramDict[\timingIndex]
			].at(index);
			if(step < size, {
				values[0][step] = 1 * [1, 2, 2, 2, 2, 2, 2, 1].at(index);
			});

			locks = [
				paramDict[\lockedPitchPositionsArray],
				paramDict[\lockedVelocityPositionsArray],
				paramDict[\lockedOctavePositionsArray],
				paramDict[\lockedArticulationPositionsArray],
				paramDict[\lockedOrnamentationPositionsArray],
				paramDict[\lockedTimingPositionsArray],
			].at(index);
			values = [(locks ++ [0])] ++ values;

			p1Plotters[index].value = values;
		});
		this.p1TextFunc;
		window.refresh;
	}

	p1TextFunc {
		p1Text.do({
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
				paramDict[\pitchIndex],
				paramDict[\velocityIndex],
				paramDict[\octaveIndex],
				paramDict[\articulationIndex],
				paramDict[\ornamentationIndex],
				paramDict[\timingIndex]
			].at(index) + 1).asInteger.asString ++ "/" ++
			[
				paramDict[\pitchReset],
				paramDict[\velocityReset],
				paramDict[\octaveReset],
				paramDict[\articulationReset],
				paramDict[\ornamentationReset],
				paramDict[\timingReset]
			].at(index).asString ++
			")";

			if(index < 5, {
				stringText = stringText ++ "; (mut.: " ++
				[
					paramDict[\pitchMutation],
					paramDict[\velocityMutation],
					paramDict[\octaveMutation],
					paramDict[\articulationMutation],
					paramDict[\ornamentationMutation]
				].at(index).asString ++
				")";
			});

			tbox.string = stringText;
		});
	}

	getValuesForPitchPlot {
		// todo: implement pitch functions & display multiple macros on the same step
		var pitch, bipolar2pos, bipolar2neg, bipolar1pos, bipolar1neg;
		pitch = paramDict[\mutatedPitchArray][paramDict[\pitchRandom]];
		bipolar2pos = 0!64; bipolar2neg = 0!64;
		bipolar1pos = 0!64; bipolar1neg = 0!64;

		if((paramDict[\mutatedPitchStepsArray][paramDict[\pitchSteps]]).sum > 0, {
			bipolar1pos = (paramDict[\mutatedPitchStepsArray][paramDict[\pitchSteps]]).abs;
		}, {
			bipolar1neg = (paramDict[\mutatedPitchStepsArray][paramDict[\pitchSteps]]).abs;
		});

		if((paramDict[\mutatedPitchConfirmingArray][paramDict[\pitchConfirming]]).sum > 0, {
			bipolar2pos = (paramDict[\mutatedPitchConfirmingArray][paramDict[\pitchConfirming]]).abs + bipolar1pos + bipolar1neg;
		}, {
			bipolar2neg = (paramDict[\mutatedPitchConfirmingArray][paramDict[\pitchConfirming]]).abs + bipolar1pos + bipolar1neg;
		});

		^[pitch, bipolar2pos * -0.15, bipolar2neg * -0.15, bipolar1pos * -0.15, bipolar1neg * -0.15];
	}

	getValuesForVelocityPlot {
		// todo: implement probability functions, dynamics & display syncopation acurately
		var velocity, dynamics, syncopation, probability, probTrigs;
		velocity = paramDict[\mutatedVelocityArray][paramDict[\velocityDensity]] * paramDict[\mutatedVelocityDynamicsArray][paramDict[\velocityDynamics]];
		syncopation = paramDict[\mutatedVelocitySyncopationArray][paramDict[\velocitySyncopation]];
		syncopation = syncopation * velocity;
		probability = 0; // velocityProbability/(dimensionSize - 1.0); // use these if there are probabilities per step, for a global probability a single knob should suffice
		^[velocity, syncopation, (2.0*probability)!64, 0!64];
	}

	getValuesForOctavePlot {
		// todo: implement probability functions and display
		var octave, probability;
		octave = paramDict[\mutatedOctaveArray][paramDict[\octaveDensity]];
		probability = 0; // octaveProbability/(dimensionSize - 1.0); // use these if there are probabilities per step, for a global probability a single knob should suffice
		^[octave, (2.0*probability)!64, 0!64];
	}

	getValuesForArticulationPlot {
		// todo: implement articulation
		var accent, slide, staccato;
		accent = paramDict[\mutatedArticulationAccentArray][paramDict[\articulationAccentDensity]];
		staccato = paramDict[\mutatedArticulationStaccatoArray][paramDict[\articulationStaccatoDensity]];
		slide = paramDict[\mutatedArticulationSlideArray][paramDict[\articulationSlideDensity]];
		accent = accent + staccato + slide;
		staccato = staccato + slide;
		^[accent, staccato, slide]*0.5;
	}

	getValuesForOrnamentationPlot {
		// todo: implement ornamentation
		var graceNotes, figures;
		graceNotes = paramDict[\mutatedOrnamentationGraceNoteArray][paramDict[\ornamentationGraceNotes]];
		figures = paramDict[\mutatedOrnamentationFigureArray][paramDict[\ornamentationFigures]];
		graceNotes = graceNotes + figures;
		^[graceNotes, figures]*0.5;
	}

	initPage1 {
		// generate UI
		p1KnobVals = 0.5!4!6;
		p1MiniKnobVals = [0.25, 0]!6;
		p1MiniButtons = [];
		p1CompositeViews = [];
		p1Plotters = [];
		p1KnobViews = [];
		p1KnobLists = [];
		p1LabelLists = [];
		p1MiniKnobs = [];
		p1MiniButtons = [];
		p1Text = [];
		pageCompositeViews[0].asView.decorator_(FlowLayout(pageCompositeViews[0].bounds, 0@0, 10@10));

		// colors
		lockColor = Color.cyan;
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
			[lockColor, stepColor, activeColor, bipolarNegativeColor2, bipolarPositiveColor2, bipolarNegativeColor1, bipolarPositiveColor1], // pitch
			[lockColor, stepColor, activeColor, inactiveColor, probabilityActiveColor, probabilityInactiveColor], // velocity
			[lockColor, stepColor, activeColor, probabilityActiveColor, probabilityInactiveColor], // octaves
			[lockColor, stepColor, articulationColor1, articulationColor2, articulationColor3], // articulation
			[lockColor, stepColor, articulationColor1, articulationColor2], // ornamentation
			[lockColor, stepColor, activeColor], // timing
		];

		3.do({
			|index|

			// add titles, mini knobs and buttons
			2.do({
				|index2|
				p1Text = p1Text ++ TextView(pageCompositeViews[0], Rect(
					0,//globalMargin + ((index/3).floor * (titleWidth + globalMargin)),
					0,//25 + (125*index.mod(3)),
					titleWidth - 90,
					20));
				p1Text[2 * index + index2].setString("test");

				p1MiniKnobs = p1MiniKnobs ++ [{Knob.new(
					pageCompositeViews[0],
					Rect(0, 0, 20, 20))
				.action_({ |ez| ("value: " ++ ez.value.asString).postln })
				.mode_(\vert)
				.value_(0.5)
				}!2];

				p1MiniButtons = p1MiniButtons ++ [Button(
					pageCompositeViews[0],
					Rect(0, 0, 20, 20))
				.action_({ arg button; button.value.postln; });
				];
			});

			// add graphs
			2.do({
				|index2|
				p1CompositeViews = p1CompositeViews ++ [
					CompositeView(
						pageCompositeViews[0],
						Rect(
							0, //globalMargin + ((index/3).floor * (plotWidth + globalMargin) ),
							0, //50 + (125*index.mod(3)),
							plotWidth,
							plotHeight)
				).background_(Color.black).resize_(5)];

				p1Plotters = p1Plotters ++ [Plotter("plot", parent: p1CompositeViews[2 * index + index2]).plotMode = \bars];
				p1Plotters[2 * index + index2].value = [ 0!64, ({1.0.rand}!64 ++ [0]) ];
				p1Plotters[2 * index + index2].plotColor = colorLists[2 * index + index2];
				p1Plotters[2 * index + index2].superpose_(true);
				p1Plotters[2 * index + index2].minval = 0;
			});

			// add knobs
			2.do({
				|index2|
				p1KnobViews = p1KnobViews ++ [
					CompositeView(
						pageCompositeViews[0],
						Rect(0, 0, plotWidth, 85)
					).background_(Color.grey).resize_(5);
				];
				p1KnobViews[2 * index + index2].decorator_(
					FlowLayout(p1KnobViews[2 * index + index2].bounds, (plotWidth - 30 - (knobSize * 4))/2@10, 10@10)
				);
				p1KnobLists = p1KnobLists ++ [{Knob.new(
					p1KnobViews[2 * index + index2],
					Rect(0, 0, knobSize, knobSize))
				.action_({ |ez| ("value: " ++ ez.value.asString).postln })
				.mode_(\vert)
				.value_(0.5)
				}!4];

				p1LabelLists = p1LabelLists ++ [{TextView(
					p1KnobViews[2 * index + index2],
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
				p1KnobLists[index][input].value = 0.0;
				p1KnobVals[index][input] = 0.0;
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
				p1KnobLists[index][input].value = 1.0;
				p1KnobVals[index][input] = 1.0;
			});
			p1MiniKnobs[index][0].value = 0.25;
			p1MiniKnobs[index][1].value = 0.0;
		});

		// add actions to knobs & buttons
		p1KnobLists.do({
			arg list, index;
			list.do({
				arg knob, index2;
				var func;
				func = {|val| p1KnobVals[index][index2] = val};
				knob.action_({
					|knobSelf|
					func.value(knobSelf.value);
					p1KnobVals[index][index2].postln;
					this.updateDict;
					this.updateP1Plotters;
				});
			});
		});

		p1MiniKnobs.do({
			arg list, index;
			list.do({
				arg knob, index2;
				var func;
				func = {|val| p1MiniKnobVals[index][index2] = val};
				knob.action_({
					|knobSelf|
					func.value(knobSelf.value);
					p1MiniKnobVals[index][index2].postln;
					this.updateDict;
					this.updateP1Plotters;
				});
			});
		});

		p1MiniButtons.do({
			arg button, index;
			button.action_({
				arg butt;
				switch(index,
					0, {paramDict[\regenFuncPitch].value;},
					1, {paramDict[\regenFuncVelocity].value;},
					2, {paramDict[\regenFuncOctave].value;},
					3, {paramDict[\regenFuncArticulation].value;},
					4, {paramDict[\regenFuncOrnamentation].value;},
					5, {"timing does not regen!".postln;}
				);
				this.updateP1Plotters;
			});
		});

		p1LabelLists.do({
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

	initPage2 {
		// generate UI
		pageCompositeViews[1].asView.decorator_(FlowLayout(pageCompositeViews[0].bounds, 0@0, 10@10));
	}

	updateP3Plotters {
		var values;
		6.do({
			arg index, step, size, locks;

			size = [
				paramDict[\pitchReset],
				paramDict[\velocityReset],
				paramDict[\octaveReset],
				paramDict[\articulationReset],
				paramDict[\ornamentationReset],
				paramDict[\timingReset]
			].at(index);

			switch(index,
				0, { values = this.getValuesForPitchPlot },
				1, { values = this.getValuesForVelocityPlot },
				2, { values = this.getValuesForOctavePlot },
				3, { values = this.getValuesForArticulationPlot },
				4, { values = this.getValuesForOrnamentationPlot },
				5, { values = paramDict[\timingArray] },
			);

			if(index < 5, {
				var buffervalues;
				buffervalues = [0!(size.clip(1, 64))];
				values.do({
					arg valueList, valIndex;
					buffervalues = buffervalues ++ [valueList.at( (0..( (size-1).clip(0, 63) )) ) ++ [0]];
				});
				values = buffervalues;
			}, {
				values = [0!(size.clip(1, 64)), values.at( (0..( (size-1).clip(0, 63) ) ) ) ++ [0]]; // to make the last step visible in the bar chart
			});

			step = [
				paramDict[\pitchIndex],
				paramDict[\velocityIndex],
				paramDict[\octaveIndex],
				paramDict[\articulationIndex],
				paramDict[\ornamentationIndex],
				paramDict[\timingIndex]
			].at(index);
			if(step < size, {
				values[0][step] = 1 * [1, 2, 2, 2, 2, 2, 2, 1].at(index);
			});

			locks = [
				paramDict[\lockedPitchPositionsArray],
				paramDict[\lockedVelocityPositionsArray],
				paramDict[\lockedOctavePositionsArray],
				paramDict[\lockedArticulationPositionsArray],
				paramDict[\lockedOrnamentationPositionsArray],
				paramDict[\lockedTimingPositionsArray],
			].at(index);
			values = [(locks ++ [0])] ++ values;

			p3Plotters[index].value = values;
		});
		this.p3TextFunc;
		window.refresh;
	}

	p3TextFunc {
		p3Text.do({
			arg tbox, index;
			var stringText;
			stringText = [
				"Pitch",
				"Velocity",
				"Octaves",
				"Articulation",
				"Ornamentation",
				"Timing",
				"Test",
				"Test"
			].at(index);

			if(index < 6, {
				stringText = stringText ++ " locks + reset " ++
				([
					paramDict[\pitchSequenceReset],
					paramDict[\velocitySequenceReset],
					paramDict[\octaveSequenceReset],
					paramDict[\articulationSequenceReset],
					paramDict[\ornamentationSequenceReset],
					paramDict[\timingSequenceReset],
				].at(index)).asInteger.asString;
			});

			tbox.string = stringText;
		});
	}

	initPage3 {
		// generate UI
		p3KnobVals = 0.5!4!6;
		p3MiniKnobVals = [0, 0, 0.25]!6;
		p3CompositeViews = [];
		p3Plotters = [];
		p3KnobViews = [];
		p3KnobLists = [];
		p3LabelLists = [];
		p3MiniKnobs = [];
		p3Text = [];
		pageCompositeViews[2].asView.decorator_(FlowLayout(pageCompositeViews[2].bounds, 0@0, 10@10));

		3.do({
			|index|

			// add titles, mini knobs and buttons
			2.do({
				|index2|
				p3Text = p3Text ++ TextView(pageCompositeViews[2], Rect(
					0,//globalMargin + ((index/3).floor * (titleWidth + globalMargin)),
					0,//25 + (125*index.mod(3)),
					titleWidth - 90,
					20));
				p3Text[2 * index + index2].setString("test");

				p3MiniKnobs = p3MiniKnobs ++ [{Knob.new(
					pageCompositeViews[2],
					Rect(0, 0, 20, 20))
				.action_({ |ez| ("value: " ++ ez.value.asString).postln; p3MiniKnobVals.dopostln; })
				.mode_(\vert)
				.value_(0)
				}!3];
				p3MiniKnobs[2 * index + index2][2].value = 0.25;
			});

			// add graphs
			2.do({
				|index2|
				p3CompositeViews = p3CompositeViews ++ [
					CompositeView(
						pageCompositeViews[2],
						Rect(
							0, //globalMargin + ((index/3).floor * (plotWidth + globalMargin) ),
							0, //50 + (125*index.mod(3)),
							plotWidth,
							plotHeight)
				).background_(Color.black).resize_(5)];

				p3Plotters = p3Plotters ++ [Plotter("plot", parent: p3CompositeViews[2 * index + index2]).plotMode = \bars];
				p3Plotters[2 * index + index2].value = [ 0!64, ({1.0.rand}!64 ++ [0]) ];
				p3Plotters[2 * index + index2].plotColor = colorLists[2 * index + index2];
				p3Plotters[2 * index + index2].superpose_(true);
				p3Plotters[2 * index + index2].minval = 0;
			});
		});

		2.do({
			|index|
			p3Text = p3Text ++ TextView(pageCompositeViews[2], Rect(
				0,//globalMargin + ((index/3).floor * (titleWidth + globalMargin)),
				0,//25 + (125*index.mod(3)),
				titleWidth,
				20));
			p3Text[index+6].setString("test");
		});

		// add graphs
		2.do({
			|index|
			p3CompositeViews = p3CompositeViews ++ [
				CompositeView(
					pageCompositeViews[2],
					Rect(
						0, //globalMargin + ((index/3).floor * (plotWidth + globalMargin) ),
						0, //50 + (125*index.mod(3)),
						plotWidth,
						plotHeight)
			).background_(Color.black).resize_(5)];

			p3Plotters = p3Plotters ++ [Plotter("plot", parent: p3CompositeViews[index+6]).plotMode = \bars];
			p3Plotters[index+6].value = [ 0!64, ({1.0.rand}!64 ++ [0]) ];
			p3Plotters[index+6].plotColor = colorLists[index];
			p3Plotters[index+6].superpose_(true);
			p3Plotters[index+6].minval = 0;
		});

		// add knobs
		2.do({
			|index|
			p3KnobViews = p3KnobViews ++ [
				CompositeView(
					pageCompositeViews[2],
					Rect(0, 0, plotWidth, knobSize + 20)
				).background_(Color.grey).resize_(5);
			];
			p3KnobViews[index].decorator_(
				FlowLayout(p3KnobViews[index].bounds, (plotWidth - 30 - (knobSize * 4))/2@10, 10@10)
			);
			p3KnobLists = p3KnobLists ++ [{Knob.new(
				p3KnobViews[index],
				Rect(0, 0, knobSize, knobSize))
			.action_({ |ez| ("value: " ++ ez.value.asString).postln })
			.mode_(\vert)
			.value_(0.5)
			}!2];
			p3LabelLists = p3LabelLists ++ [{TextView(
				p3KnobViews[index],
				Rect(0, 0, labelWidth, labelHeight)
			)}!2];
		});

		// add last graph with controls
		p3CompositeViews = p3CompositeViews ++ [
			CompositeView(
				pageCompositeViews[2],
				Rect(
					0, //globalMargin + ((index/3).floor * (plotWidth + globalMargin) ),
					0, //50 + (125*index.mod(3)),
					plotWidth,
					plotHeight+20)
		).background_(Color.black).resize_(5)];

		p3Plotters = p3Plotters ++ [Plotter("plot", parent: p3CompositeViews[8]).plotMode = \bars];
		p3Plotters[8].value = [ 0!64, ({1.0.rand}!64 ++ [0]) ];
		p3Plotters[8].plotColor = colorLists[0];
		p3Plotters[8].superpose_(true);
		p3Plotters[8].minval = 0;

		p3KnobViews = p3KnobViews ++ [
			CompositeView(
				pageCompositeViews[2],
				Rect(0, 0, plotWidth, 85)
			).background_(Color.grey).resize_(5);
		];
		p3KnobViews[2].decorator_(
			FlowLayout(p3KnobViews[2].bounds, (plotWidth - 30 - (knobSize * 4))/2@10, 10@10)
		);
		p3KnobLists = p3KnobLists ++ [{Knob.new(
			p3KnobViews[2],
			Rect(0, 0, knobSize, knobSize))
		.action_({ |ez| ("value: " ++ ez.value.asString).postln })
		.mode_(\vert)
		.value_(0.5)
		}!4];
		p3LabelLists = p3LabelLists ++ [{TextView(
			p3KnobViews[2],
			Rect(0, 0, labelWidth, labelHeight)
		)}!4];

		p3MiniKnobs.do({
			arg list, index;
			list.do({
				arg knob, index2;
				var func;
				func = {|val| p3MiniKnobVals[index][index2] = val};
				knob.action_({
					|knobSelf|
					func.value(knobSelf.value);
					this.updateDictLocks;
					if(index2 < 2, {
						// make sure sequence reset param knob doesn't regenerate locks
						switch(index,
							0, {paramDict[\regenFuncPitchLocks].value;},
							1, {paramDict[\regenFuncVelocityLocks].value;},
							2, {paramDict[\regenFuncOctaveLocks].value;},
							3, {paramDict[\regenFuncArticulationLocks].value;},
							4, {paramDict[\regenFuncOrnamentationLocks].value;},
							5, {paramDict[\regenFuncTimingLocks].value;}
						);
						this.updateP1Plotters;
					});
					this.updateP3Plotters;
				});
			});
		});
	}

	initPage4 {
		// generate UI
		p4KnobVals = 0.5!4!6;
		p4MiniKnobVals = 0!2!6;
		p4MiniButtons = [];
		p4CompositeViews = [];
		p4Plotters = [];
		p4KnobViews = [];
		p4KnobLists = [];
		p4LabelLists = [];
		p4MiniKnobs = [];
		p4MiniButtons = [];
		p4Text = [];
		pageCompositeViews[3].asView.decorator_(FlowLayout(pageCompositeViews[3].bounds, 0@0, 10@10));

		3.do({
			|index|

			// add titles, mini knobs and buttons
			2.do({
				|index2|
				p4Text = p4Text ++ TextView(pageCompositeViews[3], Rect(
					0,//globalMargin + ((index/3).floor * (titleWidth + globalMargin)),
					0,//25 + (125*index.mod(3)),
					titleWidth - 90,
					20));
				p4Text[2 * index + index2].setString("test");

				p4MiniKnobs = p4MiniKnobs ++ [{Knob.new(
					pageCompositeViews[3],
					Rect(0, 0, 20, 20))
				.action_({ |ez| ("value: " ++ ez.value.asString).postln })
				.mode_(\vert)
				.value_(0.5)
				}!2];

				p4MiniButtons = p4MiniButtons ++ [Button(
					pageCompositeViews[3],
					Rect(0, 0, 20, 20))
				.action_({ arg button; button.value.postln; });
				];
			});

			// add graphs
			2.do({
				|index2|
				p4CompositeViews = p4CompositeViews ++ [
					CompositeView(
						pageCompositeViews[3],
						Rect(
							0, //globalMargin + ((index/3).floor * (plotWidth + globalMargin) ),
							0, //50 + (125*index.mod(3)),
							plotWidth,
							plotHeight)
				).background_(Color.black).resize_(5)];

				p4Plotters = p4Plotters ++ [Plotter("plot", parent: p4CompositeViews[2 * index + index2]).plotMode = \bars];
				p4Plotters[2 * index + index2].value = [ 0!64, ({1.0.rand}!64 ++ [0]) ];
				p4Plotters[2 * index + index2].plotColor = colorLists[2 * index + index2];
				p4Plotters[2 * index + index2].superpose_(true);
				p4Plotters[2 * index + index2].minval = 0;
			});

			// add knobs
			2.do({
				|index2|
				p4KnobViews = p4KnobViews ++ [
					CompositeView(
						pageCompositeViews[3],
						Rect(0, 0, plotWidth, 85)
					).background_(Color.grey).resize_(5);
				];
				p4KnobViews[2 * index + index2].decorator_(
					FlowLayout(p4KnobViews[2 * index + index2].bounds, (plotWidth - 30 - (knobSize * 4))/2@10, 10@10)
				);
				p4KnobLists = p4KnobLists ++ [{Knob.new(
					p4KnobViews[2 * index + index2],
					Rect(0, 0, knobSize, knobSize))
				.action_({ |ez| ("value: " ++ ez.value.asString).postln })
				.mode_(\vert)
				.value_(0.5)
				}!4];

				p4LabelLists = p4LabelLists ++ [{TextView(
					p4KnobViews[2 * index + index2],
					Rect(0, 0, labelWidth, labelHeight)
				)}!4];
			});
		});
	}

	initPage5 {

	}

	initPage6 {

	}

}