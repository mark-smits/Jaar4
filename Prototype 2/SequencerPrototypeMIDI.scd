// globals the MIDI influences

// mutations
~mutation1 = Dictionary.newFrom([
	\pitch, 0,
	\vel, 0,
	\oct, 0,
	\art, 0,
	\orn, 0,
]);
~mutation2 = Dictionary.newFrom([
	\pitch, 0,
	\vel, 0,
	\oct, 0,
	\art, 0,
	\orn, 0,
]);
~mutation3 = Dictionary.newFrom([
	\pitch, 0,
	\vel, 0,
	\oct, 0,
	\art, 0,
	\orn, 0,
]);
~mutation4 = Dictionary.newFrom([
	\pitch, 0,
	\vel, 0,
	\oct, 0,
	\art, 0,
	\orn, 0,
]);

// pages & focus
~page = 0; // pitch, velocity, octave, articulation, ornamentation, timing, sound
~synth_focus_nr = 0;

// sound params the sequencer task uses
~soundParams = Dictionary.newFrom([
	\acid1_cutoff, 220,
	\acid1_resonance, 0.5,
	\acid1_waveshape, 0,
	\acid1_glide, 0.0,
	\acid1_decay, 2.0,
	\acid1_drive, 1.0,
	\acid2_cutoff, 220,
	\acid2_resonance, 0.5,
	\acid2_waveshape, 0,
	\acid2_glide, 0.0,
	\acid2_decay, 2.0,
	\acid2_drive, 1.0,
	\foldy1_ratio1, 0.66,
	\foldy1_ratio2, 3.3,
	\foldy1_index1, 0.0,
	\foldy1_index2, 0.0,
	\foldy1_folding, 0.0,
	\foldy1_decay, 2.0,
	\foldy1_drive, 1.0,
	\foldy2_ratio1, 0.66,
	\foldy2_ratio2, 3.3,
	\foldy2_index1, 0.0,
	\foldy2_index2, 0.0,
	\foldy2_folding, 0.0,
	\foldy2_decay, 2.0,
	\foldy2_drive, 1.0,
]);

// virtual knobs influenced by encoder pages
// global
~decayKnobs = 63!4;
~driveKnobs = 63!4;
// acid
~cutoffKnobs = 63!2;
~resonanceKnobs = 63!2;
~waveshapeKnobs = 0!2;
~glideKnobs = 0!2;
// foldy
~rat1Knobs = 0!2;
~rat2Knobs = 0!2;
~index1Knobs = 0!2;
~index2Knobs = 0!2;
~foldingKnobs = 0!2;
// controls
~controlDicts = {
	var dimensionSize = 15;
	Dictionary.newFrom([
		\pitch_rand, (dimensionSize/2).floor,
		\pitch_steps, (dimensionSize/2).floor,
		\pitch_conf, (dimensionSize/2).floor,
		\pitch_length, 16,
		\pitch_mutation, 0,
		\vel_density, (dimensionSize/2).floor,
		\vel_probability, dimensionSize - 1,
		\vel_sync, (dimensionSize/2).floor,
		\vel_dyn, dimensionSize - 1,
		\vel_length, 16,
		\vel_mutation, 0,
		\oct_density, (dimensionSize/2).floor,
		\oct_probability, dimensionSize - 1,
		\oct_offset, 2,
		\oct_length, 16,
		\oct_mutation, 0,
		\art_staccato, 0,
		\art_slide, 0,
		\art_accents, 0,
		\art_length, 16,
		\art_mutation, 0,
		\orn_grace, 0,
		\orn_fig, 0,
		\orn_poly, 0,
		\orn_length, 16,
		\orn_mutation, 0,
		\timing_swing, 0,
		\timing_rubato, 0,
	])
}!4;

// function to update a sequencer with all information
~oldKnobValues = 0!4;
4.do({
	|index|
	~oldKnobValues[index] = [
		[
			~controlDicts[index][\pitch_rand]/14.0,
			~controlDicts[index][\pitch_steps]/14.0,
			~controlDicts[index][\pitch_conf]/14.0,
			0
		], [
			~controlDicts[index][\vel_density]/14.0,
			~controlDicts[index][\vel_probability]/14.0,
			~controlDicts[index][\vel_sync]/14.0,
			~controlDicts[index][\vel_dyn]/14.0
		], [
			~controlDicts[index][\oct_density]/14.0,
			~controlDicts[index][\oct_probability]/14.0,
			0,
			~controlDicts[index][\oct_offset]/4.0
		], [
			~controlDicts[index][\art_staccato]/14.0,
			~controlDicts[index][\art_slide]/14.0,
			~controlDicts[index][\art_accents]/14.0,
			0
		], [
			~controlDicts[index][\orn_grace]/14.0,
			~controlDicts[index][\orn_fig]/14.0,
			~controlDicts[index][\orn_poly]/14.0,
			0
		], [
			~controlDicts[index][\timing_swing]/14.0,
			~controlDicts[index][\timing_rubato]/14.0,
			0,
			0
		]
	];
});

