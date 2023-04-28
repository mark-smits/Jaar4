Sting64 {

	// class variables
    //classvar
	// instance variables
	var
	// Sting64 vars
	s64_slideArsanel,
	s64_octArsanel,
	s64_velArsanel,
	s64_pitchArsanel,
	s64_pitchDensity, // 0-inf (but around max 64)
	s64_performablePitch, // 0-63
	s64_performableDensity, // 0-63
	s64_pitchList;

	// init funcs
	*initClass {
		// Initializations on class level (e.g. to set up classvars)
	}

	// STING!64 functions
	init {
		s64_pitchDensity = 32;
		s64_performableDensity = 32;
		s64_performablePitch = 32;

		this.calculate;
	}

	set_pitch_density {
		arg value;
		s64_pitchDensity = value;
	}

	set_performable_density {
		arg value;
		s64_performableDensity = value;
	}

	calculate {
		var note = rrand(48, 59), r_val, c1, c2, lvl, oct;

		s64_pitchList = {rrand(48, 59)}!64;
		s64_pitchDensity.do{
			r_val = rrand(0, 63);
			s64_pitchList.put(r_val, note);
		};

		s64_pitchArsanel = 0!64!64;
		64.do{
			|index|
			var indices_to_push_to_root;
			s64_pitchArsanel[index] = [];
			8.do{
				s64_pitchArsanel[index] = s64_pitchArsanel[index] ++ {(48..59).scramble}.value;
			};
			s64_pitchArsanel[index] = s64_pitchArsanel[index].at( (0..63) );
			indices_to_push_to_root = (0..63).scramble;
			index.do{
				|index2|
				s64_pitchArsanel[index][ indices_to_push_to_root[index2] ] = note;
			};
		};

		s64_velArsanel = 0!64!64;
		64.do{
			|index|
			64.do{
				|index2|
				lvl = 0;
				c1 = index.linlin(0, 60, 5, 90);
				c2 = index.linexp(0, 60, 10, 80) * index.linlin(0,60,0.0,1.0).cubed.linlin(0.0, 1.0, 0.2, 0.7);
				if(100.rand<c1,{ lvl = lvl+1 });
				if(100.rand<c2,{ lvl = lvl+1 });
				switch(lvl,
					1, {s64_velArsanel[index].put(index2, 80)},
					2, {s64_velArsanel[index].put(index2, 127)});
			};
			s64_velArsanel[index].put(0, [80, 127].choose());
		};
		7.do{
			|index|
			s64_velArsanel.put(index, s64_velArsanel.at(index+32));
		};

		s64_octArsanel = 0!64!64;
		64.do{
			|index|
			64.do{
				|index2|
				oct = 0;
				if(100.rand<index.linlin(0,60,10,30),{ oct = oct+1 });
				if(100.rand<index.linlin(0,60,10,30),{ oct = oct+1 });
				s64_octArsanel[index].put(index2, oct);
			}
		};

		s64_slideArsanel = 1!64!64;
		64.do{
			|index|
			64.do{
				|index2|
				if(100.rand<index.linlin(0,60,30,50),{
					s64_slideArsanel[index].put(index2, 2);
				});
				if(s64_velArsanel[index][index2] == 0, {
					s64_slideArsanel[index].put(index2, 0);
				});
			}
		}
	}

	mutate_note {
		// function to change a note, does not calculate a chance of mutation!
		arg step_nr;
		64.do({
			|index|
			var lvl, c1, c2, oct;
			// vel
			lvl = 0;
			c1 = index.linlin(0, 60, 5, 90);
			c2 = index.linexp(0, 60, 10, 80) * index.linlin(0,60,0.0,1.0).cubed.linlin(0.0, 1.0, 0.2, 0.7);
			if(100.rand<c1,{ lvl = lvl+1 });
			if(100.rand<c2,{ lvl = lvl+1 });
			s64_velArsanel[index].put(step_nr, [0, 80, 127].at(lvl));
			// oct
			oct = 0;
			if(100.rand<index.linlin(0,60,10,30),{ oct = oct+1 });
			if(100.rand<index.linlin(0,60,10,30),{ oct = oct+1 });
			s64_octArsanel[index].put(step_nr, oct);
			// slide
			if(100.rand<index.linlin(0,60,30,50),{
				s64_slideArsanel[index].put(step_nr, 2);
			});
			if(s64_velArsanel[index][step_nr] == 0, {
				s64_slideArsanel[index].put(step_nr, 0);
			});
		});
		7.do{
			|index|
			s64_velArsanel[index][step_nr] = s64_velArsanel[index+32][step_nr];
		};
	}

	get_note {
		arg step_nr;
		var list;
		step_nr = step_nr.mod(64);
		list = [
			s64_pitchArsanel[s64_pitchDensity][step_nr],
			//s64_pitchList[step_nr],
			s64_velArsanel[s64_performableDensity][step_nr],
			s64_octArsanel[s64_performableDensity][step_nr],
			s64_slideArsanel[s64_performableDensity][step_nr],
		];
		//"note, vel, oct, slide".postln;
		^list;//.postln;
	}

    test {
		s64_slideArsanel.postln;
		s64_octArsanel.postln;
		s64_velArsanel.postln;
		s64_pitchArsanel.dopostln;
		s64_pitchDensity.postln;
		s64_performableDensity.postln;
		s64_pitchList.postln;
    }
}