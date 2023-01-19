s.boot;
("./SequencerPrototypeMIDI.scd").loadRelative;
("./SequencerPrototypeSynthDefs.scd").loadRelative;
("./SequencerPrototypeInit.scd").loadRelative;
("./SequencerPrototypeTasks.scd").loadRelative;
r.play;
r.stop;

// function to make only track four sound
(
3.do({
	|index|
	~controlDicts[index][\vel_density] = 0;
	~updateSequencer.value(index);
});
)

// function to slowly change the character of the sequence
(
r {
	// init pitch, vel, oct
	~controlDicts[3][\pitch_rand] = 10;
	~controlDicts[3][\pitch_steps] = 8;
	~controlDicts[3][\pitch_conf] = 14;

	~controlDicts[3][\vel_density] = 10;
	~controlDicts[3][\vel_sync] = 2;
	~controlDicts[3][\vel_dyn] = 11;
	~controlDicts[3][\vel_probability] = 14;
	~controlDicts[3][\timing_swing] = 0;

	~controlDicts[3][\oct_density] = 0;
	~updateSequencer.value(3);

	7.wait;
	// pitch change
	~controlDicts[3][\pitch_rand] = 6;
	~controlDicts[3][\pitch_steps] = 5;
	~controlDicts[3][\pitch_conf] = 0;
	~updateSequencer.value(3);

	7.wait;
	// vel change
	~controlDicts[3][\vel_density] = 14;
	~controlDicts[3][\vel_sync] = 9;
	~controlDicts[3][\vel_dyn] = 3;
	~controlDicts[3][\vel_probability] = 11;
	~controlDicts[3][\timing_swing] = 6;
	~updateSequencer.value(3);

}.play;
)

// function for a phasing sequencer
(
~controlDicts[3][\pitch_length] = 3;
~controlDicts[3][\vel_length] = 8;
~controlDicts[3][\oct_length] = 11;
~controlDicts[3][\art_length] = 7;

~controlDicts[3][\vel_density] = 14;
~controlDicts[3][\vel_dyn] = 2;
~controlDicts[3][\pitch_steps] = 0;
~controlDicts[3][\pitch_rand] = 14;
~controlDicts[3][\art_accents] = 2;

~mutation4[\pitch] = 2;

~updateSequencer.value(3);
)

// function for two sequencers to play overtop eachother
(
~resetControlDicts.value();
// mute tracks 1 & 3
~controlDicts[0][\vel_density] = 0;
~controlDicts[2][\vel_density] = 0;
~updateSequencer.value(0);
~updateSequencer.value(2);
// acid params
~controlDicts[1][\pitch_length] = 8;
~controlDicts[1][\vel_length] = 8;
~controlDicts[1][\oct_length] = 16;

~controlDicts[1][\vel_density] = 7;
~controlDicts[1][\vel_dyn] = 7;
~controlDicts[1][\vel_sync] = 9;
~controlDicts[1][\pitch_steps] = 0;
~controlDicts[1][\pitch_rand] = 14;
~controlDicts[1][\art_slide] = 2;
~controlDicts[1][\art_accents] = 2;
~controlDicts[1][\oct_density] = 2;
~controlDicts[1][\oct_offset] = 1;

~updateSequencer.value(1);
// fm params
~controlDicts[3][\vel_density] = 10;
~controlDicts[3][\vel_dyn] = 4;
~controlDicts[3][\vel_sync] = 3;
~controlDicts[3][\pitch_steps] = 10;
~controlDicts[3][\pitch_rand] = 10;
~controlDicts[3][\oct_density] = 0;
~controlDicts[3][\oct_offset] = 3;

~updateSequencer.value(3);
)