~updateSequencer = {
	arg index;
	var values;
	values = [
		[
			~controlDicts[index][\pitch_rand]/14.0,
			~controlDicts[index][\pitch_steps]/14.0,
			~controlDicts[index][\pitch_conf]/14.0,
			0
		], [
			~controlDicts[index][\vel_density]/14.0,
			~controlDicts[index][\vel_probability]/14.0,
			~controlDicts[index][\vel_sync]/14.0,
			~controlDicts[index][\vel_dyn]/14.0
		], [
			~controlDicts[index][\oct_density]/14.0,
			~controlDicts[index][\oct_probability]/14.0,
			0,
			~controlDicts[index][\oct_offset]/4.0
		], [
			~controlDicts[index][\art_staccato]/14.0,
			~controlDicts[index][\art_slide]/14.0,
			~controlDicts[index][\art_accents]/14.0,
			0
		], [
			~controlDicts[index][\orn_grace]/14.0,
			~controlDicts[index][\orn_fig]/14.0,
			~controlDicts[index][\orn_poly]/14.0,
			0
		], [
			~controlDicts[index][\timing_swing]/14.0,
			~controlDicts[index][\timing_rubato]/14.0,
			0,
			0
		]
	];
	{
		6.do({
			|listIndex|
			4.do({
				|knobIndex|
				var value;
				value = values[listIndex][knobIndex];
				if((value == ~oldKnobValues[index][listIndex][knobIndex]).not, {
					p[index].setKnobVal(listIndex, knobIndex, value);
				});
				~oldKnobValues[index][listIndex][knobIndex] = value;
			});
		});
	}.defer;
	p[index].setPitchReset( (~controlDicts[index][\pitch_length] ).postln );
	p[index].setVelocityReset( (~controlDicts[index][\vel_length] ).postln );
	p[index].setOctaveReset( (~controlDicts[index][\oct_length] ).postln );
	p[index].setArticulationReset( (~controlDicts[index][\art_length] ).postln );
	p[index].setOrnamentationReset( (~controlDicts[index][\orn_length] ).postln );

	/*
	p[index].setPitchConfirming( (~controlDicts[index][\pitch_conf]/14.0 ).postln );
	p[index].setPitchRandom( (~controlDicts[index][\pitch_rand]/14.0 ).postln );
	p[index].setPitchSteps( (~controlDicts[index][\pitch_steps]/14.0 ).postln );
	p[index].setPitchReset( (~controlDicts[index][\pitch_length] ).postln );
	p[index].setVelocityDensity( (~controlDicts[index][\vel_density]/14.0 ).postln );
	p[index].setVelocityDynamics( (~controlDicts[index][\vel_dyn]/14.0 ).postln );
	p[index].setVelocityProbability( (~controlDicts[index][\vel_probability]/14.0 ).postln );
	p[index].setVelocitySyncopation( (~controlDicts[index][\vel_sync]/14.0 ).postln );
	p[index].setVelocityReset( (~controlDicts[index][\vel_length] ).postln );
	p[index].setOctaveDensity( (~controlDicts[index][\oct_density]/14.0 ).postln );
	p[index].setOctaveProbability( (~controlDicts[index][\oct_probability]/14.0 ).postln );
	p[index].setOctaveOffset( (~controlDicts[index][\oct_offset]/4.0 ).postln );
	p[index].setOctaveReset( (~controlDicts[index][\oct_length] ).postln );
	p[index].setArticulationAccentDensity( (~controlDicts[index][\art_accents]/14.0 ).postln );
	p[index].setArticulationSlideDensity( (~controlDicts[index][\art_slide]/14.0 ).postln );
	p[index].setArticulationStaccatoDensity( (~controlDicts[index][\art_staccato]/14.0 ).postln );
	p[index].setArticulationReset( (~controlDicts[index][\art_length] ).postln );
	p[index].setOrnamentationGraceNotes( (~controlDicts[index][\orn_grace]/14.0 ).postln );
	p[index].setOrnamentationFigures( (~controlDicts[index][\orn_fig]/14.0 ).postln );
	p[index].setOrnamentationPolyphony( (~controlDicts[index][\orn_poly]/14.0 ).postln );
	p[index].setOrnamentationReset( (~controlDicts[index][\orn_length] ).postln );
	p[index].setTimingSwing( (~controlDicts[index][\timing_swing]/14.0 ).postln );
	p[index].setTimingRubato( (~controlDicts[index][\timing_rubato]/14.0 ).postln );
	*/
};

