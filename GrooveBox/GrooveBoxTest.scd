~server_options = Server.default.options; ~server_options.blockSize = 256; s.boot;

~bpm = 130; ~swing = 0.6; ~lfo_busses = 6.collect({ Bus.control(s, 1); }); ~mixer_busses = 8.collect({ Bus.audio(s, 2); });

~lfo_group = Group.new; ~synth_group = Group.new(s, \addToTail); ~mixer_group = Group.new(s, \addToTail);

MIDIClient.init; MIDIIn.connectAll;

("./GrooveBoxUI.scd").loadRelative;
("./GrooveBoxSynthDefs.scd").loadRelative;
("./GrooveBoxTask.scd").loadRelative;
("./GrooveBoxMIDI.scd").loadRelative;

(
~mixer = Synth.new(\mixer, [
	\chan1_in, ~mixer_busses[0],
	\chan2_in, ~mixer_busses[1],
	\chan3_in, ~mixer_busses[2],
	\chan4_in, ~mixer_busses[3],
	\chan5_in, ~mixer_busses[4],
	\chan6_in, ~mixer_busses[5],
	\chan7_in, ~mixer_busses[6],
	\chan8_in, ~mixer_busses[7],
], ~mixer_group);
~lfos = Synth.new(\lfos, [
	\out1, ~lfo_busses[0],
	\out2, ~lfo_busses[1],
	\out3, ~lfo_busses[2],
	\out4, ~lfo_busses[3],
	\out5, ~lfo_busses[4],
	\out6, ~lfo_busses[5],
	\r1, 1,
	\r2, 1,
	\r3, 1,
	\r4, 1,
	\r5, 1,
	\r6, 1,
	\sh1, 0,
	\sh2, 0,
	\sh3, 0,
	\sh4, 0,
	\sh5, 0,
	\sh6, 0,
], ~lfo_group);
)

r.play;
r.stop;

~mixer.set(\lvl1, 0.2);
~mixer.set(\chor1, 1);
~mixer.set(\filt1, 0.15);
~mixer.set(\wow_flutter, 1);
~mixer.set(\ec_s1, 0.5);
~mixer.set(\echo_fb, 1);
~mixer.set(\echo_time, 0.5);
~mixer.set(\rv_s1, 0.5);
~mixer.set(\lvl2, 0);
~mixer.free;

(
~groovebox = GrooveBox.new;
~groovebox.init([
	\arpeggio, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/Arpeggio.txt").asAbsolutePath ),
	\high_strings, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/HighStrings.txt").asAbsolutePath ),
	\keys, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/Keys.txt").asAbsolutePath ),
	\keys_low_octave, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/KeysLowOctave.txt").asAbsolutePath ),
	\long_notes_melody, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/LongNotesMelody.txt").asAbsolutePath ),
	\melodious_bass, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/MelodiousBass.txt").asAbsolutePath ),
	\melodious_bass_harmonic, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/MelodiousBassHarmonic.txt").asAbsolutePath ),
	\rhythmic_bass, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/RhythmicBass.txt").asAbsolutePath ),
	\rhythmic_chords, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/RhythmicChords.txt").asAbsolutePath ),
	\rhythmic_layered_notes_melody, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/RhythmicLayeredNotesMelody.txt").asAbsolutePath ),
	\rhythmic_thin_chords, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/RhythmicThinChords.txt").asAbsolutePath ),
	\short_notes_melody, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/ShortNotesMelody.txt").asAbsolutePath ),
	\simple_stab_bass_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabBassRhythm.txt").asAbsolutePath ),
	\simple_stab_chords_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabChordsRhythm.txt").asAbsolutePath ),
	\simple_stab_full_chords_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabFullChordsRhythm.txt").asAbsolutePath ),
	\simple_stab_note_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabNoteRhythm.txt").asAbsolutePath ),
	\simple_stab_scale_note_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabScaleNoteRhythm.txt").asAbsolutePath ),
	\simple_stab_thin_chords_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabThinChordsRhythm.txt").asAbsolutePath ),
	\spaced_notes_melody, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SpacedNotesMelody.txt").asAbsolutePath )
]);
)

~groovebox.get_note_no_mutation(0, 0);

(
64.collect({
	|index|
	var note, pitch;
	note = p.get_note_no_mutation(3, index);
	if(note[0].isNil.not, {
		pitch = note[0][0];
	}, {
		pitch = 0;
	});
}).plot;
)

