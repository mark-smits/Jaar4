+ SequencerPrototype {

	// functions for sequencing

	tickIndices {
		paramDict[\pitchIndex] = (paramDict[\pitchIndex] + 1).mod(paramDict[\pitchReset]);
		paramDict[\octaveIndex] = (paramDict[\octaveIndex] + 1).mod(paramDict[\octaveReset]);
		paramDict[\velocityIndex] = (paramDict[\velocityIndex] + 1).mod(paramDict[\velocityReset]);
		//paramDict[\gateIndex] = (paramDict[\gateIndex] + 1).mod(paramDict[\gateReset]); // will be deprecated
		paramDict[\articulationIndex] = (paramDict[\articulationIndex] + 1).mod(paramDict[\articulationReset]);
		paramDict[\ornamentationIndex] = (paramDict[\ornamentationIndex] + 1).mod(paramDict[\ornamentationReset]);
		paramDict[\timingIndex] = (paramDict[\timingIndex] + 1).mod(paramDict[\timingReset]);
	}

	resetVelocityIndex {
		// also seperately available if necessary due to syncopation
		paramDict[\velocityIndex] = 0;
	}

	resetIndices {
		paramDict[\pitchIndex] = 0;
		paramDict[\octaveIndex] = 0;
		paramDict[\velocityIndex] = 0;
		paramDict[\gateIndex] = 0; // will be deorecated
		paramDict[\articulationIndex] = 0;
		paramDict[\ornamentationIndex] = 0;
		paramDict[\timingIndex] = 0;
	}

	setPitchReset {
		arg reset;
		paramDict[\pitchReset] = reset.clip(1, 64);
	}

	setOctaveReset {
		arg reset;
		paramDict[\octaveReset] = reset.clip(1, 64);
	}

	setVelocityReset {
		arg reset;
		paramDict[\velocityReset] = reset.clip(1, 64);
	}

	setGateReset { // will be deprecated
		arg reset;
		paramDict[\gateReset] = reset.clip(1, 64);
	}

	setArticulationReset {
		arg reset;
		paramDict[\articulationReset] = reset.clip(1, 64);
	}

	setOrnamentationReset {
		arg reset;
		paramDict[\ornamentationReset] = reset.clip(1, 64);
	}

	setTimingReset {
		arg reset;
		paramDict[\timingReset] = reset.clip(1, 64);
	}

	/*
	getNote { // is deprecated ??
		var note, pitch, vel, staccato, slide, timing;
		note = Dictionary.new;

		// todo implement dimensions & octave & timing

		pitch = this.translateTonality(mutatedPitchArray[ pitchRandom ][ pitchIndex ]);
		vel = mutatedVelocityArray[ velocityDensity ][ velocityIndex ];
		staccato = mutatedGateStaccatoArray[ gateStaccatoDensity ][ gateIndex ];
		slide = mutatedGateSlideArray[ gateSlideDensity ][ gateIndex ];
		timing = 0;

		note.put(\pitch, pitch);
		note.put(\vel, vel);
		note.put(\staccato, staccato);
		note.put(\slide, slide);
		note.put(\timing, timing);

		^note;
	}
	*/

	setPpqn {
		arg pulse;
		ppqnPulse = pulse.mod(ppqnResolution);
	}

	handlePulse {
		var trigger = false, note = nil;

		if(ppqnPulse.mod(ppqnResolution/4) == ((ppqnResolution/4).asFloat * timingArray[paramDict[\timingIndex]]).asInteger, {
			// a step triggers to calculate

			// calc trigger
			if(paramDict[\lockedVelocityPositionsArray][ paramDict[\velocityIndex] ].asBoolean, {
				if(lockedVelocityArray[ paramDict[\velocityIndex] ] > 0, {
					trigger = true;
				}, {
					trigger = false;
				});
			}, {
				trigger = mutatedVelocityArray[ paramDict[\velocityDensity] ][ paramDict[\velocityIndex] ].asBoolean; // original trigger
				trigger = trigger.and(
					mutatedVelocitySyncopationArray[ paramDict[\velocitySyncopation] ][ paramDict[\velocityIndex] ].asBoolean.not
				); // syncopation filter
				if(1.0.rand > paramDict[\velocityProbability], {
					trigger = false;
				}); // probability check
			});
			// if trigger play note
			if(trigger, {
				var pitch, vel, oct, accent, staccato, slide;

				if(paramDict[\lockedPitchPositionsArray][ paramDict[\pitchIndex] ].asBoolean, {
					pitch = lockedPitchArray[ paramDict[\pitchIndex] ];
				}, {
					pitch = this.translateTonality(
						mutatedPitchArray[ paramDict[\pitchRandom] ][ paramDict[\pitchIndex] ],
						mutatedPitchStepsArray[ paramDict[\pitchSteps] ][ paramDict[\pitchIndex] ],
						mutatedPitchConfirmingArray[ paramDict[\pitchConfirming] ][ paramDict[\pitchIndex] ]
					);
				});

				if(paramDict[\lockedVelocityPositionsArray][ paramDict[\velocityIndex] ].asBoolean, {
					vel = lockedVelocityArray[ paramDict[\velocityIndex] ];
				}, {
					vel = mutatedVelocityDynamicsArray[ paramDict[\velocityDynamics] ][ paramDict[\velocityIndex] ];
				});

				if(paramDict[\lockedOctavePositionsArray][ paramDict[\octaveIndex] ].asBoolean, {
					oct = lockedOctaveArray[ paramDict[\octaveIndex] ];
				}, {
					oct = 0;
					if(1.0.rand < paramDict[\octaveProbability], {
						oct = oct + mutatedOctaveArray[ paramDict[\octaveDensity] ][ paramDict[\octaveIndex] ];
					});
				});

				if(paramDict[\lockedArticulationPositionsArray][ paramDict[\articulationIndex] ].asBoolean, {
					staccato = lockedArticulationArray[0][ paramDict[\articulationIndex] ];
					slide = lockedArticulationArray[1][ paramDict[\articulationIndex] ];
					accent = lockedArticulationArray[2][ paramDict[\articulationIndex] ];
				}, {
					accent = mutatedArticulationAccentArray[ paramDict[\articulationAccentDensity] ][ paramDict[\articulationIndex] ];
					staccato = mutatedArticulationStaccatoArray[ paramDict[\articulationStaccatoDensity] ][ paramDict[\articulationIndex] ];
					slide = mutatedArticulationSlideArray[ paramDict[\articulationSlideDensity] ][ paramDict[\articulationIndex] ];
				});

				note = Dictionary.newFrom([
					\pitch, pitch + paramDict[\octaveOffset],
					\vel, vel * (1 + accent),
					\slide, slideFlag,
				]);
				note[\pitch] = note[\pitch] + (oct * 12);
				staccatoFlag = staccato;
				slideFlag = slide;
				lastNote = note[\pitch];
			});
		});

		if(note.isNil, {
			if(ppqnPulse.mod(ppqnResolution/4) == ( ((ppqnResolution/4).asFloat*timingArray * timingArray[paramDict[\timingIndex]] * 2 + 1)/3.0 ).asInteger, {
				// kill staccato note
				if(staccatoFlag.asBoolean, {
					note = Dictionary.newFrom([
						\pitch, lastNote,
						\vel, 0,
						\slide, 0,
					]);
				});
				staccatoFlag = 0;
			});
		});

		if(ppqnPulse.mod(ppqnResolution/4) == (ppqnResolution/4 - 1), {
			// tick indices
			this.tickIndices;
		});

		ppqnPulse = (ppqnPulse+1).mod(ppqnResolution);
		^note;
	}
}