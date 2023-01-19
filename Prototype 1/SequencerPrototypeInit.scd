// sequencer params

~ppqn = 1536;
p = SequencerPrototype.new!4;
p.do({
	|prot, index|
	prot.init;
});

// voices (1, 2 = acid, 3, 4 = foldy)
~voice1 = Synth.new(\acid,
	[
		\amp, 0,
		\freq, 110,
		\res, 0.5,
		\decay, 3,
		\gate, 1,
		\cutoff, 220
	]
);
~voice2 = Synth.new(\acid,
	[
		\amp, 0,
		\freq, 110,
		\res, 0.5,
		\decay, 3,
		\gate, 1,
		\cutoff, 220
	]
);