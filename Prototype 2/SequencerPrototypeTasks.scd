r = Task({
	var delta, count = 0, pulses = [nil, nil, nil, nil], slides = [0, 0, 0, 0], qncount = 0,
	trigger_buffer = 0.1; // triggerbuffer is to counteract gate messages being ignored due to being send too close to eachother
	while {
		delta = 60/130/~ppqn;
		delta.notNil;
	} {
		// 4th note
		if(count == 0, {
			// kick
			Synth.new(\kik);
			if(qncount.mod(4) == 0, {
				// sequencable mutations
				p.do({
					|prot, index|
					var mutation;
					mutation = [~mutation1, ~mutation2, ~mutation3, ~mutation4].at(index);
					if(mutation[\pitch] > 0, {
						prot.mutatePitch(mutation[\pitch]);
					});
					if(mutation[\vel] > 0, {
						prot.mutateVelocity(mutation[\vel]);
					});
					if(mutation[\oct] > 0, {
						prot.mutateOctave(mutation[\oct]);
					});
					if(mutation[\art] > 0, {
						prot.mutateArticulation(mutation[\art]);
					});
					if(mutation[\orn] > 0, {
						prot.mutateOrnamentation(mutation[\orn]);
					});
				});
			});
			if(qncount == 0, {
				"pre count check".postln;
				p.do({
					|prot, index|
					var mutation;
					mutation = [~mutation1, ~mutation2, ~mutation3, ~mutation4].at(index);
					mutation.postln;
					if(mutation[\pitch] > 0, {
						prot.resetPitchMutation;
					});
					if(mutation[\vel] > 0, {
						prot.resetVelocityMutation;
					});
					if(mutation[\oct] > 0, {
						prot.resetOctaveMutation;
					});
					if(mutation[\art] > 0, {
						prot.resetArticulationMutation;
					});
					if(mutation[\orn] > 0, {
						prot.resetOrnamentationMutation;
					});
					prot.resetVelocityIndex;
				});
				"post count check".postln;
			});
			qncount = (qncount + 1).mod(16);
		});
		// pulse and sound updating
		p.do({
			|prot, index|

			// update pulse
			pulses[index] = prot.handlePulse;

			// update plotters
			if(count.mod(~ppqn/8) == 0, {
				{prot.updatePlotters}.defer;
			});

			// update voices
			if(pulses[index].isNil.not, {
				if(pulses[index][\vel] == 0, {
					// staccato check for synth 1 & 2
					if(index < 2, {
						if(index == 0, {
							~voice1.set(\decay, 0.3);
						}, {
							~voice2.set(\decay, 0.3);
						});
					});
				}, {
					// play note
					switch(index,
						0, {
							~voice1.set(
								\amp, pulses[index][\vel] * ~soundParams[\acid1_drive],
								\freq, pulses[index][\pitch].midicps/2,
								\decay, (2 + pulses[index][\vel]) * ~soundParams[\acid1_decay],
								\gate, 1,
								\cutoff, ~soundParams[\acid1_cutoff],
								\res, ~soundParams[\acid1_resonance],
								\glide, ~soundParams[\acid1_glide],
								\waveform, ~soundParams[\acid1_waveshape],
							);
							slides[index] = pulses[index][\slide];
						},
						1, {
							~voice2.set(
								\amp, pulses[index][\vel] * ~soundParams[\acid2_drive],
								\freq, pulses[index][\pitch].midicps/2,
								\decay, (2 + pulses[index][\vel]) * ~soundParams[\acid2_decay],
								\gate, 1,
								\cutoff, ~soundParams[\acid2_cutoff],
								\res, ~soundParams[\acid2_resonance],
								\glide, ~soundParams[\acid2_glide],
								\waveform, ~soundParams[\acid2_waveshape],
							);
							slides[index] = pulses[index][\slide];
						},
						2, {
							~voice3 = Synth.new(\foldy,
								[
									\amp, pulses[index][\vel] * ~soundParams[\foldy1_drive],
									\freq, pulses[index][\pitch].midicps,
									\fmIndex1, ~soundParams[\foldy1_index1],
									\fmIndex2, ~soundParams[\foldy1_index2],
									\fmRatio1, ~soundParams[\foldy1_ratio1],
									\fmRatio2, ~soundParams[\foldy1_ratio2],
									\waveFolds, ~soundParams[\foldy1_folding],
									\decay, pulses[index][\vel] * ~soundParams[\foldy1_decay],
									\gate, 1
								]
							);
							slides[index] = pulses[index][\slide];
						},
						3, {
							~voice4 = Synth.new(\foldy,
								[
									\amp, pulses[index][\vel] * ~soundParams[\foldy2_drive],
									\freq, pulses[index][\pitch].midicps,
									\fmIndex1, ~soundParams[\foldy2_index1],
									\fmIndex2, ~soundParams[\foldy2_index2],
									\fmRatio1, ~soundParams[\foldy2_ratio1],
									\fmRatio2, ~soundParams[\foldy2_ratio2],
									\waveFolds, ~soundParams[\foldy2_folding],
									\decay, pulses[index][\vel] * ~soundParams[\foldy2_decay],
									\gate, 1
								]
							);
							slides[index] = pulses[index][\slide];
						},
					);
				});
			});
		});
		// pulse and slide updating
		if(count.mod(~ppqn/4) == ((~ppqn/4 - 1) * (1 - trigger_buffer)).asInteger, {
			slides.do({
				|slide, index|
				if(slide.asBoolean.not, {
					switch(index,
						0, { ~voice1.set(\gate, 0); },
						1, { ~voice2.set(\gate, 0); },
						2, {
							if(~voice3.isNil.not, {
								~voice3.set(\gate, 0);
								~voice3 = nil;
							});
						},
						3, {
							if(~voice4.isNil.not, {
								~voice4.set(\gate, 0);
								~voice4 = nil;
							});
						},
					);
				});
			});
			slides = [0, 0, 0, 0];
		});
		delta.yield;
		count = (count + 1).mod(~ppqn);
	}
});
		