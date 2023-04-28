ACDGEN {

	// class variables
    //classvar
	// instance variables
	var
	// ACDGEN vars
	ag_genParams,
	ag_patternDict;

	// init funcs
	*initClass {
		// Initializations on class level (e.g. to set up classvars)
	}

	// ACDGEN functions
	init {
		ag_genParams = Dictionary.newFrom([
			\seqMode, "Normal",
			\scale, [0, 1, 2, 3, 4, 5, 6, 7],
			\notePool, [],
			\slideBias, 1.0, //0.5 - 1.5
			\octaveBias, 0, // 0 - 100
			\octaveBalance, 0.6, // 0.0 > 1.0
			\tripletAccent, 0.6, // 0.0 - 0.9
			\algorithmBias, 0.0, // -1.0 - 1.0
			\variationChance, 0.3, // 0.0 - 1.0
			\baseVelocity, 60, // 0 - 127
			\holdProbability, 0.2, // 0.0 - 1.0
			\randomVelocity, 0, //0 -127
			\holdUntil, 0,
			\holdArray, [],
			\variation, 0, // 0-2
			\density, 100, // 0-100
		]);

		this.calculate;
	}

	set_key {
		arg key, value;
		ag_genParams[key] = value;
	}

	calculate {
		var note_list;
		ag_patternDict = 0!5!(64*3); // init the patternDict
		ag_genParams[\holdArray] = 0!(64*3);
		ag_genParams[\holdUntil] = -1;
		if(ag_genParams[\seqMode] == "FifthOct", {
			ag_genParams[\notePool] = [0, 4];
		}, {
			ag_genParams[\notePool] = Array.newFrom(ag_genParams[\scale]).scramble.at((0..3)).sort;
		});
		64.do({
			|index|
			note_list = this.calculateSingleNote(index);
			ag_patternDict[index] = note_list;
			if(1.0.rand < ag_genParams[\variationChance], {
				ag_patternDict[index+64] = this.calculateSingleNote(index);
			}, {
				ag_patternDict[index+64] = note_list;
			});
			if(1.0.rand < ag_genParams[\variationChance], {
				ag_patternDict[index+128] = this.calculateSingleNote(index);
			}, {
				ag_patternDict[index+128] = note_list;
			});
		});
	}

	calculateSingleNote {
		arg step;
		var note, vel, oct, slide, density, list, prob_vals = [30, 60, 10, 80], scaled_step, hold_amount = 2.0.rand.round + 1;

		// density
		if(step % 4 == 0, {
			density = 30 + 69.rand;
		}, {
			density = 99.rand;
		});

		// slide
		scaled_step = step.linlin(0, 64, 20*ag_genParams[\slideBias], 40*ag_genParams[\slideBias])*0.01;
		if(
			(1.0.rand < ag_genParams[\holdProbability])
			.and(ag_patternDict[step][1] > 0)
			.and(hold_amount < (64-step)), {
				ag_genParams[\holdArray][step + hold_amount] = 1;
				ag_genParams[\holdUntil] = step + hold_amount;
				slide = 1.0+hold_amount;
			}, {
				if(
					(1.0.rand < scaled_step)
					.and(ag_patternDict[ (step-1).clip(0, 63) ][3] < 1.1), {
						slide = 1.6;
					}, {
						slide = 1.0;
				});
		});

		// oct
		switch(ag_genParams[\seqMode],
			"Normal", {
				scaled_step = step.linlin(0, 64, 1, 30 + ag_genParams[\octaveBias])*0.01;
			},
			"Floor", {
				scaled_step = step.linlin(0, 64, 2, 20 + ag_genParams[\octaveBias])*0.01;
			},
			"FifthOct", {
				scaled_step = step.linlin(0, 64, 1, 30 + ag_genParams[\octaveBias])*0.01;
			},
			"Upwards", {
				scaled_step = step.linlin(0, 64, 2, 10 + ag_genParams[\octaveBias])*0.01;
			},
			"Downwards", {
				scaled_step = step.linlin(0, 64, 2, 10 + ag_genParams[\octaveBias])*0.01;
			},
			"Up-Stepped", {
				scaled_step = 0;
			},
			"Down-Stepped", {
				scaled_step = 0;
			},
			"Arp3", {
				scaled_step = 0;
			},
		);
		if(1.0.rand < scaled_step, {
			if(1.0.rand < ag_genParams[\octaveBias], {
				oct = 1;
			}, {
				oct = 2;
			});
		}, {
			oct = 0;
		});

		// vel
		if(ag_genParams[\holdArray][step] == 0, {
			var chance;
			if(ag_genParams[\seqMode] == "Arp3", {
				prob_vals = [40, 95, 10, 80];
			});
			chance = 1.0.rand;
			if((step % 3) == 0, {
				if(chance < ag_genParams[\tripletAccent], {
					vel = 127;
				}, {
					if(chance < 0.95, {
						vel = ((ag_genParams[\randomVelocity] * 2.0.rand).round - ag_genParams[\randomVelocity] + ag_genParams[\baseVelocity]).clip(0, 127);
					}, {
						vel = 0;
					});
				});
			}, {
				var scaled_step1, scaled_step2;
				scaled_step1 = step.linlin(0, 64, prob_vals[0], prob_vals[1]) * 0.01;
				scaled_step2 = (step.linlin(0, 64, prob_vals[2], prob_vals[3]) * 0.01).pow(1.2);
				if(chance < scaled_step1, {
					if(chance < scaled_step2, {
						vel = 127;
					}, {
						vel = ((ag_genParams[\randomVelocity] * 2.0.rand).round - ag_genParams[\randomVelocity] + ag_genParams[\baseVelocity]).clip(0, 127);
					});
				}, {
					if(chance < scaled_step2, {
						vel = ((ag_genParams[\randomVelocity] * 2.0.rand).round - ag_genParams[\randomVelocity] + ag_genParams[\baseVelocity]).clip(0, 127);
					}, {
						vel = 0;
					});
				});
			});
		}, {
			vel = 0;
		});

		// note
		switch(ag_genParams[\seqMode],
			"Normal", {
				note = ag_genParams[\scale].choose;
			},
			"Floor", {
				if(1.0.rand < ((ag_genParams[\algorithmBias] * 0.3) + 0.6), {
					note = ag_genParams[\notePool][0]
				}, {
					note = ag_genParams[\notePool].choose;
				});
			},
			"FifthOct", {
				if((step % 3) == 0, {
					if(1.0.rand < ((ag_genParams[\algorithmBias] * 0.3) + 0.7), {
						note = 0;
					}, {
						note = 4;
					});
				}, {
					note = ag_genParams[\notePool].choose;
				});
			},
			"Upwards", {
				var chance;
				chance = 1.0.rand;
				if(chance < ((ag_genParams[\algorithmBias] * 0.2) + 0.6), {
					if((step % 8) < 7, {
						note = ag_genParams[\scale][step % 8];
					}, {
						note = ag_genParams[\scale][7];
					});
				}, {
					if(chance < 0.9, {
						note = ag_genParams[\scale][ (step % 8 - 1).clip(0, 7) ];
					}, {
						note = 0;
					});
				});
			},
			"Downwards", {
				var chance;
				chance = 1.0.rand;
				if(chance < ((ag_genParams[\algorithmBias] * 0.2) + 0.6), {
					if((7 - (step % 8)) < 7, {
						note = ag_genParams[\scale][7 - (step % 8)];
					}, {
						note = ag_genParams[\scale][7];
					});
				}, {
					if(chance < 0.9, {
						note = ag_genParams[\scale][ (7 - (step % 8) - 1).clip(0, 7) ];
					}, {
						note = 0;
					});
				});
			},
			"Up-Stepped", {
				var chance;
				chance = 1.0.rand;
				if((step % 2) == 1, {
					if(chance < ((ag_genParams[\algorithmBias] * 0.2) + 0.3), {
						note = ag_genParams[\scale][ ((step%16+1/2).round-1).clip(0, 7) ];
					}, {
						note = 0;
					});
				}, {
					if(chance < 0.4, {
						if(step%16<15, {
							note = ag_genParams[\scale][ ((step%16+1/2).round-1).clip(0, 7) ];
						}, {
							note = ag_genParams[\scale][7];
						});
					}, {
						if(chance < ((ag_genParams[\algorithmBias] * 0.2) + 0.8), {
							note = ag_genParams[\scale][ ((step%16+1/2).round-2).clip(0, 7) ];
						}, {
							note = 0;
						});
					});
				});
			},
			"Down-Stepped", {
				var chance;
				chance = 1.0.rand;
				if((step % 2) == 0, {
					if(chance < ((ag_genParams[\algorithmBias] * 0.2) + 0.3), {
						note = ag_genParams[\scale][ ((15-(step%16)+1/2).round-1).clip(0, 7) ];
					}, {
						note = 0;
					});
				}, {
					if(chance < 0.4, {
						if(step%16<15, {
							note = ag_genParams[\scale][ ((15-(step%16)+1/2).round-1).clip(0, 7) ];
						}, {
							note = ag_genParams[\scale][7];
						});
					}, {
						if(chance < ((ag_genParams[\algorithmBias] * 0.2) + 0.8), {
							note = ag_genParams[\scale][ ((15-(step%16)+1/2).round-2).clip(0, 7) ];
						}, {
							note = 0;
						});
					});
				});
			},
			"Arp3", {
				note = ag_genParams[\notePool][step%3]
			},
		);

		list = [note, vel, oct, slide, density];

		^list;
	}

	mutate_note {
		arg step_nr;
		var note_list;
		note_list = this.calculateSingleNote(step_nr);
		ag_patternDict[step_nr] = note_list;
		if(1.0.rand < ag_genParams[\variationChance], {
			ag_patternDict[step_nr+64] = this.calculateSingleNote(step_nr);
		}, {
			ag_patternDict[step_nr+64] = note_list;
		});
		if(1.0.rand < ag_genParams[\variationChance], {
			ag_patternDict[step_nr+128] = this.calculateSingleNote(step_nr);
		}, {
			ag_patternDict[step_nr+128] = note_list;
		});
	}

	get_note {
		arg step_nr;
		var note;
		//"note, vel, oct, slide, dens".postln;
		step_nr = step_nr.mod(64) + (ag_genParams[\variation]*64);
		note = ag_patternDict[step_nr];//.postln;
		if(note[4] > ag_genParams[\density], {
			note = [0, 0, 0, 0];
		}, {
			note = note.at( (0..3) );
		});
		^note;
	}

    test {
		ag_genParams.dopostln;
		ag_patternDict.dopostln;
    }
}