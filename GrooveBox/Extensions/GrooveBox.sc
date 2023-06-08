GrooveBox {

	/*
	todos:
	- function to get UI element for the internal state of each of the sequences
	*/

	// class variables
    //classvar
	// instance variables
	var
	// GrooveBox vars
	// musical params
	global_root,
	global_scale,
	roots,
	scales,
	// pattern classes
	chords,
	sting64s,
	acdgens,
	srm_bl001s,
	// pattern lists
	arp_pattern,
	chord_patterns,
	bass_melody_patterns,
	// pattern dictionary
	engine_lists_dict,
	// octave offsets
	octave_offsets, // -2, -1, 0, 1, 2
	// patterns parameters
	mutation_chances, // 0.0-1.0
	pattern_type_indices,
	// indexing
	pattern_indices,
	pattern_lengths,
	pattern_syncing,
	pattern_syncing_length_bars,
	uses_global_scale, // to use the global scale instead of harmonically applicable scales
	global_index = 0;

	// init funcs
	*initClass {
		// Initializations on class level (e.g. to set up classvars)
	}

	// GrooveBox functions
	init {
		arg engine_dict_args;

		sting64s = Sting64.new!6;
		acdgens = ACDGEN.new!6;
		srm_bl001s = SRM_BL001.new!6;
		chords = HouseChords.new;
		engine_lists_dict = Dictionary.newFrom(engine_dict_args);

		chords.init(4);
		sting64s.do({
			|seq, index|
			seq.init;
		});
		acdgens.do({
			|seq, index|
			seq.init;
		});
		srm_bl001s.do({
			|seq, index|
			seq.init;
		});

		arp_pattern = [];
		chord_patterns = []!2;
		bass_melody_patterns = []!3;
		pattern_type_indices = 0!6;

		octave_offsets = 0!6;
		mutation_chances = 0.0!6;
		pattern_type_indices = 0!6;
		pattern_indices = 0!6;
		pattern_lengths = 16!6;
		pattern_syncing = false!6;
		uses_global_scale = false!6;
		pattern_syncing_length_bars = 4!6;

		scales = chords.get_scales;
		global_scale = [0, 2, 3, 5, 7, 8, 10];
		global_root = 0;
		roots = [];
		scales.do({
			|scale, index|
			roots = roots ++ scale[0];
		});

		6.do({
			|index|
			this.regen_pattern(index, engine_dict_args[0]);
		});
	}

	regen_chords {
		chords.calculate(4);
		scales = chords.get_scales;
		//global_scale = [0, 2, 3, 5, 7, 8, 10];
		global_root = (global_root + [5, 7, 2, 10].wchoose([0.4, 0.4, 0.1, 0.1])).mod(12);
		if(global_root > 6, {
			global_root = global_root - 12;
		});
		roots = [];
		scales.do({
			|scale, index|
			roots = roots ++ scale[0];
		});
	}

	tick {
		global_index = (global_index + 1).mod(128); // 8 bar
		pattern_indices.do({
			|pat_index, index|
			pattern_indices[index] = (pat_index + 1).mod(pattern_lengths[index]);
			if(pattern_syncing[index], {
				if( (global_index).mod(16*pattern_syncing_length_bars[index]) == 0, {
					pattern_indices[index] = 0;
				});
			});
		});
	}

	set_acdgen_key {
		arg index, key, value;
		acdgens[index].set_key(key, value);
	}

	set_srm_key {
		arg index, key, value;
		srm_bl001s[index].set_key(key, value);
	}

	set_sting64_pitch_density {
		arg index, value;
		sting64s[index].set_pitch_density(value);
	}

	set_sting64_performable_density {
		arg index, value;
		sting64s[index].set_performable_density(value);
	}

	set_uses_global_scale {
		arg index, value;
		uses_global_scale[index] = value;
	}

	set_pattern_type {
		arg pattern_nr, pattern_type_index;
		pattern_type_indices[pattern_nr] = pattern_type_index;
	}

	set_new_arp_pattern {
		arg dict_key;
		arp_pattern = Array.newFrom(engine_lists_dict[dict_key].choose);
	}

	set_new_chord_pattern {
		arg index, dict_key;
		chord_patterns[index] = Array.newFrom(engine_lists_dict[dict_key].choose);
	}

	set_new_bass_melody_pattern {
		arg index, dict_key;
		bass_melody_patterns[index] = Array.newFrom(engine_lists_dict[dict_key].choose);
	}

	set_mutation_chance {
		arg index, mutation;
		mutation_chances[index] = mutation;
	}

	set_octave_offset {
		arg index, offset;
		octave_offsets[index] = offset;
	}

	set_pattern_length {
		arg pattern_index, length;
		pattern_lengths[pattern_index] = length;
	}

	get_pattern_length {
		arg pattern_index;
		^pattern_lengths[pattern_index];
	}

	set_pattern_syncing {
		arg pattern_index, sync_bool;
		pattern_syncing[pattern_index] = sync_bool;
	}

	set_pattern_syncing_lengths_bars {
		arg pattern_index, sync_length;
		pattern_syncing_length_bars[pattern_index] = sync_length;
	}

	regen_pattern {
		arg pattern_index, dict_key;
		switch(pattern_index,
			0, {
				this.set_new_chord_pattern(0, dict_key);
				acdgens[0].calculate;
				srm_bl001s[0].calculate( (0..6) );
				sting64s[0].calculate;
			},
			1, {
				this.set_new_chord_pattern(1, dict_key);
				acdgens[1].calculate;
				srm_bl001s[1].calculate( (0..6) );
				sting64s[1].calculate;
			},
			2, {
				this.set_new_arp_pattern(dict_key);
				acdgens[2].calculate;
				srm_bl001s[2].calculate( (0..6) );
				sting64s[2].calculate;
			},
			3, {
				this.set_new_bass_melody_pattern(0, dict_key);
				acdgens[3].calculate;
				srm_bl001s[3].calculate( (0..6) );
				sting64s[3].calculate;
			},
			4, {
				this.set_new_bass_melody_pattern(1, dict_key);
				acdgens[4].calculate;
				srm_bl001s[4].calculate( (0..6) );
				sting64s[4].calculate;
			},
			5, {
				this.set_new_bass_melody_pattern(2, dict_key);
				acdgens[5].calculate;
				srm_bl001s[5].calculate( (0..6) );
				sting64s[5].calculate;
			},
		);
	}

	get_index {
		arg pattern_nr;
		^pattern_indices[pattern_nr];
	}

	get_global_index {
		^global_index;
	}

	get_note_no_mutation {
		arg pattern_nr, index_overwrite = nil;
		var mut1, mut2, mut3, mut4, mut5, mut6, note;
		mut1 = mutation_chances[0];
		mut2 = mutation_chances[1];
		mut3 = mutation_chances[2];
		mut4 = mutation_chances[3];
		mut5 = mutation_chances[4];
		mut6 = mutation_chances[5];
		mutation_chances = [0, 0, 0, 0, 0, 0];
		note = this.get_note(pattern_nr, index_overwrite);
		mutation_chances = [mut1, mut2, mut3, mut4, mut5, mut6];
		^note;
	}

	get_note {
		// todo: translate note functions to get usable notes out of this function
		arg pattern_nr, index_overwrite = nil; // if index is overwritten, the user can get a specific note from the list
		var note, pattern_index, glob_index, scale;

		pattern_index = pattern_indices[pattern_nr];

		if(index_overwrite.isNil.not, {
			pattern_index = index_overwrite;
		});

		if(index_overwrite.isNil.not, {
			glob_index = index_overwrite;
		}, {
			glob_index = global_index;
		});

		if(uses_global_scale[pattern_nr], {
			scale = global_scale;
		}, {
			scale = scales[ glob_index.mod(scales.size) ];
		});

		/*
		per pattern number:
		1. legato chords, acdgen, srm_bl001 or sting64
		2. rhythmic chords, acdgen, srm_bl001 or sting64
		3. arp, acdgen, srm_bl001 or sting64
		4-6. mel/bass pattern, acdgen, srm_bl001 or sting64

		note formatted as [note_nr, vel, dur] from [note_nr, vel, oct, dur]
		*/

		if(mutation_chances[pattern_nr] > 1.0.rand, {
			acdgens[pattern_nr].mutate_note(pattern_index);
			sting64s[pattern_nr].mutate_note(pattern_index);
		});

		switch(pattern_nr, // retrieving a note form a pattern
			0, {
				switch(pattern_type_indices[0],
					0, {note = chord_patterns[0][pattern_index]},
					1, {note = acdgens[0].get_note(pattern_index)},
					2, {note = srm_bl001s[0].get_note(pattern_index)},
					3, {note = sting64s[0].get_note(pattern_index)},
				)
			},
			1, {
				switch(pattern_type_indices[1],
					0, {note = chord_patterns[1][pattern_index]},
					1, {note = acdgens[1].get_note(pattern_index)},
					2, {note = srm_bl001s[1].get_note(pattern_index)},
					3, {note = sting64s[1].get_note(pattern_index)},
				)
			},
			2, {
				switch(pattern_type_indices[2],
					0, {note = arp_pattern[pattern_index]},
					1, {note = acdgens[2].get_note(pattern_index)},
					2, {note = srm_bl001s[2].get_note(pattern_index)},
					3, {note = sting64s[2].get_note(pattern_index)},
				)
			},
			3, {
				switch(pattern_type_indices[3],
					0, {note = bass_melody_patterns[0][pattern_index]},
					1, {note = acdgens[3].get_note(pattern_index)},
					2, {note = srm_bl001s[3].get_note(pattern_index)},
					3, {note = sting64s[3].get_note(pattern_index)},
				)
			},
			4, {
				switch(pattern_type_indices[4],
					0, {note = bass_melody_patterns[1][pattern_index]},
					1, {note = acdgens[4].get_note(pattern_index)},
					2, {note = srm_bl001s[4].get_note(pattern_index)},
					3, {note = sting64s[4].get_note(pattern_index)},
				)
			},
			5, {
				switch(pattern_type_indices[5],
					0, {note = bass_melody_patterns[2][pattern_index]},
					1, {note = acdgens[5].get_note(pattern_index)},
					2, {note = srm_bl001s[5].get_note(pattern_index)},
					3, {note = sting64s[5].get_note(pattern_index)},
				)
			},
		);

		if(pattern_type_indices[pattern_nr] > 0, {
			if(pattern_type_indices[pattern_nr] == 3, { // sting note formatting
				note = [
					[ note[0] + ( (note[2] + octave_offsets[pattern_nr]) * 12) ],
					[ note[1] ],
					[ note[3] ],
				];
			}, { // acd_gen & srm_bl001 note formatting
				note = [
					[ scale[ note[0].mod(7) ] + global_root
						+ ( (note[2] + (note[0]/7).floor + octave_offsets[pattern_nr]) * 12 ) + 48 ],
					[ note[1] ],
					[ note[3] ],
				];
			});
		}, { // house engine note formatting
			var n0, n1, n2, n3;
			n0 = Array.newFrom(note[0]);
			n1 = Array.newFrom(note[1]);
			n2 = Array.newFrom(note[2]);
			n3 = Array.newFrom(note[3]);
			if(n0.isNil.not, {
				n0.do({
					|pitch, index|
					n0[index] = scale[ pitch ] + global_root
					+ ( (n2[index] + octave_offsets[pattern_nr] * 12) );
				});
			});
			note = [
				n0,
				n1,
				n3,
			];
		});

		^note;
	}

	test {
		chords.test;
		sting64s.do({
			|seq, index|
			seq.test;
		});
		acdgens.do({
			|seq, index|
			seq.test;
		});
		srm_bl001s.do({
			|seq, index|
			seq.test;
		});
		engine_lists_dict.dopostln;
	}

	test_chords {
		chords.test;
	}
}