// function to update mutations
~updateMutations = {
	arg index;
	switch(index,
		0, {
			~mutation1[\pitch] = ~controlDicts[index][\pitch_mutation];
			~mutation1[\vel] = ~controlDicts[index][\vel_mutation];
			~mutation1[\oct] = ~controlDicts[index][\oct_mutation];
			~mutation1[\art] = ~controlDicts[index][\art_mutation];
			~mutation1[\orn] = ~controlDicts[index][\orn_mutation];
		},
		1, {
			~mutation2[\pitch] = ~controlDicts[index][\pitch_mutation];
			~mutation2[\vel] = ~controlDicts[index][\vel_mutation];
			~mutation2[\oct] = ~controlDicts[index][\oct_mutation];
			~mutation2[\art] = ~controlDicts[index][\art_mutation];
			~mutation2[\orn] = ~controlDicts[index][\orn_mutation];
		},
		2, {
			~mutation3[\pitch] = ~controlDicts[index][\pitch_mutation];
			~mutation3[\vel] = ~controlDicts[index][\vel_mutation];
			~mutation3[\oct] = ~controlDicts[index][\oct_mutation];
			~mutation3[\art] = ~controlDicts[index][\art_mutation];
			~mutation3[\orn] = ~controlDicts[index][\orn_mutation];
		},
		3, {
			~mutation4[\pitch] = ~controlDicts[index][\pitch_mutation];
			~mutation4[\vel] = ~controlDicts[index][\vel_mutation];
			~mutation4[\oct] = ~controlDicts[index][\oct_mutation];
			~mutation4[\art] = ~controlDicts[index][\art_mutation];
			~mutation4[\orn] = ~controlDicts[index][\orn_mutation];
		},
	);
	p[index].setMutations(
		~controlDicts[index][\pitch_mutation],
		~controlDicts[index][\vel_mutation],
		~controlDicts[index][\oct_mutation],
		~controlDicts[index][\art_mutation],
		~controlDicts[index][\orn_mutation]
	);
};

// functions to update synths
~updateAcidSynth = {
	arg index;
	switch(index,
		0, {
			~soundParams[\acid1_cutoff] = ~cutoffKnobs[0].linexp(0, 127, 50, 1000); // apply scaling
			~soundParams[\acid1_resonance] = ~resonanceKnobs[0]/127.0;
			~soundParams[\acid1_waveshape] = (~waveshapeKnobs[0]/63.0).asInteger;
			~soundParams[\acid1_glide] = ~glideKnobs[0]/127.0;
			~soundParams[\acid1_decay] = ~decayKnobs[0]/127.0 + 0.5;
			~soundParams[\acid1_drive] = ~driveKnobs[0]/127.0;
		},
		1, {
			~soundParams[\acid2_cutoff] = ~cutoffKnobs[1].linexp(0, 127, 50, 1000);
			~soundParams[\acid2_resonance] = ~resonanceKnobs[1]/127.0;
			~soundParams[\acid2_waveshape] = (~waveshapeKnobs[1]/63.0).asInteger;
			~soundParams[\acid2_glide] = ~glideKnobs[1]/127.0;
			~soundParams[\acid2_decay] = ~decayKnobs[1]/127.0 + 0.5;
			~soundParams[\acid2_drive] = ~driveKnobs[1]/127.0;
		},
	);
};
~updateFoldingSynth = {
	arg index;
	var choices1, choices2;
	choices1 = [1.0, 0.8, 0.75, 0.66, 0.6, 0.5];
	choices2 = [1.0, 1.5, 2.25, 2.5, 3.3, 5.0];
	switch(index,
		2, {
			~soundParams[\foldy1_ratio1] = choices1[ ~rat1Knobs[0].linlin(0, 127, 0, choices1.size - 1).postln ].postln;
			~soundParams[\foldy1_ratio2] = choices2[ ~rat2Knobs[0].linlin(0, 127, 0, choices2.size - 1).postln ].postln;
			~soundParams[\foldy1_index1] = ~index1Knobs[0]/127.0;
			~soundParams[\foldy1_index2] = ~index2Knobs[0]/127.0;
			~soundParams[\foldy1_folding] = ~foldingKnobs[0];
			~soundParams[\foldy1_decay] = ~decayKnobs[2]/127.0 + 0.5;
			~soundParams[\foldy1_drive] = ~driveKnobs[2]/127.0;
		},
		3, {
			~soundParams[\foldy2_ratio1] = choices1[ ~rat1Knobs[1].linlin(0, 127, 0, choices1.size - 1).postln ].postln;
			~soundParams[\foldy2_ratio2] = choices2[ ~rat2Knobs[1].linlin(0, 127, 0, choices2.size - 1).postln ].postln;
			~soundParams[\foldy2_index1] = ~index1Knobs[1]/127.0;
			~soundParams[\foldy2_index2] = ~index2Knobs[1]/127.0;
			~soundParams[\foldy2_folding] = ~foldingKnobs[1];
			~soundParams[\foldy2_decay] = ~decayKnobs[3]/127.0 + 0.5;
			~soundParams[\foldy2_drive] = ~driveKnobs[3]/127.0;
		},
	);
};

