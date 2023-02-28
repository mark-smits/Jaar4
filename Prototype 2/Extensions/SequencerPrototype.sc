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
	// ouput locked arrays
	lockedPitchArray,
	lockedVelocityArray,
	lockedOctaveArray,
	lockedArticulationArray,
	lockedOrnamentationArray,
	lockedTimingArray,
	/*
	lockedPitchPositionsArray,
	lockedVelocityPositionsArray,
	lockedOctavePositionsArray,
	lockedArticulationPositionsArray,
	lockedOrnamentationPositionsArray,
	lockedTimingPositionsArray,
	*/
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

		paramDict = Dictionary();

		// initialize parameters

		scale = [0, 2, 3, 5, 7, 8, 10, 12];

		paramDict[\dimensionSize] = dimensionSize;
		paramDict[\pitchRandom] = (dimensionSize/2.0).floor;
		paramDict[\pitchSteps] = (dimensionSize/2.0).floor;
		paramDict[\pitchConfirming] = (dimensionSize/2.0).floor;
		paramDict[\pitchTonality] = (dimensionSize/2.0).floor;
		paramDict[\octaveDensity] = (dimensionSize/2.0).floor;
		paramDict[\octaveProbability] = (dimensionSize/2.0).floor;
		paramDict[\velocitySyncopation] = (dimensionSize/2.0).floor;
		paramDict[\velocityAccent] = (dimensionSize/2.0).floor; // will be deprecated
		paramDict[\velocityDensity] = (dimensionSize/2.0).floor;
		paramDict[\velocityProbability] = (dimensionSize/2.0).floor;
		paramDict[\velocityDynamics] = (dimensionSize/2.0).floor;
		paramDict[\articulationStaccatoDensity] = 0;
		paramDict[\articulationSlideDensity] = 0;
		paramDict[\articulationAccentDensity] = 0;
		paramDict[\ornamentationGraceNotes] = 0;
		paramDict[\ornamentationFigures] = 0;
		paramDict[\ornamentationPolyphony] = 0;
		paramDict[\gateLength] = (dimensionSize/2.0).floor; // will be deprecated
		paramDict[\gateStaccatoDensity] = (dimensionSize/2.0).floor; // will be deprecated
		paramDict[\gateSlideDensity] = (dimensionSize/2.0).floor; // will be deprecated
		paramDict[\timingSwing] = 0.0;
		paramDict[\timingRubato] = 0.0;

		paramDict[\pitchReset] = 16;
		paramDict[\velocityReset] = 16;
		paramDict[\octaveReset] = 16;
		paramDict[\articulationReset] = 16;
		paramDict[\ornamentationReset] = 16;
		paramDict[\timingReset] = 16;

		paramDict[\lockedPitchPositionsArray] = 0!16;
		paramDict[\lockedVelocityPositionsArray] = 0!16;
		paramDict[\lockedOctavePositionsArray] = 0!16;
		paramDict[\lockedArticulationPositionsArray] = 0!16;
		paramDict[\lockedOrnamentationPositionsArray] = 0!16;
		paramDict[\lockedTimingPositionsArray] = 0!16;

		paramDict[\pitchLockPulses] = 0; paramDict[\pitchLockRotation] = 0; paramDict[\pitchSequenceReset] = 16;
		paramDict[\velocityLockPulses] = 0; paramDict[\velocityLockRotation] = 0; paramDict[\velocitySequenceReset] = 16;
		paramDict[\octaveLockPulses] = 0; paramDict[\octaveLockRotation] = 0; paramDict[\octaveSequenceReset] = 16;
		paramDict[\articulationLockPulses] = 0; paramDict[\articulationLockRotation] = 0; paramDict[\articulationSequenceReset] = 16;
		paramDict[\ornamentationLockPulses] = 0; paramDict[\ornamentationLockRotation] = 0; paramDict[\ornamentationSequenceReset] = 16;
		paramDict[\timingLockPulses] = 0; paramDict[\timingLockRotation] = 0; paramDict[\timingSequenceReset] = 16;

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
		this.resetIndices;

		// generate UI = outsourced

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

		// test dictionary
		this.updateDictArrays; this.updateDictIndices;
		newUI.passDict(paramDict);

		// dictionary functions to regen values from the UI
		paramDict[\regenFuncPitch] = {
			this.calcPitchArray;
			this.calcPitchConfirming;
			this.calcPitchSteps;
			this.resetPitchMutation;
			this.updateDictArrays;
		};
		paramDict[\regenFuncOctave] = {
			this.calcOctaveArray;
			this.resetOctaveMutation;
			this.updateDictArrays;
		};
		paramDict[\regenFuncVelocity] = {
			this.calcVelocityArray;
			this.calcVelocityAccentArray;
			this.calcVelocitySyncopationArray;
			this.calcVelocityDynamicsArray;
			this.resetVelocityMutation;
			this.updateDictArrays;
		};
		paramDict[\regenFuncArticulation] = {
			this.calcArticulationSlideArray;
			this.calcArticulationStaccatoArray;
			this.calcArticulationAccentArray;
			this.resetArticulationMutation;
			this.updateDictArrays;
		};
		paramDict[\regenFuncOrnamentation] = {
			this.calcOrnamentationGraceNoteArray;
			this.calcOrnamentationFigureArray;
			this.resetOrnamentationMutation;
			this.updateDictArrays;
		};
		paramDict[\regenFuncPitchLocks] = {
			this.updatePitchLocks;
		};
		paramDict[\regenFuncVelocityLocks] = {
			this.updateVelocityLocks;
		};
		paramDict[\regenFuncOctaveLocks] = {
			this.updateOctaveLocks;
		};
		paramDict[\regenFuncArticulationLocks] = {
			this.updateArticulationLocks;
		};
		paramDict[\regenFuncOrnamentationLocks] = {
			this.updateOrnamentationLocks;
		};
		paramDict[\regenFuncTimingLocks] = {
			this.updateTimingLocks;
		};

		// update the parameters
		globalWindowSaveStates.front;
		globalWindowPerformancePage.front;

		newUI.updateP1Plotters; newUI.updateP3Plotters;
	}

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

	/*

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

	*/

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