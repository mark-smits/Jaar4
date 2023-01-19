SynthDef(\acid, {
	arg freq = 220, gate = 0, cutoff = 220, res = 0, glide = 0, kill = 1, decay = 0.3, amp = 1, waveform = 0;
	var sig, env, kill_env;

	cutoff = Lag.kr(cutoff, 0.005);
	res = Lag.kr(res, 0.005);
	freq = Lag.kr(freq, 0.007 + glide);

	env = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.003, decay], curve: [4, -20]), gate: gate);
	kill_env = EnvGen.kr(Env.asr(), kill, doneAction: Done.freeSelf);

	sig = Select.ar(waveform, [Saw.ar(freq), Pulse.ar(freq)]);
	//sig = Saw.ar(freq);
	sig = LPF.ar(sig, 22000); // aliasing
	sig = RLPF.ar(
		sig,
		(cutoff * (1+env)).clip(20, 20000),
		res.linexp(0, 1, 1, 0.05),
		env
	);
	sig = tanh(sig * 2 * amp).softclip * 0.5;

	Out.ar(0, sig!2);

}).add;

SynthDef(\foldy, {
	arg freq = 220, gate = 0, fmIndex1 = 0.3, fmIndex2 = 0.3, fmRatio1 = 0.66, fmRatio2 = 3.3,
	glide = 0, kill = 1, waveFolds = 1, decay = 0.3, amp = 1;
	var sig, env, kill_env, mod1Freq, mod2Freq, mod1Index, mod2Index, mod1, mod2, modFreq;

	waveFolds = Lag.kr(waveFolds, 0.005);
	fmIndex1 = Lag.kr(fmIndex1, 0.005);
	fmIndex2 = Lag.kr(fmIndex2, 0.005);
	freq = Lag.kr(freq, 0.007 + glide);

	mod1Index = fmIndex1 * 7;
	mod1Freq = freq * fmRatio1 * LFNoise2.kr(freq: 0.1, mul: 0.001, add: 1);
	mod1 = SinOsc.ar(freq: mod1Freq, phase: 0, mul: mod1Index * mod1Freq, add: 0);
	mod2Index = fmIndex2 * 4;
	mod2Freq = freq * fmRatio2 * LFNoise2.kr(freq: 0.1, mul: 0.005, add: 1);
	mod2 = SinOsc.ar(freq: mod2Freq, phase: 0, mul: mod2Index * mod2Freq, add: 0);
	modFreq = freq + mod1 + mod2;

	// Sine and triangle
	sig = VarSaw.ar(freq: modFreq, iphase: 0, width: 0.5, mul: 0.5); // triangle wave
	// Fold
	sig = Fold.ar(in: sig * (1 + (waveFolds * 3)), lo: -0.5, hi: 0.5);
	// Hack away some aliasing
	sig = LPF.ar(in: sig, freq: 12000);

	env = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.003, decay], curve: [4, -20]), gate: gate, doneAction: Done.freeSelf);
	kill_env = EnvGen.kr(Env.asr(), kill, doneAction: Done.freeSelf);

	sig = LPF.ar(
		sig,
		(12000 * env).clip(20, 20000),
		env
	);
	sig = tanh(sig * 2 * amp).softclip * 0.5;

	Out.ar(0, sig!2);

}).add;

SynthDef(\kik, {
	arg preamp = 1, amp = 1;
    var freq, sig;
	freq = EnvGen.kr(Env([1000, 66], [0.08], -8));
	sig = SinOsc.ar(freq, 0.5pi, preamp).distort;
	sig = sig * EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: Done.freeSelf);
	sig = tanh(sig * 2 * amp).softclip * 0.5;
    Out.ar(0, sig!2);
}).add;