// MIDI stuff

MIDIClient.init;
MIDIIn.connectAll;

MIDIdef.cc(\MFTwister, {
	arg val, cc, chan, src;
	/*
	("encoder " ++ cc.asString).post;
	switch(val,
		63, {" moved counterclockwise".postln},
		65, {" moved clockwise".postln},
		0, {" button released".postln},
		127, {" button pressed".postln},
	);
	*/
	if(chan == 0, {
		var inc;
		if(val == 63, { inc = -1; });
		if(val == 65, { inc = 1; });

		switch(cc,
			0, {
				~decayKnobs[0] = (~decayKnobs[0] + inc).clip(0, 127).postln;
				~updateAcidSynth.value(0);
			},
			1, {
				~decayKnobs[1] = (~decayKnobs[1] + inc).clip(0, 127).postln;
				~updateAcidSynth.value(1);
			},
			2, {
				~decayKnobs[2] = (~decayKnobs[2] + inc).clip(0, 127).postln;
				~updateFoldingSynth.value(2);
			},
			3, {
				~decayKnobs[3] = (~decayKnobs[3] + inc).clip(0, 127).postln;
				~updateFoldingSynth.value(3);
			},
			4, {
				~driveKnobs[0] = (~driveKnobs[0] + inc).clip(0, 127).postln;
				~updateAcidSynth.value(0);
			},
			5, {
				~driveKnobs[1] = (~driveKnobs[1] + inc).clip(0, 127).postln;
				~updateAcidSynth.value(1);
			},
			6, {
				~driveKnobs[2] = (~driveKnobs[2] + inc).clip(0, 127).postln;
				~updateFoldingSynth.value(2);
			},
			7, {
				~driveKnobs[3] = (~driveKnobs[3] + inc).clip(0, 127).postln;
				~updateFoldingSynth.value(3);
			},
			8, {
				switch(~page,
					0, { // pitch
						~controlDicts[~synth_focus_nr][\pitch_rand] = (~controlDicts[~synth_focus_nr][\pitch_rand] + inc).clip(0, 14);
					},
					1, { // velocity
						~controlDicts[~synth_focus_nr][\vel_density] = (~controlDicts[~synth_focus_nr][\vel_density] + inc).clip(0, 14);
					},
					2, { // octave
						~controlDicts[~synth_focus_nr][\oct_density] = (~controlDicts[~synth_focus_nr][\oct_density] + inc).clip(0, 14);
					},
					3, { // articulation
						~controlDicts[~synth_focus_nr][\art_staccato] = (~controlDicts[~synth_focus_nr][\art_staccato] + inc).clip(0, 14);
					},
					4, { // ornamentation
						~controlDicts[~synth_focus_nr][\orn_grace] = (~controlDicts[~synth_focus_nr][\orn_grace] + inc).clip(0, 14);
					},
					5, { // timing
						~controlDicts[~synth_focus_nr][\timing_swing] = (~controlDicts[~synth_focus_nr][\timing_swing] + inc).clip(0, 14);
					},
					6, { //  sound params
						switch(~synth_focus_nr,
							0, {
								~resonanceKnobs[0] = (~resonanceKnobs[0]+inc).clip(0,127);
							},
							1, {
								~resonanceKnobs[1] = (~resonanceKnobs[1]+inc).clip(0,127);
							},
							2, {
								~rat1Knobs[0] = (~rat1Knobs[0]+inc).clip(0,127).postln;
							},
							3, {
								~rat1Knobs[1] = (~rat1Knobs[1]+inc).clip(0,127).postln;
							},
						);
					},
				);
			},
			9, {
				switch(~page,
					0, { // pitch
						~controlDicts[~synth_focus_nr][\pitch_steps] = (~controlDicts[~synth_focus_nr][\pitch_steps] + inc).clip(0, 14);
					},
					1, { // velocity
						~controlDicts[~synth_focus_nr][\vel_probability] = (~controlDicts[~synth_focus_nr][\vel_probability] + inc).clip(0, 14);
					},
					2, { // octave
						~controlDicts[~synth_focus_nr][\oct_probability] = (~controlDicts[~synth_focus_nr][\oct_probability] + inc).clip(0, 14);
					},
					3, { // articulation
						~controlDicts[~synth_focus_nr][\art_slide] = (~controlDicts[~synth_focus_nr][\art_slide] + inc).clip(0, 14);
					},
					4, { // ornamentation
						~controlDicts[~synth_focus_nr][\orn_fig] = (~controlDicts[~synth_focus_nr][\orn_fig] + inc).clip(0, 14);
					},
					5, { // timing
						~controlDicts[~synth_focus_nr][\timing_rubato] = (~controlDicts[~synth_focus_nr][\timing_rubato] + inc).clip(0, 14);
					},
					6, { //  sound params
						switch(~synth_focus_nr,
							0, {

							},
							1, {

							},
							2, {
								~rat2Knobs[0] = (~rat2Knobs[0]+inc).clip(0,127).postln;
							},
							3, {
								~rat2Knobs[1] = (~rat2Knobs[1]+inc).clip(0,127).postln;
							},
						);
					},
				);
			},
			10, {
				switch(~page,
					0, { // pitch
						~controlDicts[~synth_focus_nr][\pitch_conf] = (~controlDicts[~synth_focus_nr][\pitch_conf] + inc).clip(0, 14);
					},
					1, { // velocity
						~controlDicts[~synth_focus_nr][\vel_sync] = (~controlDicts[~synth_focus_nr][\vel_sync] + inc).clip(0, 14);
					},
					3, { // articulation
						~controlDicts[~synth_focus_nr][\art_accents] = (~controlDicts[~synth_focus_nr][\art_accents] + inc).clip(0, 14);
					},
					4, { // ornamentation
						~controlDicts[~synth_focus_nr][\orn_poly] = (~controlDicts[~synth_focus_nr][\orn_poly] + inc).clip(0, 14);
					},
					6, { //  sound params
						switch(~synth_focus_nr,
							0, {

							},
							1, {

							},
							2, {

							},
							3, {

							},
						);
					},
				);
			},
			11, {
				switch(~page,
					1, { // velocity
						~controlDicts[~synth_focus_nr][\vel_dyn] = (~controlDicts[~synth_focus_nr][\vel_dyn] + inc).clip(0, 14);
					},
					2, { // octave
						~controlDicts[~synth_focus_nr][\oct_offset] = (~controlDicts[~synth_focus_nr][\oct_offset] + inc).clip(0, 4);
					},
				);
			},
			12, {
				switch(~page,
					0, { // pitch
						~controlDicts[~synth_focus_nr][\pitch_length] = (~controlDicts[~synth_focus_nr][\pitch_length] + inc).clip(1, 64);
					},
					1, { // velocity
						~controlDicts[~synth_focus_nr][\vel_length] = (~controlDicts[~synth_focus_nr][\vel_length] + inc).clip(1, 64);
					},
					2, { // octave
						~controlDicts[~synth_focus_nr][\oct_length] = (~controlDicts[~synth_focus_nr][\oct_length] + inc).clip(1, 64);
					},
					3, { // articulation
						~controlDicts[~synth_focus_nr][\art_length] = (~controlDicts[~synth_focus_nr][\art_length] + inc).clip(1, 64);
					},
					4, { // ornamentation
						~controlDicts[~synth_focus_nr][\orn_length] = (~controlDicts[~synth_focus_nr][\orn_length] + inc).clip(1, 64);
					},
					6, { //  sound params
						switch(~synth_focus_nr,
							0, {
								~cutoffKnobs[0] = (~cutoffKnobs[0]+inc).clip(0,127);
							},
							1, {
								~cutoffKnobs[1] = (~cutoffKnobs[1]+inc).clip(0,127);
							},
							2, {
								~index1Knobs[0] = (~index1Knobs[0]+inc).clip(0,127);
							},
							3, {
								~index1Knobs[1] = (~index1Knobs[1]+inc).clip(0,127);
							},
						);
					},
				);
			},
			13, {
				switch(~page,
					6, { //  sound params
						switch(~synth_focus_nr,
							0, {
								~waveshapeKnobs[0] = (~waveshapeKnobs[0]+inc).clip(0,127);
							},
							1, {
								~waveshapeKnobs[1] = (~waveshapeKnobs[1]+inc).clip(0,127);
							},
							2, {
								~index2Knobs[0] = (~index2Knobs[0]+inc).clip(0,127);
							},
							3, {
								~index2Knobs[1] = (~index2Knobs[1]+inc).clip(0,127);
							},
						);
					},
				);
			},
			14, {
				switch(~page,
					// recalc data
					0, { // pitch
						p[~synth_focus_nr].calcPitchArray;
						p[~synth_focus_nr].calcPitchSteps;
						p[~synth_focus_nr].calcPitchConfirming;
						p[~synth_focus_nr].resetPitchMutation;
					},
					1, { // velocity
						p[~synth_focus_nr].calcVelocityArray;
						p[~synth_focus_nr].calcVelocityDynamicsArray;
						p[~synth_focus_nr].calcVelocitySyncopationArray;
						p[~synth_focus_nr].resetVelocityMutation;
					},
					2, { // octave
						p[~synth_focus_nr].calcOctaveArray;
						p[~synth_focus_nr].resetOctaveMutation;
					},
					3, { // articulation
						p[~synth_focus_nr].calcArticulationAccentArray;
						p[~synth_focus_nr].calcArticulationSlideArray;
						p[~synth_focus_nr].calcArticulationStaccatoArray;
						p[~synth_focus_nr].resetArticulationMutation;
					},
					4, { // ornamentation
						p[~synth_focus_nr].calcOrnamentationFigureArray;
						p[~synth_focus_nr].calcOrnamentationGraceNoteArray;
						p[~synth_focus_nr].resetOrnamentationMutation;
					},
					6, { //  sound params
						switch(~synth_focus_nr,
							0, {
								~glideKnobs[0] = (~glideKnobs[0]+inc).clip(0,127);
							},
							1, {
								~gildeKnobs[1] = (~glideKnobs[1]+inc).clip(0,127);
							},
							2, {
								~foldingKnobs[0] = (~foldingKnobs[0]+inc).clip(0,127);
							},
							3, {
								~foldingKnobs[1] = (~foldingKnobs[1]+inc).clip(0,127);
							},
						);
					},
				);
			},
			15, {
				switch(~page,
					0, { // pitch
						~controlDicts[~synth_focus_nr][\pitch_mutation] = (~controlDicts[~synth_focus_nr][\pitch_mutation] + inc).clip(0, 3);
					},
					1, { // velocity
						~controlDicts[~synth_focus_nr][\vel_mutation] = (~controlDicts[~synth_focus_nr][\vel_mutation] + inc).clip(0, 3);
					},
					2, { // octave
						~controlDicts[~synth_focus_nr][\oct_mutation] = (~controlDicts[~synth_focus_nr][\oct_mutation] + inc).clip(0, 3);
					},
					3, { // articulation
						~controlDicts[~synth_focus_nr][\art_mutation] = (~controlDicts[~synth_focus_nr][\art_mutation] + inc).clip(0, 3);
					},
					4, { // ornamentation
						~controlDicts[~synth_focus_nr][\orn_mutation] = (~controlDicts[~synth_focus_nr][\orn_mutation] + inc).clip(0, 3);
					},
				);
			},
		);
		if(cc > 7, {
			if(~page < 6, {
				~updateSequencer.value(~synth_focus_nr);
				~updateMutations.value(~synth_focus_nr);
			}, {
				~updateAcidSynth.value(~synth_focus_nr);
				~updateFoldingSynth.value(~synth_focus_nr);
			});
		});
	});
});