(
p = GrooveBox.new;
p.init([
	\arpeggio, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/Arpeggio.txt").asAbsolutePath ),
	\high_strings, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/HighStrings.txt").asAbsolutePath ),
	\keys, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/Keys.txt").asAbsolutePath ),
	\keys_low_octave, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/KeysLowOctave.txt").asAbsolutePath ),
	\long_notes_melody, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/LongNotesMelody.txt").asAbsolutePath ),
	\melodious_bass, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/MelodiousBass.txt").asAbsolutePath ),
	\melodious_bass_harmonic, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/MelodiousBassHarmonic.txt").asAbsolutePath ),
	\rhythmic_bass, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/RhythmicBass.txt").asAbsolutePath ),
	\rhythmic_chords, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/RhythmicChords.txt").asAbsolutePath ),
	\rhythmic_layered_notes_melody, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/RhythmicLayeredNotesMelody.txt").asAbsolutePath ),
	\rhythmic_thin_chords, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/RhythmicThinChords.txt").asAbsolutePath ),
	\short_notes_melody, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/ShortNotesMelody.txt").asAbsolutePath ),
	\simple_stab_bass_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabBassRhythm.txt").asAbsolutePath ),
	\simple_stab_chords_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabChordsRhythm.txt").asAbsolutePath ),
	\simple_stab_full_chords_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabFullChordsRhythm.txt").asAbsolutePath ),
	\simple_stab_note_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabNoteRhythm.txt").asAbsolutePath ),
	\simple_stab_scale_note_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabScaleNoteRhythm.txt").asAbsolutePath ),
	\simple_stab_thin_chords_rhythm, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SimpleStabThinChordsRhythm.txt").asAbsolutePath ),
	\spaced_notes_melody, Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/SpacedNotesMelody.txt").asAbsolutePath )
]);
)

p.set_uses_global_scale(3, true);
p.set_mutation_chance(0, 0);
p.set_pattern_type(0, 2);
p.get_note(3, 0);
p.regen_pattern(3, \keys);
p.set_sting64_pitch_density(0, 1000);
p.set_pattern_length(3, 64);
p.test;

(
// function to test drawing the internal state of the fourth sequencer
var width = 200, height = 200;
w = Window.new("test window", Rect(200, 200, width, height));
w.drawFunc = {
	var notes, min_pitch = 127, max_pitch = 0;
	notes = [];

	64.do({
		|index|
		notes = notes ++ [p.get_note_no_mutation(0, index)];
	});

	notes.do({
		|note_set, index|
		if(note_set[0].isNil.not, {
			note_set[0].do({
				|pitch, index2|
				if(pitch < min_pitch, {
					min_pitch = pitch;
				});
				if(pitch > max_pitch, {
					max_pitch = pitch;
				});
			});
		});
	});

	notes.do({
		|note_set, index|
		if(note_set[0].isNil.not, {
			note_set[0].do({
				|note, index2|
				if(note_set[1][index2] > 0, {
					var vertical_pos;
					vertical_pos = height*(1-note.linlin(min_pitch-0.5, max_pitch+0.5, 0.0, 1.0));
					Pen.line( index/64*width@vertical_pos, (index+note_set[2][index2])/64*width@vertical_pos );
					Pen.strokeColor = Color.grey(1-(note_set[1][index2]/127));
					if(index == p.get_index(3), {
						Pen.strokeColor = Color.red;
					});
					Pen.width = 200/(max_pitch-min_pitch);
					Pen.stroke;
				});
			});
		});
	});
};
w.front;
t = Task({
	while {
		1.0.notNil;
	} {
		p.tick;
		{w.refresh}.defer;
		0.1.wait;
	};
}).play;
)

t.play;
t.stop;

/*

GUI brainstorm

elementen die altijd accesable moeten zijn: bpm & swing dials, track select buttons, mixer button, sequencer/synth switch, regen global chords

sequencer elementen:
- note window
- sequence length, sync, sync length, uses global scale
- randomize settings
- pattern type
- octave offset
- regen pattern

acdgen elementen:
- seqMode
- slideBias, 1.0, //0.5 - 1.5
- octaveBias, 0, // 0 - 100
- octaveBalance, 0.6, // 0.0 > 1.0
- tripletAccent, 0.6, // 0.0 - 0.9
- algorithmBias, 0.0, // -1.0 - 1.0
- variationChance, 0.3, // 0.0 - 1.0
- baseVelocity, 60, // 0 - 127
- holdProbability, 0.2, // 0.0 - 1.0
- randomVelocity, 0, //0 -127
- variation, 0, // 0-2
- density, 100, // 0-100

srm_bl001 elementen:
- frontWeight, 60, // 0-100
- slideProbability, 30, // 0-100
- noteProbability, 100, // 0-100
- accentProbability, 80, // 0-100
- basslineVel, 96,
- accentIntensity, 80, // 0-100

sting64 elementen: (does need rewrite to include type)
- density
- type

*/

