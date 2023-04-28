SRM_BL001 {

	// class variables
    //classvar
	// instance variables
	var
	// SRM BL001 vars
	srm_genParams,
	srm_patternDict;

	// init funcs
	*initClass {
		// Initializations on class level (e.g. to set up classvars)
	}

	// SRM_BL001 functions
	init {
		srm_genParams = Dictionary.newFrom([
			\accent_patterns, [
				"X.......X.......X.......X.......",
				"....X.......X.......X.......X...",
				"X...X...X...X...X...X...X...X...",
				"..X...X...X...X...X...X...X...X.",
				"..............XX..............XX",
				"X..............XX..............X",
				".X.X............X.X.............",
				"X.X............X.X..............",
				"............X.X..............X.X",
				"X.X.",
				".X.X",
				"XX.XXX.X",
				"XX.X.X.X",
				"X..X..X.",
				"XXXXXXXX"],
			\patterns, [
				"..X...X.X.XX...X...X..X.X.XX....",
				"X.X...X.X..X.XX.X.X...X.X.......",
				"X.X.X.X.X.XX....X.X.X.XXX.XX....",
				"X.X.X.X.X..X....X.X.X.X.X..X...X",
				"X.X.X.X.X..X....X.X.X.X.X..X...X",
				"X..XX.X.X.X.X...X..XX.X.X.....XX",
				"..X..X..X.X...X...X..X..X.X...XX",
				"X..X..X...X.X...X..X..X...X.X..X",
				"...X..X............X..X...........XX..X............X..X.X.X.....",
				"X.X.X.X.X..X..X.X.X.X.X.X..X.XX.",
				"X..X..X.........X..X..X.......XX",
				"X-X-X-..........X-X-X-..........",
				"..X...X...........X...X...X.......X...X...........XX..XX..X.....",
				"X...X...X..X..X.X...X...X..X.X..",
				"..................X....X.XX.....",
				"X.X...X.X....XX.",
				"X.X...X.X....XX.X.X...X.X..X.XX.",
				"X.X...X.X....XX.X.X.X.X.X....XX.",
				"Xxx...X.X...X...",
				"Xxx...X.X...X...Xxx...X.X.....XX",
				"X..XX.X.X..XX.X.X..XX.X.....Xxx.",
				"X..XX.X.X..XX.X.X..XX.X...XxX...",
				"X..X..........XxX..X............",
				"X.....X.X.......X..X..X.X.......",
				"X.X.X.XxX.....X.X.X.X.XxX.......",
				"..X..X..X.....XX..X..X..X.......",
				"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
				"XXX.Xxx.........Xx..X.X.X...Xx..XXX.Xxx.............X.X.Xx......",
				"X.X.X.X.X.X.X..XX.X.X.X.X.X.X...X.X.X...X.X.X..XX.X.X.X.X.X.X...",
				"X.X...X......XX.X.X...X.........X.X...X......XX.X.X...XX.......X",
				"X.X.X.XX.....XX.X.X.X.XX....Xx..",
				"..X.XXXX.....XX...X.XXXX....Xxx.",
				"X..XX.X.X.X.X...X..XX.X.X.X.X...",
				"X.....X.X.....X.X.....X.X....XX.X.....X.X.....X.X.....X.X..X.XX.",
				"X..XX.X.Xx..Xx..X..XX.X.X.X.Xx..X..XX.X.Xx..Xx..X..XX.X.X.....XX",
				"X...X.X.X...Xx..X...X.X.X.Xx..XX",
				"X.X..X..X.X..X..",
				"X.X..X..X.X..X..X.X..X..X.X..X..",
				"X.X.XX.XX.X.X.X.",
				"X.X.XX.XX.X.X.X.X.X.XX.XX.X.X.X.",
				"Xx.XX.X.Xx.XX.X.Xx.XX.X.Xx.X..X.",
				"X.X..........XX.XxX.............X.X..........XX.XxX...X...X...X.",
				"X....XX.X.......X.....X.Xx..X...",
				"X..X..X.X..X....X..X..X.X..X....X..X..X.X..X....X..X..X.X..X..XX",
				"X.X.X..X.X.XXXXXX.X.X..X.X.XX...",
				"XX.XXX.XXx......XX.XXX.XXx..Xx..XX.XXX.XXx......XX.XXX.XXx....XX",
				"X.X...XXXX..X...X.X...XXXX..X..X",
				"X..XX.X.X.......X..XX.X.X...X.X.X..XX.X.X.......X..XX.X.X.....XX",
				"X...X...XxxX....X...X..X........X...X...XxxX....X...X..X...X.XX.",
				"X.X.X...X.X.X...X.X.X.X.X.X.X...",
				"Xxxxxx..X.X.X.X.Xxxx....X.X.X...",
				"Xxxx...X..X.......X.XX.X..X.....Xxxx...X..X.......X.XX.X..X...XX"
			],
			\frontWeight, 60, // 0-100
			\slideProbability, 30, // 0-100
			\noteProbability, 100, // 0-100
			\accentProbability, 80, // 0-100
			\basslineVel, 96,
			\accentIntensity, 80, // 0-100
			\weights, [],
			\rhythm, [],
			\accents, [],
		]);

		this.calculate([0, 1, 2, 3, 4, 5, 6, 7]);
	}

	set_key {
		arg key, value;
		srm_genParams[key] = value;
	}

	get_pattern {
		^srm_genParams[\patterns].choose;
	}

	get_accent_pattern {
		^srm_genParams[\accent_patterns].choose;
	}

	calculate {
		arg notes = [];
		var total, last_note_down, pat, acc_pat;

		// weights
		srm_patternDict = 0!4!64;
		total = 0;
		srm_genParams[\weights] = 0!(notes.size);
		notes.size.do({
			|index|
			var x_val, y_val;
			x_val = index + 1;
			y_val = 1 / (x_val - 0.95) * (srm_genParams[\frontWeight] / 100.0) + ((100.0 - srm_genParams[\frontWeight]) / 100.0);
			srm_genParams[\weights][index] = y_val;
			total = total + y_val;
		});
		srm_genParams[\weights] = srm_genParams[\weights].normalizeSum;

		// generate rhythm
		srm_patternDict = 0!4!64; // vel, dur, note, prob
		pat = this.get_pattern;
		acc_pat = this.get_accent_pattern;
		srm_genParams[\rhythm] = []; srm_genParams[\accents] = [];
		pat.do({
			|item|
			srm_genParams[\rhythm] = srm_genParams[\rhythm] ++ item;
		});
		acc_pat.do({
			|item|
			srm_genParams[\accents] = srm_genParams[\accents] ++ item;
		});

		// add notes
		last_note_down = -1;
		64.do({
			// TODO check if chars or strings are tested in rhythm and accent checks
			|index|
			var note, chance, noteFound;
			total = 0;
			chance = 1.0.rand;
			noteFound = false;
			notes.size.do({
				|index2|
				total = total + srm_genParams[\weights][index2];
				if((chance < total).and(noteFound.not), {
					note = notes[index2];
					noteFound = true;
				});
			});
			switch(srm_genParams[\rhythm].wrapAt(index),
				$X, {
					var velocity;
					velocity = srm_genParams[\basslineVel];
					if(srm_genParams[\accents].wrapAt(index) == $X, {
						velocity = srm_genParams[\accentIntensity].linlin(0, 100, velocity, 127).round;
					});
					if(
						(last_note_down > -1)
						.and(index-last_note_down < 4)
						.and(100.rand < srm_genParams[\slideProbability]), {
							srm_patternDict[last_note_down][1] = srm_patternDict[last_note_down][1] + (index - last_note_down);
					});
					if(100.rand < srm_genParams[\noteProbability], {
						srm_patternDict[index] = [
							velocity,
							1,
							note,
							100
						];
						last_note_down = index;
					});
				},
				$-, {
					if(last_note_down > -1, {
						srm_patternDict[last_note_down][1] = srm_patternDict[last_note_down][1] + 1;
					});
				},
				$., {

				},
			);
		});
	}

	get_note {
		arg step_nr;
		var note;
		//"vel, len, note, prob".postln;
		note = srm_patternDict[step_nr.mod(srm_patternDict.size)];//.postln;
		^[note[2], note[0], 0, note[1]];
	}

    test {
		srm_genParams[\weights].postln;
		srm_genParams.postln;
		srm_patternDict.postln;
    }
}