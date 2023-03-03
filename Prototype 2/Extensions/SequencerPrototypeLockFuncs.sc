+ SequencerPrototype {

	// functions generating step locking information

	euclidean {
		arg steps, pulses, rotation;
		var euclidean_pos, euclidean_trigs;
		if(pulses > 0, {
			euclidean_pos = (0..(pulses-1))/pulses*steps;
			euclidean_pos.asInteger;
			euclidean_trigs = 0!steps;
			euclidean_pos.do({
				|pos, index|
				euclidean_trigs[pos] = 1;
			});
		}, {
			euclidean_trigs = 0!steps;
		});
		^euclidean_trigs.rotate(rotation);
	}

	updatePitchLocks {
		paramDict[\lockedPitchPositionsArray] = this.euclidean(
			paramDict[\pitchReset].postln,
			(paramDict[\pitchLockPulses]*paramDict[\pitchReset]).asInteger.postln,
			(paramDict[\pitchLockRotation]*paramDict[\pitchReset]).asInteger.postln
		);
		lockedPitchArray = 0!64;
		64.do({
			|index|
			lockedPitchArray[index] = this.translateTonality(
				mutatedPitchArray[ paramDict[\pitchRandom] ][ index ],
				mutatedPitchStepsArray[ paramDict[\pitchSteps] ][ index ],
				mutatedPitchConfirmingArray[ paramDict[\pitchConfirming] ][ index ]
			);
		});
	}

	updateVelocityLocks {
		paramDict[\lockedVelocityPositionsArray] = this.euclidean(
			paramDict[\velocityReset],
			(paramDict[\velocityLockPulses]*paramDict[\velocityReset]).asInteger,
			(paramDict[\velocityLockRotation]*paramDict[\velocityReset]).asInteger
		);
		lockedVelocityArray = 0!64;
		64.do({
			|index|
			lockedVelocityArray[index] = mutatedVelocityDynamicsArray[ paramDict[\velocityDynamics] ][ index ] *
			mutatedVelocityArray[ paramDict[\velocityDensity] ][ index ] *
			(1-mutatedVelocitySyncopationArray[ paramDict[\velocitySyncopation] ][ index ]);
		});
		paramDict[\lockedVelocityPositionsArray].postln;
		lockedVelocityArray.postln;
	}

	updateOctaveLocks {
		paramDict[\lockedOctavePositionsArray] = this.euclidean(
			paramDict[\octaveReset],
			(paramDict[\octaveLockPulses]*paramDict[\octaveReset]).asInteger,
			(paramDict[\octaveLockRotation]*paramDict[\octaveReset]).asInteger
		);
		lockedOctaveArray = 0!64;
		64.do({
			|index|
			lockedOctaveArray[index] = mutatedOctaveArray[ paramDict[\octaveDensity] ][ index ];
		});
	}

	updateArticulationLocks {
		paramDict[\lockedArticulationPositionsArray] = this.euclidean(
			paramDict[\articulationReset],
			(paramDict[\articulationLockPulses]*paramDict[\articulationReset]).asInteger,
			(paramDict[\articulationLockRotation]*paramDict[\articulationReset]).asInteger
		);
		lockedArticulationArray = 0!3!64;
		64.do({
			|index|
			lockedArticulationArray[index] = [
				mutatedArticulationStaccatoArray[ paramDict[\articulationStaccatoDensity] ][ index ],
				mutatedArticulationSlideArray[ paramDict[\articulationSlideDensity] ][ index ],
				mutatedArticulationAccentArray[ paramDict[\articulationAccentDensity] ][ index ]
			];
		});
	}

	updateOrnamentationLocks {
		paramDict[\lockedOrnamentationPositionsArray] = this.euclidean(
			paramDict[\ornamentationReset],
			(paramDict[\ornamentationLockPulses]*paramDict[\ornamentationReset]).asInteger,
			(paramDict[\ornamentationLockRotation]*paramDict[\ornamentationReset]).asInteger
		);
		lockedOrnamentationArray = 0!2!64;
		64.do({
			|index|
			lockedOrnamentationArray[index] = [
				mutatedOrnamentationGraceNoteArray[ paramDict[\ornamentationGraceNotes] ][ index ],
				mutatedOrnamentationFigureArray[ paramDict[\ornamentationFigures] ][ index ]
			];
		});
	}

	updateTimingLocks {
		paramDict[\lockedTimingPositionsArray] = this.euclidean(
			paramDict[\timingReset],
			(paramDict[\timingLockPulses]*paramDict[\timingReset]).asInteger,
			(paramDict[\timingLockRotation]*paramDict[\timingReset]).asInteger
		);
		lockedTimingArray = 0!16;
		16.do({
			|index|
			lockedTimingArray[index] = timingArray[index];
		});
	}
}