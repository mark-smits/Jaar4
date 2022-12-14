+ SequencerPrototype {

	// functions for sequencing

	tickIndices {
		pitchIndex = (pitchIndex + 1).mod(pitchReset);
		octaveIndex = (octaveIndex + 1).mod(octaveReset);
		velocityIndex = (velocityIndex + 1).mod(velocityReset);
		gateIndex = (gateIndex + 1).mod(gateReset); // will be deprecated
		articulationIndex = (articulationIndex + 1).mod(articulationReset);
		ornamentationIndex = (ornamentationIndex + 1).mod(ornamentationReset);
		timingIndex = (timingIndex + 1).mod(timingReset);
	}

	resetVelocityIndex {
		// also seperately available if necessary due to syncopation
		velocityIndex = 0;
	}

	resetIndices {
		pitchIndex = 0;
		octaveIndex = 0;
		velocityIndex = 0;
		gateIndex = 0; // will be deorecated
		articulationIndex = 0;
		ornamentationIndex = 0;
		timingIndex = 0;
	}

	setPitchReset {
		arg reset;
		pitchReset = reset.clip(1, 64);
	}

	setOctaveReset {
		arg reset;
		octaveReset = reset.clip(1, 64);
	}

	setVelocityReset {
		arg reset;
		velocityReset = reset.clip(1, 64);
	}

	setGateReset { // will be deprecated
		arg reset;
		gateReset = reset.clip(1, 64);
	}

	setArticulationReset {
		arg reset;
		articulationReset = reset.clip(1, 64);
	}

	setOrnamentationReset {
		arg reset;
		ornamentationReset = reset.clip(1, 64);
	}

	setTimingReset {
		arg reset;
		timingReset = reset.clip(1, 64);
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

		if(ppqnPulse.mod(ppqnResolution/4) == ((ppqnResolution/4).asFloat * timingArray[timingIndex]).asInteger, {
			((ppqnResolution/4).asFloat * timingArray[timingIndex]).asInteger;
			// calc trigger
			trigger = mutatedVelocityArray[ velocityDensity ][ velocityIndex ].asBoolean; // original trigger
			trigger = trigger.and(
				mutatedVelocitySyncopationArray[ velocitySyncopation ][ velocityIndex ].asBoolean.not
			); // syncopation filter
			if(1.0.rand > velocityProbability, {
				trigger = false;
			}); // probability check
			// if trigger play note
			if(trigger, {
				note = Dictionary.newFrom([
					\pitch, this.translateTonality(
						mutatedPitchArray[ pitchRandom ][ pitchIndex ],
						mutatedPitchStepsArray[ pitchSteps ][ pitchIndex ],
						mutatedPitchConfirmingArray[ pitchConfirming ][ pitchIndex ]
					),
					\vel, mutatedVelocityDynamicsArray[ velocityDynamics ][ velocityIndex ] * (1 + mutatedArticulationAccentArray[ articulationAccentDensity ][ articulationIndex ]),
					\slide, slideFlag,
				]);
				if(1.0.rand < octaveProbability, {
					note[\pitch] = note[\pitch] + (mutatedOctaveArray[ octaveDensity ][ octaveIndex ] * 12);
				});
				staccatoFlag = mutatedArticulationStaccatoArray[ articulationStaccatoDensity ][ articulationIndex ];
				slideFlag = mutatedArticulationSlideArray[ articulationSlideDensity ][ articulationIndex ];
				lastNote = note[\pitch];
			});
		});

		if(note.isNil, {
			if(ppqnPulse.mod(ppqnResolution/4) == ( ((ppqnResolution/4).asFloat*timingArray * timingArray[timingIndex] * 2 + 1)/3.0 ).asInteger, {
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