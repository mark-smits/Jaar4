HouseChords {

	// class variables
    //classvar
	// instance variables
	var
	// House Engine Chords vars
	scale,
	scales_16ths,
	chords,
	roots,
	simple_chords,
	rhythm,
	bars,
	simple_chords_16ths,
	chords_16ths,
	roots_16ths,
	note_list;

	// init funcs
	*initClass {
		// Initializations on class level (e.g. to set up classvars)
	}

	// House Engine Chords functions
	init {
		arg num_bars;
		scale = [0, 2, 3, 5, 7, 8, 10];
		bars = num_bars;

		this.calculate(num_bars);
	}

	calculate {
		arg num_bars;
		var inversion;

		roots = [0];
		3.do({
			|index|
			var new_note;
			new_note = 0;
			while( {roots.includes(new_note)}, {
				new_note = (-2..4).choose;
			});
			roots = roots ++ new_note;
		});
		roots = roots.scramble;

		roots.do({
			|root, index|
			var chord_shape;
			chord_shape = [0, 2, 4, 6];
			if(root == 1, {
				chord_shape = [0, 2, 3, 5];
			});
			if(root == -1, {
				chord_shape = [0, 2, 4, 5];
			});
			simple_chords = simple_chords ++ [ (scale ++ (scale+12) ++ (scale-12)).wrapAt(chord_shape+root) ];
		});
		//"simple chords:".postln;
		//simple_chords.dopostln;

		inversion = [0, 1, 2, 3].choose;
		roots.do({
			|root, index|
			var root2, chord;
			root2 = root; // preserve original root note for slash chords
			if(root == 1, {
				root = root + 3; // generate slash chord X/V
			});
			if(root == -1, {
				root = root + 5; // generate slash chord X/III¦
			});

			chord = ([0, 2, 4, 6] + root).mod(7);
			chord = scale.at(chord);

			chord = chord - [0, 3, 7, 10].at(inversion);
			chord = chord.mod(12);
			chord = chord + [0, 3, 7, 10].at(inversion);

			chord = chord + 12;
			root = scale.at(root2.mod(7));
			if([8, 10].includes(root), {
				root = root - 12;
			});
			chord = [root] ++ chord;
			chords = chords ++ [ chord.sort ];
		});
		roots = scale.at(roots.mod(7));
		roots.do({
			|root, index|
			if(root > 7, {
				roots[index] = root - 12;
			});
		});
		//"roots:".postln;
		//roots.postln;
		//"chords:".postln;
		//chords.dopostln;

		this.make_lists(num_bars);
	}

	make_lists {
		arg num_bars; // expects 2 or 4
		var rhythms2, rhythms4, expanded_scale;

		expanded_scale = (scale-12) ++ scale ++ (scale+12);

		rhythms4 = [
			(0!16) ++ (1!16),
			(0!10) ++ (1!22),
			(0!26) ++ (1!6),
			(0!20) ++ (1!12),
		];

		rhythms2 = [
			(0!10) ++ (1!6),
			(0!8) ++ (1!8),
			(0!12) ++ (1!4),
			(0!14) ++ (1!2)
		];

		if(num_bars == 4, {
			rhythm = rhythms4.choose ++ (rhythms4.choose + 2);
		}, {
			rhythm = rhythms2.wchoose([0.45, 0.3, 0.2, 0.05]) ++ (rhythms2.wchoose([0.45, 0.3, 0.2, 0.05]) + 2);
		});
		if(1.0.rand > 0.5, {
			// generate 3 chords
			var len1, len2;
			if(roots.at([0, 1]).includes(0), {
				//"roots in first".postln;
				rhythm = (roots.indexOf(0)!(num_bars*8)) ++ rhythm.at( ((num_bars*8)..(num_bars*16-1)) );
				len1 = rhythm.indexOf(3) - rhythm.indexOf(2);
				len2 = num_bars*16 - rhythm.indexOf(3);
				note_list = [[chords[roots.indexOf(0)], num_bars*8]] ++ (0!(num_bars*8-1)) ++
				[[chords[2], len1]] ++ (0!(len1-1)) ++
				[[chords[3], len2]] ++ (0!(len2-1));
			}, {
				//"roots in last".postln;
				rhythm = rhythm.at( (0..(num_bars*8-1)) ) ++ (roots.indexOf(0)!(num_bars*8));
				len1 = rhythm.indexOf(1);
				len2 = num_bars*8 - rhythm.indexOf(1);
				note_list = [[chords[0], len1]] ++ (0!(len1-1)) ++
				[[chords[1], len2]] ++ (0!(len2-1)) ++
				[[chords[roots.indexOf(0)], num_bars*8]] ++ (0!(num_bars*8-1));
			});
			//rhythm.postln;
		}, {
			// generate 4 chords
			var len1, len2, len3, len4;
			len1 = rhythm.indexOf(1);
			len2 = num_bars*8 - rhythm.indexOf(1);
			len3 = rhythm.indexOf(3) - rhythm.indexOf(2);
			len4 = num_bars*16 - rhythm.indexOf(3);
			note_list = [[chords[0], len1]] ++ (0!(len1-1)) ++
			[[chords[1], len2]] ++ (0!(len2-1)) ++
			[[chords[2], len3]] ++ (0!(len3-1)) ++
			[[chords[3], len4]] ++ (0!(len4-1));
		});

		//"simple chords 16ths:".postln;
		simple_chords_16ths = simple_chords.at(rhythm);//.postln;
		//"chords 16ths:".postln;
		chords_16ths = chords.at(rhythm);//.postln;
		//"roots 16ths:".postln;
		roots_16ths = roots.at(rhythm);//.postln;

		scales_16ths = [];
		roots_16ths.do({
			|root, index|
			scales_16ths = scales_16ths ++ [expanded_scale.at( [0, 1, 2, 3, 4, 5, 6] + expanded_scale.indexOf(root) )];
		});
	}

	get_note {
		arg step_nr;
		^note_list.wrapAt(step_nr);
	}

	get_root {
		arg step_nr;
		^roots_16ths.wrapAt(step_nr);
	}

	get_simple_chord {
		arg step_nr;
		^simple_chords_16ths.wrapAt(step_nr);
	}

	get_chord {
		arg step_nr;
		^chords_16ths.wrapAt(step_nr);
	}

	get_scales {
		^scales_16ths;
	}

    test {
		simple_chords_16ths.postln;
		roots_16ths.postln;
		chords_16ths.postln;
		note_list.postln;
    }
}