/*

// functions for getting information from midi files

(
~notes_lists = [];
PathName.new("~/Desktop/House Engine Export Test/spaced notes melody").filesDo({
	|file, index|
	var noteOnArray = [], noteOffArray = [], minNoteNr = 18, ppsn, fixedNotesArray, notes_list = [], list_reps, list_rep_offset;
	m = SimpleMIDIFile.read(
		file.asAbsolutePath//"~/Desktop/House Engine Export Test/legato bass.mid"
	);
	ppsn = m.division/4;
	//(m.length/ppsn).round.postln;
	//m.plot(true);
	m.midiEvents.do({
		|event|
		if(event[4] > minNoteNr, { // filter out keyswitches
			if((event[2].asString == "noteOn").and(event[1] >= 0), {
				noteOnArray = noteOnArray ++ [
					//startpulse at 96 ppqn, notenr, vel
					[ event[1], event[4], event[5] ]
				];
			},{
				if((event[2].asString == "noteOff").and(event[1] >= 0), {
					noteOffArray = noteOffArray ++ [
						//endpulse at 96 ppqn, notenr
						[ event[1], event[4] ]
					];
				});
			});
		});
	});
	1000.do({//((m.length/ppsn).ceil.asInteger+1).abs.do({
		|i|
		noteOnArray.do({
			arg item, j;
			if( (item[0] >= (i*ppsn-8)).and(item[0] < ((i+1)*ppsn-8)), {
				var len = 1000, end_pulse;
				noteOffArray.do({
					|noteOff, index|
					if(noteOff[1] == item[1], { // same pitch
						var cur_len;
						cur_len = noteOff[0] - item[0];
						if((cur_len > 0).and(cur_len < len), {
							len = cur_len;
						});
					});
				});
				fixedNotesArray = fixedNotesArray ++ [
					[
						item[1] + 3, // compensate moving pitches from A to C for easy calculations
						item[2],
						i,
						len/ppsn//((noteOffArray[j][0] - noteOnArray[j][0])/ppsn)//((noteOffArray[j][0] - noteOnArray[j][0])/ppsn).floor.clip(1, 10000)*ppsn
					]
				];
			});
		});
	});
	//fixedNotesArray.postln;
	notes_list = nil!4!128; // note, vel, oct, dur
	list_reps = 128/((m.length/ppsn).round);
	switch(list_reps.asInteger,
		1, {list_rep_offset = 128},
		2, {list_rep_offset = 64},
		4, {list_rep_offset = 32},
	);
	list_reps.do({
		|index|
		fixedNotesArray.do({
			|note, index2|
			notes_list[ note[2]+(index*list_rep_offset) ] = [
				notes_list[ note[2]+(index*list_rep_offset) ][0].asArray ++ [0, 2, 3, 5, 7, 8, 10].indexOf(note[0].mod(12)),
				notes_list[ note[2]+(index*list_rep_offset) ][1].asArray ++ note[1],
				notes_list[ note[2]+(index*list_rep_offset) ][2].asArray ++ (note[0]/12).floor,
				notes_list[ note[2]+(index*list_rep_offset) ][3].asArray ++ note[3]
			];
			/*
			if([1, 4, 6, 9, 11].includes(note[0].mod(12)), {
				"chromatic".postln;
			});
			*/
		});
	});
	//notes_list.postln;
	~notes_lists = ~notes_lists ++ [ notes_list ];
});
~notes_lists.dopostln;
)

~notes_lists.writeTextArchive( PathName.new("~/Desktop/SpacedNotesMelody.txt").asAbsolutePath );
d = Object.readArchive( PathName.new("~/Documents/SCScripts/House Engine Lists/Keys.txt").asAbsolutePath );
d.dopostln;
~notes_lists[23].dopostln;

(
m = SimpleMIDIFile.new("~/Desktop/test.mid");
m.init1(2, 120, "4/4");
m.timeMode = \seconds;
~notes_lists[23].do({
	|note, index|
	if(note[0].isNil.not, {
		note[0].do({
			|pitch, index2|
			m.addNote(pitch + (12*note[2][index2]), note[1][index2], index/2, note[3][index2]/2);
		});
	});
});
m.adjustEndOfTrack;
m.plot;
)
*/