MIDIdef.noteOn(\MF3D, {
	arg vel, nr, chan, src;

	// MIDI fighter 3D 36-51 noteOn 127
	if(chan == 2, {
		switch(nr,
			36, {
				p.do({
					|prot, index|
					prot.setScale(
						1,
						[0, 2, 3, 5, 7, 8, 10, 12]
					);
				});
			},
			37, {
				p.do({
					|prot, index|
					prot.setScale(
						5,
						[0, 2, 3, 5, 7, 8, 10, 12]
					);
				});
			},
			38, {
				p.do({
					|prot, index|
					prot.setScale(
						4,
						[0, 2, 4, 6, 7, 9, 11, 12]
					);
				});
			},
			39, {
				p.do({
					|prot, index|
					prot.setScale(
						3,
						[0, 2, 3, 5, 7, 9, 10, 12]
					);
				});
			},
			40, {
				p.do({
					|prot, index|
					prot.setScale(
						0,
						[0, 2, 3, 5, 7, 8, 10, 12]
					);
				});
			},
			41, {
				p.do({
					|prot, index|
					prot.setScale(
						4,
						[0, 2, 3, 5, 7, 8, 10, 12]
					);
				});
			},
			42, {
				p.do({
					|prot, index|
					prot.setScale(
						3,
						[0, 2, 4, 6, 7, 9, 11, 12]
					);
				});
			},
			43, {
				p.do({
					|prot, index|
					prot.setScale(
						2,
						[0, 2, 3, 5, 7, 9, 10, 12]
					);
				});
			},
			48, { ~page = 0; },
			49, { ~page = 1; },
			50, { ~page = 2; },
			51, { ~page = 3; },
			44, { ~page = 4; },
			45, { ~page = 5; },
			46, { ~page = 6; },
		);
		~page.postln;
		{
			p.do({
				|prot, index|
				prot.setFocusColor(~page);
			});
		}.defer
	});

	if(chan == 3, {
		~synth_focus_nr = nr.postln;
	});
});

