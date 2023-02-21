SequencerPrototype {

	/*
	TODOS:
	pitch:

	velocity:
	dynamics
	octaves:
	(prob.)
	gate:

	timing:
	alles

	alle probabilities
	triggers op de eerste tel zetten (en ook afvangen in de mutatie)
	mutatie moet afhangen van de dataArray lengte zodat niet waardes buiten de lengte in en uit kunnen muteren
	syncopatie moet op een eigen lengte lopen -> altijd een even lengte -> niet elke keer verschuiving
	*/

	// class variables
    classvar
	globalWindowSaveStates,
	saveStateButtons,
	globalWindowPerformancePage,
	performancePagePopUpMenus,
	performancePageLabels,
	performancePageCompViews;
	// variables
	var
	// dataArrays
	pitchArray,
	pitchConfirmingArray,
	pitchStepsArray,
	octaveArray,
	velocityArray,
	velocitySyncopationArray,
	velocityDynamicsArray,
	velocityAccentArray, // will be deprecated
	gatelengthArray, // will be deprecated
	gateStaccatoArray, // will be deprecated
	gateSlideArray, // will be deprecated
	articulationStaccatoArray,
	articulationSlideArray,
	articulationAccentArray,
	ornamentationGraceNoteArray,
	ornamentationFigureArray,
	timingArray,
	// mutated arrays
	mutatedPitchArray,
	mutatedPitchConfirmingArray,
	mutatedPitchStepsArray,
	mutatedOctaveArray,
	mutatedVelocityArray,
	mutatedVelocitySyncopationArray,
	mutatedVelocityDynamicsArray,
	mutatedVelocityAccentArray, // will be deprecated
	mutatedGatelengthArray, // will be deprecated
	mutatedGateStaccatoArray, // will be deprecated
	mutatedGateSlideArray, // will be deprecated
	mutatedArticulationStaccatoArray,
	mutatedArticulationSlideArray,
	mutatedArticulationAccentArray,
	mutatedOrnamentationGraceNoteArray,
	mutatedOrnamentationFigureArray,
	mutatedTimingArray,
	// dimensions (0-15)
	dimensionSize = 15,
	pitchRandom,
	pitchSteps,
	pitchConfirming,
	pitchTonality,
	octaveDensity,
	octaveProbability,
	velocitySyncopation,
	velocityAccent, // will be deprecated
	velocityDensity,
	velocityProbability,
	velocityDynamics,
	gateLength, // will be deprecated
	gateStaccatoDensity, // will be deprecated
	gateSlideDensity, // will be deprecated
	articulationStaccatoDensity,
	articulationSlideDensity,
	articulationAccentDensity,
	ornamentationGraceNotes,
	ornamentationFigures,
	ornamentationPolyphony,
	timingSwing,
	timingRubato,
	// mutations
	pitchMutation = 0,
	velocityMutation = 0,
	octaveMutation = 0,
	articulationMutation = 0,
	ornamentationMutation = 0,
	// tonality params
	scale, // including the octave makes live easier
	octave_offset = 48,
	root = 12,
	// indices
	pitchIndex = 0,
	octaveIndex = 0,
	velocityIndex = 0,
	gateIndex = 0,
	articulationIndex = 0,
	ornamentationIndex = 0,
	timingIndex = 0,
	pitchReset = 16,
	octaveReset = 16,
	velocityReset = 16,
	gateReset = 16,
	articulationReset = 16,
	ornamentationReset = 16,
	timingReset = 16,
	// sequencing params
	ppqnResolution = 1536, // make sure this is devisible by 4 and 12
	ppqnPulse = 0,
	lastNote = nil,
	lastPitchIndex = nil,
	slideFlag = false,
	staccatoFlag = false,
	// UI objects
	newUI,
	window,
	text,
	compositeViews,
	sliders,
	plotters,
	knobViews,
	knobLists,
	labelLists,
	// sizing params
	plotHeight = 75, plotWidth = 250,
	titleHeight = 20, titleWidth = 250,
	knobSize = 35,
	labelHeight = 20, labelWidth = 35,
	plotSpacing = 10, globalMargin = 10,
	// colors
	activeColor, inactiveColor, stepColor,
	bipolarPositiveColor1, bipolarNegativeColor1,
	bipolarPositiveColor2, bipolarNegativeColor2,
	articulationColor1, articulationColor2, articulationColor3,
	probabilityActiveColor, probabilityInactiveColor, colorLists,

	// dictionary to pass values between UI and this class
	paramDict;

	// init funcs
	*initClass {
		// Initializations on class level (e.g. to set up classvars)

	}

	init {
		// init UI
		newUI = SequencerUIPrototype.new;
		newUI.init;

		// initialize parameters

		scale = [0, 2, 3, 5, 7, 8, 10, 12];

		pitchRandom = (dimensionSize/2.0).floor;
		pitchSteps = (dimensionSize/2.0).floor;
		pitchConfirming = (dimensionSize/2.0).floor;
		pitchTonality = (dimensionSize/2.0).floor;
		octaveDensity = (dimensionSize/2.0).floor;
		octaveProbability = (dimensionSize/2.0).floor;
		velocitySyncopation = (dimensionSize/2.0).floor;
		velocityAccent = (dimensionSize/2.0).floor; // will be deprecated
		velocityDensity = (dimensionSize/2.0).floor;
		velocityProbability = (dimensionSize/2.0).floor;
		velocityDynamics = (dimensionSize/2.0).floor;
		articulationStaccatoDensity = 0;
		articulationSlideDensity = 0;
		articulationAccentDensity = 0;
		ornamentationGraceNotes = 0;
		ornamentationFigures = 0;
		ornamentationPolyphony = 0;
		gateLength = (dimensionSize/2.0).floor; // will be deprecated
		gateStaccatoDensity = (dimensionSize/2.0).floor; // will be deprecated
		gateSlideDensity = (dimensionSize/2.0).floor; // will be deprecated
		timingSwing = 0.0;
		timingRubato = 0.0;

		// calculate arrays
		this.calcPitchArray;
		this.calcPitchConfirming;
		this.calcPitchSteps;
		this.calcOctaveArray;
		this.calcVelocityArray;
		this.calcVelocityAccentArray;
		this.calcVelocitySyncopationArray;
		this.calcVelocityDynamicsArray;
		this.calcGateStaccatoArray;
		this.calcGateSlideArray;
		this.calcArticulationSlideArray;
		this.calcArticulationStaccatoArray;
		this.calcArticulationAccentArray;
		this.calcOrnamentationGraceNoteArray;
		this.calcOrnamentationFigureArray;
		this.calcTimingArray;
		this.resetMutations;

		// generate UI
		window = Window("plot panel", Rect(20, 30, 540, 650));
		GUI.skin.plot.background = Color.black;
		GUI.skin.plot.gridColorX = Color.new(alpha: 0.0);
		GUI.skin.plot.gridColorY = Color.new(alpha: 0.0);
		GUI.skin.plot.fontColor = Color.new(alpha: 0.0);
		sliders = [];
		compositeViews = [];
		plotters = [];
		knobViews = [];
		knobLists = [];
		labelLists = [];
		text = [];
		window.view.decorator_(FlowLayout(window.bounds, 15@15, 10@10));

		// save state window
		globalWindowSaveStates = Window("Save States",  Rect(600, 50, 300, 260));
		globalWindowSaveStates.view.decorator_(FlowLayout(globalWindowSaveStates.bounds, 15@15, 10@10));
		saveStateButtons = [];
		4.do({
			|index|
			4.do({
				saveStateButtons = saveStateButtons ++
				Button(globalWindowSaveStates, Rect(0, 0, 60, 20)).states_([
				["save", Color.black, Color.cyan]
				]).action_({ |butt|
				"saved current configuration".postln;
				});
			});
			4.do({
				saveStateButtons = saveStateButtons ++
				Button(globalWindowSaveStates, Rect(0, 0, 60, 20)).states_([
				["load", Color.white, Color.blue]
				]).action_({ |butt|
				"loaded saved configuration".postln;
				});
			});
		});

		// performance page window
		globalWindowPerformancePage = Window("Performance Page Parameters",  Rect(600, 350, 300, 380));
		globalWindowPerformancePage.view.decorator_(FlowLayout(globalWindowPerformancePage.bounds, 15@15, 10@10));
		performancePagePopUpMenus = [];
		performancePageLabels = [];

		4.do({
			|index|
			performancePageCompViews = performancePageCompViews ++ [
				CompositeView(
					globalWindowPerformancePage,
					Rect(0, 0, 270, 80)).background_([Color.grey(0.3), Color.grey(0.5)].at(index.mod(2)) )];
			performancePageCompViews[index].decorator_(FlowLayout(performancePageCompViews[index].bounds, 0@0, 10@0));

			performancePageLabels = performancePageLabels ++ StaticText(performancePageCompViews[index], Rect(0, 0, 270, 20)).align_(\center).string_("Grouping:").stringColor_( [Color.white, Color.black].at(index.mod(2)) );
			performancePagePopUpMenus = performancePagePopUpMenus ++
			[{PopUpMenu(performancePageCompViews[index], Rect(0, 0, 60, 20))}!4];
			performancePageLabels = performancePageLabels ++ StaticText(performancePageCompViews[index], Rect(0, 0, 270, 20)).align_(\center).string_("Parameter:").stringColor_( [Color.white, Color.black].at(index.mod(2)) );
			performancePagePopUpMenus = performancePagePopUpMenus ++
			[{PopUpMenu(performancePageCompViews[index], Rect(0, 0, 60, 20))}!4];
		});

		8.do({
			|index|
			4.do({
				|index2|
				// add items to lists
				performancePagePopUpMenus[index][index2].items = [
					[
						"pitch", "velocity", "octave", "articulation", "ornamentation", "timing"
					], [
						"random", "steps", "confirming"
					]
				].at(index.mod(2));
			});
			if(index.mod(2) == 0, {
				// update lists with parameters on group change
				4.do({
					|index2|
					performancePagePopUpMenus[index][index2].action = {
						|pmenu|
						var oldval, newItems;
						oldval = performancePagePopUpMenus[index+1][index2].value;
						newItems = [
							[
								"random", "steps", "confirming"
							], [
								"density", "probability", "syncopation", "dynamics"
							], [
								"density", "probability", "offset"
							], [
								"slide", "staccato", "accent"
							], [
								"grace notes", "figures", "polyphony"
							], [
								"swing", "rubato"
							]
						].at(pmenu.value);
						performancePagePopUpMenus[index+1][index2].items = newItems;
						oldval = oldval.clip(0, newItems.size-1);
						performancePagePopUpMenus[index+1][index2].valueAction = oldval;
					};
				});
			});
		});

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
				text = text ++ TextView(window, Rect(
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
						window,
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
						window,
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

		// test dictionary
		paramDict = Dictionary();
		this.updateDict1; this.updateDict2;
		newUI.passDict(paramDict);

		// dictionary functions to regen values from the UI
		paramDict[\regenFuncPitch] = {
			this.calcPitchArray;
			this.calcPitchConfirming;
			this.calcPitchSteps;
			this.resetPitchMutation;
			this.updateDict1;
		};
		paramDict[\regenFuncOctave] = {
			this.calcOctaveArray;
			this.resetOctaveMutation;
			this.updateDict1;
		};
		paramDict[\regenFuncVelocity] = {
			this.calcVelocityArray;
			this.calcVelocityAccentArray;
			this.calcVelocitySyncopationArray;
			this.calcVelocityDynamicsArray;
			this.resetVelocityMutation;
			this.updateDict1;
		};
		paramDict[\regenFuncArticulation] = {
			this.calcArticulationSlideArray;
			this.calcArticulationStaccatoArray;
			this.calcArticulationAccentArray;
			this.resetArticulationMutation;
			this.updateDict1;
		};
		paramDict[\regenFuncOrnamentation] = {
			this.calcOrnamentationGraceNoteArray;
			this.calcOrnamentationFigureArray;
			this.resetOrnamentationMutation;
			this.updateDict1;
		};

		// update the parameters
		window.front;
		globalWindowSaveStates.front;
		globalWindowPerformancePage.front;
		this.textFunc;
		this.updatePlotters;

		newUI.updateP1Plotters;
	}

	// calculations offloaded to seperate file

	// getters
	getPitchArray {
		^pitchArray;
	}

	getPitchConfirmingArray {
		^pitchConfirmingArray;
	}

	getPitchStepsArray {
		^pitchStepsArray;
	}

	getOctaveArray {
		^octaveArray;
	}

	getVelocityArray {
		^velocityArray;
	}

	getVelocityAccentArray {
		^velocityAccentArray;
	}

	getVelocitySyncopationArray {
		^velocitySyncopationArray;
	}

	getVelocityDynamicsArray {
		^velocityDynamicsArray;
	}

	getGateStaccatoArray {
		^gateStaccatoArray;
	}

	getGateSlideArray {
		^gateSlideArray;
	}

	// setters
	setKnobVal {
		arg list, knob, val;
		if((list > -1).and(list < 6), {
			if((knob > -1).and(knob < 4), {
				knobLists[list][knob].valueAction = val;
			});
		});
	}

	setScale {
		arg rootIn, scaleIn;
		root = rootIn.mod(12);
		scale = scaleIn.mod(12);
	}

	setPitchRandom {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != pitchRandom, {
			"pitchRandom set to: ".post; value.postln;
			pitchRandom = value;
		});
	}

	setPitchSteps {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != pitchSteps, {
			"pitchSteps set to: ".post; value.postln;
			pitchSteps = value;
		});
	}

	setPitchConfirming {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != pitchConfirming, {
			"pitchConfirming set to: ".post; value.postln;
			pitchConfirming = value;
		});
	}

	setOctaveDensity {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != octaveDensity, {
			"octaveDensity set to: ".post; value.postln;
			octaveDensity = value;
		});
	}

	setOctaveProbability {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		//value = (value*dimensionSize - 0.001).asInteger;
		if(value != octaveProbability, {
			"octaveProbability set to: ".post; value.postln;
			octaveProbability = value;
		});
	}

	setOctaveOffset {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value * 4.99999).asInteger;
		value = [24, 36, 48, 60, 72].at(value);
		if(value != octave_offset, {
			"octave offset set to: ".post; value.postln;
			octave_offset = value;
		});
	}

	setVelocitySyncopation {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != velocitySyncopation, {
			"velocitySyncopation set to: ".post; value.postln;
			velocitySyncopation = value;
		});
	}

	setVelocityAccent { // will be deprecated
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != velocityAccent, {
			"velocityAccent set to: ".post; value.postln;
			velocityAccent = value;
		});
	}

	setVelocityDensity {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != velocityDensity, {
			"velocityDensity set to: ".post; value.postln;
			velocityDensity = value;
		});
	}

	setVelocityDynamics {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != velocityDynamics, {
			"velocityDynamics set to: ".post; value.postln;
			velocityDynamics = value;
		});
	}

	setVelocityProbability {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		//value = (value*dimensionSize - 0.001).asInteger;
		if(value != velocityProbability, {
			"velocityProbability set to: ".post; value.postln;
			velocityProbability = value;
		});
	}

	setGateStaccatoDensity { // will be deprecated
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != gateStaccatoDensity, {
			"gateStaccatoDensity set to: ".post; value.postln;
			gateStaccatoDensity = value;
		});
	}

	setGateSlideDensity { // will be deprecated
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != gateSlideDensity, {
			"gateSlideDensity set to: ".post; value.postln;
			gateSlideDensity = value;
		});
	}

	setArticulationSlideDensity {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != articulationSlideDensity, {
			"articulationSlideDensity set to: ".post; value.postln;
			articulationSlideDensity = value;
		});
	}

	setArticulationAccentDensity {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != articulationAccentDensity, {
			"articulationAccentDensity set to: ".post; value.postln;
			articulationAccentDensity = value;
		});
	}

	setArticulationStaccatoDensity {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != articulationStaccatoDensity, {
			"articulationStaccatoDensity set to: ".post; value.postln;
			articulationStaccatoDensity = value;
		});
	}

	setOrnamentationGraceNotes {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != ornamentationGraceNotes, {
			"ornamentationGraceNotes set to: ".post; value.postln;
			ornamentationGraceNotes = value;
		});
	}

	setOrnamentationFigures {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != ornamentationFigures, {
			"ornamentationFigures set to: ".post; value.postln;
			ornamentationFigures = value;
		});
	}

	setOrnamentationPolyphony {
		arg value; // expects 0.0-1.0 value
		value = value.clip(0.0, 1.0);
		value = (value*dimensionSize - 0.001).asInteger;
		if(value != ornamentationPolyphony, {
			"ornamentationPolyphony set to: ".post; value.postln;
			ornamentationPolyphony = value;
		});
	}

	setTimingSwing {
		arg value; // expects 0.0-1.0 value
		timingSwing = value.clip(0.0, 1.0);
		"timingSwing set to: ".post; timingSwing.postln;
		this.calcTimingArray;
	}

	setTimingRubato {
		arg value; // expects 0.0-1.0 value
		timingRubato = value.clip(0.0, 1.0);
		"timingRubato set to: ".post; timingRubato.postln;
		this.calcTimingArray;
	}

	setMutations {
		arg pitch, vel, oct, art, orn; // these are solely for the UI
		pitchMutation = pitch;
		velocityMutation = vel;
		octaveMutation = oct;
		articulationMutation = art;
		ornamentationMutation = orn;
		{
			this.updatePlotters;
		}.defer;
	}

	setPpqnResolution {
		arg value;
		ppqnResolution = value.clip(1, 10000);
	}
}