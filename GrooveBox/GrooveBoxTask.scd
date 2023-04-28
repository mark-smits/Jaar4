r = Task({
	var delta, count = 0, notes;
	while {
		delta = 15/~bpm*(~swing*2);
		delta.notNil;
	} {

		// get notes from the groovebox object
		notes = 6.collect({
			|index|
			~groovebox.get_note(index);
		});

		// put notes in the note function from GrooveBoxSynthDefs.scd
		notes.do({
			|note, index|
			if(note[0].size>0, {
				if(note[1][0]>0, {
					note[0].do({
						|pitch, index2|
						/*
						pitch.postln;
						note[1][index2].postln;
						note[2][index2].postln;
						*/
						~note_func.value(index, pitch, note[1][index2], note[2][index2]);
					});
				});
			});
		});

		~groovebox.tick;

		delta = 15/~bpm*( [~swing, 1-~swing].at(count) *2);
		count = 1-count;
		delta.yield;
	}
});