~resetControlDicts = {
	~controlDicts = {
		var dimensionSize = 15;
		Dictionary.newFrom([
			\pitch_rand, (dimensionSize/2).floor,
			\pitch_steps, (dimensionSize/2).floor,
			\pitch_conf, (dimensionSize/2).floor,
			\pitch_length, 16,
			\pitch_mutation, 0,
			\vel_density, (dimensionSize/2).floor,
			\vel_probability, dimensionSize - 1,
			\vel_sync, (dimensionSize/2).floor,
			\vel_dyn, dimensionSize - 1,
			\vel_length, 16,
			\vel_mutation, 0,
			\oct_density, (dimensionSize/2).floor,
			\oct_probability, dimensionSize - 1,
			\oct_offset, 2,
			\oct_length, 16,
			\oct_mutation, 0,
			\art_staccato, 0,
			\art_slide, 0,
			\art_accents, 0,
			\art_length, 16,
			\art_mutation, 0,
			\orn_grace, 0,
			\orn_fig, 0,
			\orn_poly, 0,
			\orn_length, 16,
			\orn_mutation, 0,
			\timing_swing, 0,
			\timing_rubato, 0,
		])
	}!4;
	4.do({
		|index|
		~updateSequencer.value(index);
	});
};

/*
MIDIdef.cc(\MFTwister, {
	arg val, cc, chan, src;
	// MIDI fighter Twister 60-63, 56-59, 52-55, 48-51
	if(chan == 0, {
		switch(cc,
			60, {
				~soundParams[\acid_cutoff] = val.linexp(0, 127, 50, 1000);
				"cutoff set to: ".post;
				~soundParams[\acid_cutoff].postln;
			},
			61, {
				~soundParams[\acid_resonance] = val/127.0;
				"resonance set to: ".post;
				~soundParams[\acid_resonance].postln;
			},
			62, {
				~soundParams[\foldy_index1] = val/127.0;
				"index 1 set to: ".post;
				~soundParams[\foldy_index1].postln;
			},
			63, {
				~soundParams[\foldy_index2] = val/127.0;
				"index 2 set to: ".post;
				~soundParams[\foldy_index2].postln;
			},
			56, {
				~soundParams[\acid_waveshape] = (val/63.0).asInteger;
				"waveshape set to: ".post;
				~soundParams[\acid_waveshape].postln;
			},
			57, {
				~soundParams[\acid_glide] = val/127.0;
				"glide set to: ".post;
				~soundParams[\acid_glide].postln;
			},
			58, {
				var choices;
				choices = [1.0, 0.8, 0.75, 0.66, 0.6, 0.5];
				~soundParams[\foldy_ratio1] = choices[ val.linlin(0, 127, 0, choices.size - 1) ];
				"ratio 1 set to: ".post;
				~soundParams[\foldy_ratio1].postln;
			},
			59, {
				var choices;
				choices = [1.0, 1.5, 2.25, 2.5, 3.3, 5.0];
				~soundParams[\foldy_ratio2] = choices[ val.linlin(0, 127, 0, choices.size - 1) ];
				"index 2 set to: ".post;
				~soundParams[\foldy_ratio2].postln;
			},
			54, {
				~soundParams[\foldy_folding] = val/127.0;
				"folding set to: ".post;
				~soundParams[\foldy_folding].postln;
			},
			48, {
				~soundParams[\acid_decay] = val/127.0 + 0.5;
				"decay set to: ".post;
				~soundParams[\acid_decay].postln;
			},
			49, {
				~soundParams[\acid_drive] = val/127.0;
				"drive set to: ".post;
				~soundParams[\acid_drive].postln;
			},
			50, {
				~soundParams[\foldy_decay] = val/127.0 + 0.5;
				"decay set to: ".post;
				~soundParams[\foldy_decay].postln;
			},
			51, {
				~soundParams[\foldy_drive] = val/127.0;
				"drive set to: ".post;
				~soundParams[\foldy_drive].postln;
			},
		)
	});
});

MIDIdef.noteOn(\MF3D, {
	arg vel, nr, chan, src;

	// MIDI fighter 3D 36-51 noteOn 127
	if(chan == 2, {
		switch(nr,
			36, {
				p.resetMutations;
			},
			37, {
				~mutation1 = 0;
			},
			38, {
				q.resetMutations;
			},
			39, {
				~mutation2 = 0;
			},
			40, {
				p.mutateGate(1);
				p.mutateOctave(1);
				p.mutatePitch(1);
				p.mutateVelocity(1);
			},
			41, {
				~mutation1 = 1;
			},
			42, {
				q.mutateGate(1);
				q.mutateOctave(1);
				q.mutatePitch(1);
				q.mutateVelocity(1);
			},
			43, {
				~mutation2 = 1;
			},
			44, {
				p.mutateGate(2);
				p.mutateOctave(2);
				p.mutatePitch(2);
				p.mutateVelocity(2);
			},
			45, {
				~mutation1 = 2;
			},
			46, {
				q.mutateGate(2);
				q.mutateOctave(2);
				q.mutatePitch(2);
				q.mutateVelocity(2);
			},
			47, {
				~mutation2 = 2;
			},
			48, {
				p.mutateGate(3);
				p.mutateOctave(3);
				p.mutatePitch(3);
				p.mutateVelocity(3);
			},
			49, {
				~mutation1 = 3;
			},
			50, {
				q.mutateGate(3);
				q.mutateOctave(3);
				q.mutatePitch(3);
				q.mutateVelocity(3);
			},
			51, {
				~mutation2 = 3;
			},
		)
	});
});

MIDIdef.cc(\LauncControlXL, {
	arg val, cc, chan, src;

	/*
	volume fader 1-8 -> cc's 77-84
	green pots 1-8 -> 49-56
	yellow pots 1-8 -> 29-36
	red pots 1-8 -> 13-20
	*/

	if(chan == 4, {
		switch(cc,
			// p params
			13, {
				p.setPitchRandom(val/127.0);
			},
			14, {
				p.setOctaveDensity(val/127.0);
			},
			15, {
				p.setVelocityDensity(val/127.0);
			},
			16, {
				p.setVelocityAccent(val/127.0);
			},
			29, {
				p.setVelocitySyncopation(val/127.0);
			},
			30, {
				p.setGateStaccatoDensity(val/127.0);
			},
			31, {
				p.setGateSlideDensity(val/127.0);
			},
			49, {
				p.setTimingSwing(val/127.0);
			},
			50, {
				p.setTimingRubato(val/127.0);
			},
			// q params
			17, {
				q.setPitchRandom(val/127.0);
			},
			18, {
				q.setOctaveDensity(val/127.0);
			},
			19, {
				q.setVelocityDensity(val/127.0);
			},
			20, {
				q.setVelocityAccent(val/127.0);
			},
			33, {
				q.setVelocitySyncopation(val/127.0);
			},
			34, {
				q.setGateStaccatoDensity(val/127.0);
			},
			35, {
				q.setGateSlideDensity(val/127.0);
			},
			53, {
				q.setTimingSwing(val/127.0);
			},
			54, {
				q.setTimingRubato(val/127.0);
			},
			// indices
			77, {
				p.setPitchReset(
					[1, 2, 3, 4, 5, 7, 8, 12, 16].at(
						((val/127.0*9)-0.0001).asInteger
					)
				);
				((val/127.0*9)-0.0001).asInteger.postln;
			},
			78, {
				p.setOctaveReset(
					[1, 2, 3, 4, 5, 7, 8, 12, 16].at(
						((val/127.0*9)-0.0001).asInteger
					)
				);
				((val/127.0*9)-0.0001).asInteger.postln;
			},
			79, {
				p.setVelocityReset(
					[1, 2, 3, 4, 5, 7, 8, 12, 16].at(
						((val/127.0*9)-0.0001).asInteger
					)
				);
				((val/127.0*9)-0.0001).asInteger.postln;
			},
			80, {
				p.setGateReset(
					[1, 2, 3, 4, 5, 7, 8, 12, 16].at(
						((val/127.0*9)-0.0001).asInteger
					)
				);
				((val/127.0*9)-0.0001).asInteger.postln;
			},
			81, {
				q.setPitchReset(
					[1, 2, 3, 4, 5, 7, 8, 12, 16].at(
						((val/127.0*9)-0.0001).asInteger
					)
				);
				((val/127.0*9)-0.0001).asInteger.postln;
			},
			82, {
				q.setOctaveReset(
					[1, 2, 3, 4, 5, 7, 8, 12, 16].at(
						((val/127.0*9)-0.0001).asInteger
					)
				);
				((val/127.0*9)-0.0001).asInteger.postln;
			},
			83, {
				q.setVelocityReset(
					[1, 2, 3, 4, 5, 7, 8, 12, 16].at(
						((val/127.0*9)-0.0001).asInteger
					)
				);
				((val/127.0*9)-0.0001).asInteger.postln;
			},
			84, {
				q.setGateReset(
					[1, 2, 3, 4, 5, 7, 8, 12, 16].at(
						((val/127.0*9)-0.0001).asInteger
					)
				);
				((val/127.0*9)-0.0001).asInteger.postln;
			},
		)
	});
});
*/