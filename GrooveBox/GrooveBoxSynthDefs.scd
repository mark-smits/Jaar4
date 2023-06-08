SynthDef.new(\mixer, {
	arg chan1_in, chan2_in, chan3_in, chan4_in, chan5_in, chan6_in, chan7_in, chan8_in,
	lvl1 = 0, lvl2 = 0, lvl3 = 0, lvl4 = 0, lvl5 = 0, lvl6 = 0, lvl7 = 0, lvl8 = 0,
	chor1 = 0, chor2 = 0, chor3 = 0, chor4 = 0, chor5 = 0, chor6 = 0, chor7 = 0, chor8 = 0,
	filt1 = 0, filt2 = 0, filt3 = 0, filt4 = 0, filt5 = 0, filt6 = 0, filt7 = 0, filt8 = 0,
	ec_s1 = 0, ec_s2 = 0, ec_s3 = 0, ec_s4 = 0, ec_s5 = 0, ec_s6 = 0, ec_s7 = 0, ec_s8 = 0,
	rv_s1 = 0, rv_s2 = 0, rv_s3 = 0, rv_s4 = 0, rv_s5 = 0, rv_s6 = 0, rv_s7 = 0, rv_s8 = 0,
	predelay = 0, spring_amount = 0.065, darken = -6, echo_fb = 0, echo_time = 0.5, wow_flutter = 0.5;
	var in, in1, in2, in3, in4, in5, in6, in7, in8,
	sig, echo_dry, echo_wet, echo1, echo2, echo3, wow_flutter_lfo,
	reverb_dry, preProcess, springReso, reverb_wet, predelay_init = 0.075;

	// lag all inputs
	lvl1 = Lag.kr(lvl1, 0.005);
	lvl2 = Lag.kr(lvl2, 0.005);
	lvl3 = Lag.kr(lvl3, 0.005);
	lvl4 = Lag.kr(lvl4, 0.005);
	lvl5 = Lag.kr(lvl5, 0.005);
	lvl6 = Lag.kr(lvl6, 0.005);
	lvl7 = Lag.kr(lvl7, 0.005);
	lvl8 = Lag.kr(lvl8, 0.005);

	chor1 = Lag.kr(chor1, 0.005);
	chor2 = Lag.kr(chor2, 0.005);
	chor3 = Lag.kr(chor3, 0.005);
	chor4 = Lag.kr(chor4, 0.005);
	chor5 = Lag.kr(chor5, 0.005);
	chor6 = Lag.kr(chor6, 0.005);
	chor7 = Lag.kr(chor7, 0.005);
	chor8 = Lag.kr(chor8, 0.005);

	filt1 = Lag.kr(filt1, 0.005);
	filt2 = Lag.kr(filt2, 0.005);
	filt3 = Lag.kr(filt3, 0.005);
	filt4 = Lag.kr(filt4, 0.005);
	filt5 = Lag.kr(filt5, 0.005);
	filt6 = Lag.kr(filt6, 0.005);
	filt7 = Lag.kr(filt7, 0.005);
	filt8 = Lag.kr(filt8, 0.005);

	ec_s1 = Lag.kr(ec_s1, 0.005);
	ec_s2 = Lag.kr(ec_s2, 0.005);
	ec_s3 = Lag.kr(ec_s3, 0.005);
	ec_s4 = Lag.kr(ec_s4, 0.005);
	ec_s5 = Lag.kr(ec_s5, 0.005);
	ec_s6 = Lag.kr(ec_s6, 0.005);
	ec_s7 = Lag.kr(ec_s7, 0.005);
	ec_s8 = Lag.kr(ec_s8, 0.005);

	rv_s1 = Lag.kr(rv_s1, 0.005);
	rv_s2 = Lag.kr(rv_s2, 0.005);
	rv_s3 = Lag.kr(rv_s3, 0.005);
	rv_s4 = Lag.kr(rv_s4, 0.005);
	rv_s5 = Lag.kr(rv_s5, 0.005);
	rv_s6 = Lag.kr(rv_s6, 0.005);
	rv_s7 = Lag.kr(rv_s7, 0.005);
	rv_s8 = Lag.kr(rv_s8, 0.005);

	predelay = Lag.kr(predelay, 0.005);
	spring_amount = Lag.kr(spring_amount, 0.005);
	darken = Lag.kr(darken, 0.005);
	echo_fb = Lag.kr(echo_fb, 0.005);
	echo_time = Lag.kr(echo_time, 0.005);
	wow_flutter = Lag.kr(wow_flutter, 0.005);

	// input

	in1 = In.ar(chan1_in, 2) * lvl1;
	in2 = In.ar(chan2_in, 2) * lvl2;
	in3 = In.ar(chan3_in, 2) * lvl3;
	in4 = In.ar(chan4_in, 2) * lvl4;
	in5 = In.ar(chan5_in, 2) * lvl5;
	in6 = In.ar(chan6_in, 2) * lvl6;
	in7 = In.ar(chan7_in, 2) * lvl7;
	in8 = In.ar(chan8_in, 2) * lvl8;
	in = [in1, in2, in3, in4, in5, in6, in7, in8];

	// chorusing

	8.do({
		|index|
		var signal, chorus, chorusPreProcess, chorusPreDelay = 0.01, chorusDepth = 0.0053,
		chorusMix, chorusDelay, chorusLfo;

		signal = in[index];
		chorusMix = [chor1, chor2, chor3, chor4, chor5, chor6, chor7, chor8].at(index);

		chorusLfo = LFPar.kr(chorusMix.linlin(0.7, 1, 0.5, 0.75));

		chorusPreProcess = signal + (signal * WhiteNoise.ar(0.004));
		chorusDelay = chorusPreDelay + chorusMix.linlin(0.5, 1, chorusDepth, chorusDepth * 0.75);

		chorus = DelayC.ar(
			in: chorusPreProcess,
			maxdelaytime: chorusPreDelay + chorusDepth,
			delaytime: [chorusLfo.range(chorusPreDelay, chorusDelay),
				chorusLfo.range(chorusDelay, chorusPreDelay)
		]);
		chorus = LPF.ar(chorus, 14000);

		in[index] = SelectX.ar(chorusMix * 0.5, [signal, chorus]);
	});

	// filtering

	8.do({
		|index|
		var ffilter;
		ffilter = [filt1, filt2, filt3, filt4, filt5, filt6, filt7, filt8].at(index);
		in[index] = HPF.ar(
			LPF.ar(
				in[index], ffilter.linexp(-1, 0, 200, 20000)),
			ffilter.linexp(0, 1, 20, 20000)
		);
	});

	// summing

	sig = Splay.ar(in);

	// echo send

	echo_dry = tanh(Splay.ar(in * [ec_s1, ec_s2, ec_s3, ec_s4, ec_s5, ec_s6, ec_s7, ec_s8]) + LocalIn.ar(2));

	wow_flutter_lfo = wow_flutter * (SinOsc.kr(7).range(-0.01, 0) + SinOsc.kr(0.55).range(-0.01, 0));

	echo1 = DelayC.ar(echo_dry, 0.224, echo_time.linexp(0, 1, 0.5, 2) * 0.112*(1+wow_flutter_lfo));
	echo2 = DelayC.ar(echo1, 0.21, echo_time.linexp(0, 1, 0.5, 2) * 0.105*(1+wow_flutter_lfo));
	echo3 = DelayC.ar(echo2, 0.202, echo_time.linexp(0, 1, 0.5, 2) * 0.101*(1+wow_flutter_lfo));

	echo_wet = APF.ar(LPF.ar(echo1 + echo2 + echo3, 2500), 4000);
	LocalOut.ar(echo_wet * echo_fb * 0.16);

	// reverb send

	reverb_dry = Splay.ar(in * [rv_s1, rv_s2, rv_s3, rv_s4, rv_s5, rv_s6, rv_s7, rv_s8]);

	preProcess = tanh(BHiShelf.ar(in: reverb_dry, freq: 1000, rs: 1, db: darken, mul: 1.5, add: 0)); // Darken and saturate
	preProcess = DelayN.ar(in: preProcess, maxdelaytime: predelay_init, delaytime: predelay.linlin(0, 1, 0.015, 0.075));
	springReso = Klank.ar(specificationsArrayRef: `[[508, 270, 1153], [0.15, 0.25, 0.1], [1, 1.2, 1.4]], input: preProcess);
	springReso = Limiter.ar(springReso);
	preProcess = preProcess * 0.55; // FreeVerb doesn't like a loud signal
	reverb_wet = tanh(FreeVerb2.ar(in: preProcess, in2: preProcess, mix: 1, room: 0.7, damp: 0.35, mul: 1.8));
	reverb_wet = SelectX.ar(spring_amount, [reverb_wet, springReso]);//(reverb_wet * 0.935) + (springReso * 0.065);

	sig = tanh(sig + echo_wet + reverb_wet);

	Out.ar(0, sig);
}).add;

SynthDef(\anushri, { // todos: check FM signal, clip frequency values from going to high, make it analog like i.e. molly the polly, lag all audio controls
	arg freq = 110, gate = 0, kill_gate = 1, out = 0,
	portamento = 0, fm_on = 0, fm_index = 0, // freq params
	sync_on = 0, sync = 0, pw = 0.5, sub_oct = -1,
	vco_balance = 0.5, vco_pitch = 0, sub_amp = 0, // osc params
	filter_freq = 110, filter_res = 0, filter_env_amount = 1, // filter params
	fuzz_on = 0, fuzz_drive = 1, fuzz_offset = 0.4, master_volume = 1, // shaping params
	vcf_attack = 0.0005, vcf_decay = 1, vcf_sustain = 0, vcf_release = 1, // filter env
	vca_attack = 0.0005, vca_decay = 1, vca_sustain = 0, vca_release = 1, // vca env
	mod_attack = 0.0005, mod_decay = 1, lfo_rate = 1, lfo_shape = 0, mod_balance = 0.5, // mod params
	pwm_amount = 0, sync_amount = 0, freq_amount = 0, ffreq_amount = 0; // mod destinations
	var sig, mod, sub_freq, saw, pulse, sub, vca_env, vcf_env, mod_env, kill_env, lfo, mainOscDriftLfo, subOscDriftLfo;

	// lag inputs
	fm_index = Lag.kr(fm_index, 0.005);
	sync = Lag.kr(sync, 0.005);
	pw = Lag.kr(pw, 0.005);
	vco_balance = Lag.kr(vco_balance, 0.005);
	vco_pitch = Lag.kr(vco_pitch, 0.005);
	sub_amp = Lag.kr(sub_amp, 0.005);
	filter_freq = Lag.kr(filter_freq, 0.005);
	filter_res = Lag.kr(filter_res, 0.005);
	filter_env_amount = Lag.kr(filter_env_amount, 0.005);
	fuzz_drive = Lag.kr(fuzz_drive, 0.005);
	mod_balance = Lag.kr(mod_balance, 0.005);
	pwm_amount = Lag.kr(pwm_amount, 0.005);
	sync_amount = Lag.kr(sync_amount, 0.005);
	freq_amount = Lag.kr(freq_amount, 0.005);
	ffreq_amount = Lag.kr(ffreq_amount, 0.005);

	// analogify
	mainOscDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.001,
		add: 1
	);
	subOscDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.0008,
		add: 1
	);

	// control sources
	vca_env = EnvGen.ar(
		envelope: Env.adsr(
			vca_attack,
			vca_decay,
			vca_sustain,
			vca_release),
		gate: gate,
		doneAction: 2
	);
	vcf_env = EnvGen.ar(
		envelope: Env.adsr(
			vcf_attack,
			vcf_decay,
			vcf_sustain,
			vcf_release),
		gate: gate
	);
	mod_env = EnvGen.kr(
		envelope: Env.perc(
			mod_attack,
			mod_decay),
		gate: gate
	);
	kill_env = EnvGen.ar(Env.asr(0, 1, 0.005), kill_gate, doneAction: 2);
	kill_env = kill_env * EnvGen.ar(Env.linen(0, 5, 0.005), kill_gate, doneAction: 2); // kill after 5 secs
	lfo = Select.kr(lfo_shape, [ // tri, pulse, ramp down, ramp up
		VarSaw.kr(lfo_rate, 0, 0.5),
		Pulse.kr(lfo_rate),
		VarSaw.kr(lfo_rate, 0, 0),
		VarSaw.kr(lfo_rate, 0, 1),
	]);
	mod = SelectX.kr(mod_balance, [mod_env, lfo]);

	// audio processing
	freq = Lag.kr(freq, 0.005 + portamento);
	sub_freq = freq * 2.pow(sub_oct) * subOscDriftLfo;
	freq = freq * 2.pow(vco_pitch/12) * LinExp.kr(mod*freq_amount, 0, 1, 1, 2)
	* SinOsc.ar(freq, mul: fm_index*fm_on, add: 1) * mainOscDriftLfo;
	// oscillators
	saw = SyncSaw.ar(
		freq,
		freq * ((sync + (sync_amount * mod)) * sync_on + 1)
	);
	pulse = Pulse.ar(
		freq,
		pw + (pwm_amount * mod)
	);
	sub = Pulse.ar(sub_freq);
	// mixing
	sig = SelectX.ar(vco_balance, [saw, pulse]);
	sig = SelectX.ar(sub_amp*0.5, [sig, sub]);
	// filtering
	filter_freq = filter_freq * LinExp.ar((filter_env_amount * vcf_env) + (ffreq_amount * mod), 0, 1, 1, 2);
	sig = RLPFD.ar(sig, filter_freq.clip(20, 20000), filter_res, 0, 3.5);
	sig = Select.ar(fuzz_on, [
		sig * vca_env, ( (sig + fuzz_offset) * (fuzz_drive+1) * vca_env).tanh
	]);
	sig = LeakDC.ar(sig) * master_volume * kill_env;
	// output
	Out.ar(out, sig!2);
}).add;

SynthDef(\sh101, {// todos: clip frequency values from going to high, make it analog like i.e. molly the polly, lag all audio controls
	arg freq = 110, gate = 0, kill_gate = 1, portamento = 0, out = 0, // freq params
	pw = 0.5, sub_oct = -1,
	vco_balance = 0.5, vco_pitch = 0, sub_amp = 0, noise_amp = 0,// osc params
	filter_freq = 110, filter_res = 0, filter_env_amount = 1, // filter params
	master_volume = 1, // shaping params
	env_attack = 0.0005, env_decay = 1, env_sustain = 0, env_release = 1, // env
	lfo_rate = 1, // mod params
	pwm_amount = 0, freq_amount = 0, ffreq_amount = 0; // mod destinations
	var sig, mod, sub_freq, saw, pulse, sub, env, kill_env, mainOscDriftLfo, subOscDriftLfo;

	// analogify
	mainOscDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.001,
		add: 1
	);
	subOscDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.0008,
		add: 1
	);

	// lag inputs
	pw = Lag.kr(pw, 0.005);
	vco_balance = Lag.kr(vco_balance, 0.005);
	vco_pitch = Lag.kr(vco_pitch, 0.005);
	sub_amp = Lag.kr(sub_amp, 0.005);
	noise_amp = Lag.kr(noise_amp, 0.005);
	filter_freq = Lag.kr(filter_freq, 0.005);
	filter_res = Lag.kr(filter_res, 0.005);
	filter_env_amount = Lag.kr(filter_env_amount, 0.005);
	pwm_amount = Lag.kr(pwm_amount, 0.005);
	freq_amount = Lag.kr(freq_amount, 0.005);
	ffreq_amount = Lag.kr(ffreq_amount, 0.005);

	// control sources
	env = EnvGen.ar(
		envelope: Env.adsr(
			env_attack,
			env_decay,
			env_sustain,
			env_release),
		gate: gate,
		doneAction: 2
	);
	kill_env = EnvGen.ar(Env.asr(0, 1, 0.005), kill_gate, doneAction: 2);
	kill_env = kill_env * EnvGen.ar(Env.linen(0, 5, 0.005), kill_gate, doneAction: 2); // kill after 5 secs
	mod = VarSaw.kr(lfo_rate, 0, 0.5);

	// audio processing
	freq = Lag.kr(freq, 0.005 + portamento);
	sub_freq = freq * 2.pow(sub_oct) * subOscDriftLfo;
	freq = freq * 2.pow(vco_pitch/12) * LinExp.kr(mod*freq_amount, 0, 1, 1, 2) * mainOscDriftLfo;
	// oscillators
	saw = Saw.ar(
		freq
	);
	pulse = Pulse.ar(
		freq,
		pw + (pwm_amount * mod)
	);
	sub = Pulse.ar(sub_freq);
	// mixing
	sig = SelectX.ar(vco_balance, [saw, pulse]);
	sig = SelectX.ar(sub_amp*0.5, [sig, sub]);
	sig = SelectX.ar(noise_amp*0.5, [sig, WhiteNoise.ar()]);
	// filtering
	filter_freq = filter_freq * LinExp.ar((filter_env_amount * env) + (ffreq_amount * mod), 0, 1, 1, 2);
	sig = RLPF.ar(sig, filter_freq.clip(20, 20000), filter_res.linexp(0, 1, 1, 0.05));
	sig = sig * env * master_volume * kill_env;
	// output
	Out.ar(out, sig!2);
}).add;

SynthDef(\juno6, {// todos: clip frequency values from going to high, make it analog like i.e. molly the polly, lag all audio controls, write a chorus
	arg freq = 110, gate = 0, kill_gate = 1, out = 0, // freq params
	pw = 0.5, sub_oct = -1,
	vco_balance = 0.5, vco_pitch = 0, sub_amp = 0, noise_amp = 0,// osc params
	hpf_freq = 20, filter_freq = 110, filter_res = 0, filter_env_amount = 1, // filter params
	master_volume = 1, chorus = 0, // shaping params
	env_attack = 0.0005, env_decay = 1, env_sustain = 0, env_release = 1, // env
	lfo_rate = 1, // mod params
	pwm_amount = 0, freq_amount = 0, ffreq_amount = 0; // mod destinations
	var sig, mod, sub_freq, saw, pulse, sub, env, kill_env, mainOscDriftLfo, subOscDriftLfo;

	// lag inputs
	pw = Lag.kr(pw, 0.005);
	vco_balance = Lag.kr(vco_balance, 0.005);
	vco_pitch = Lag.kr(vco_pitch, 0.005);
	sub_amp = Lag.kr(sub_amp, 0.005);
	noise_amp = Lag.kr(noise_amp, 0.005);
	hpf_freq = Lag.kr(hpf_freq, 0.005);
	filter_freq = Lag.kr(filter_freq, 0.005);
	filter_res = Lag.kr(filter_res, 0.005);
	filter_env_amount = Lag.kr(filter_env_amount, 0.005);
	pwm_amount = Lag.kr(pwm_amount, 0.005);
	freq_amount = Lag.kr(freq_amount, 0.005);
	ffreq_amount = Lag.kr(ffreq_amount, 0.005);

	// analogify
	mainOscDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.001,
		add: 1
	);
	subOscDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.0008,
		add: 1
	);

	// control sources
	env = EnvGen.ar(
		envelope: Env.adsr(
			env_attack,
			env_decay,
			env_sustain,
			env_release),
		gate: gate,
		doneAction: 2
	);
	kill_env = EnvGen.ar(Env.asr(0, 1, 0.005), kill_gate, doneAction: 2);
	kill_env = kill_env * EnvGen.ar(Env.linen(0, 5, 0.005), kill_gate, doneAction: 2); // kill after 5 secs
	mod = VarSaw.kr(lfo_rate, 0, 0.5);

	// audio processing
	freq = Lag.kr(freq, 0.005);
	sub_freq = freq * 2.pow(sub_oct)*subOscDriftLfo;
	freq = freq * 2.pow(vco_pitch/12) * LinExp.kr(mod*freq_amount, 0, 1, 1, 2) * mainOscDriftLfo;
	// oscillators
	saw = Saw.ar(
		freq
	);
	pulse = Pulse.ar(
		freq,
		pw + (pwm_amount * mod)
	);
	sub = Pulse.ar(sub_freq);
	// mixing
	sig = SelectX.ar(vco_balance, [saw, pulse]);
	sig = SelectX.ar(sub_amp*0.5, [sig, sub]);
	sig = SelectX.ar(noise_amp*0.5, [sig, WhiteNoise.ar()]);
	// filtering
	filter_freq = filter_freq * LinExp.ar((filter_env_amount * env) + (ffreq_amount * mod), 0, 1, 1, 2);
	sig = HPF.ar(sig, hpf_freq);
	sig = RLPF.ar(sig, filter_freq.clip(20, 20000), filter_res.linexp(0, 1, 1, 0.05));
	sig = sig * env * master_volume * kill_env;
	// output
	Out.ar(out, sig!2);
}).add;

SynthDef(\alphajuno, {// todos: clip frequency values from going to high, make it analog like i.e. molly the polly, lag all audio controls, write a chorus
	arg freq = 110, gate = 0, kill_gate = 1, out = 0, // freq params
	sub_oct = 0, dco_pitch = 0, // 0, -1 or -2
	saw_wave = 0, pulse_wave = 0, sub_wave = 0, // alpha juno waveshapes
	pw = 0.5, pwm_amount = 0.45, pwm_speed = 0.5, // pw seperated
	dco_balance = 1, sub_amp = 0, noise_amp = 0,// osc params
	hpf_freq = 20, filter_freq = 110, filter_res = 0, filter_env_amount = 1, // filter params
	master_volume = 1, chorus = 0, // shaping params
	env_attack = 0.0005, env_decay = 1, env_sustain = 0, env_release = 1, // env
	lfo_rate = 1, // mod params
	freq_amount = 0, ffreq_amount = 0; // mod destinations
	// mixing
	var saw, pulse, sub, lfo, sig, env, kill_env, mod,
	mod_pulse1, mod_pulse2, mod_pulse3, mod_pulse4, mod_pulse5, mod_pulse6, mainOscDriftLfo, subOscDriftLfo;

	// lag inputs
	pw = Lag.kr(pw, 0.005);
	dco_balance = Lag.kr(dco_balance, 0.005);
	dco_pitch = Lag.kr(dco_pitch, 0.005);
	sub_amp = Lag.kr(sub_amp, 0.005);
	noise_amp = Lag.kr(noise_amp, 0.005);
	hpf_freq = Lag.kr(hpf_freq, 0.005);
	filter_freq = Lag.kr(filter_freq, 0.005);
	filter_res = Lag.kr(filter_res, 0.005);
	filter_env_amount = Lag.kr(filter_env_amount, 0.005);
	pwm_amount = Lag.kr(pwm_amount, 0.005);
	freq_amount = Lag.kr(freq_amount, 0.005);
	ffreq_amount = Lag.kr(ffreq_amount, 0.005);

	// analogify
	mainOscDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.001,
		add: 1
	);
	subOscDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.0008,
		add: 1
	);

	// control sources
	env = EnvGen.ar(
		envelope: Env.adsr(
			env_attack,
			env_decay,
			env_sustain,
			env_release),
		gate: gate,
		doneAction: 2
	);
	kill_env = EnvGen.ar(Env.asr(0, 1, 0.005), kill_gate, doneAction: 2);
	kill_env = kill_env * EnvGen.ar(Env.linen(0, 5, 0.005), kill_gate, doneAction: 2); // kill after 5 secs
	mod = VarSaw.kr(lfo_rate, 0, 0.5);

	lfo = VarSaw.kr(pwm_speed, 0, 0.5, pwm_amount, pw);

	// audio processing
	freq = Lag.kr(freq, 0.005);
	freq = freq * 2.pow(dco_pitch/12) * LinExp.kr(mod*freq_amount, 0, 1, 1, 2);

	// initial waves
	saw = Saw.ar(freq * mainOscDriftLfo);
	pulse = Pulse.ar(freq * mainOscDriftLfo, Select.kr(pulse_wave, [0.5, 0.25, lfo]));
	sub = Pulse.ar(freq*(2.pow(sub_oct) * subOscDriftLfo), Select.kr(sub_wave, [0.5, 0.25, 0.5, 0.5]));

	// modulation waves
	mod_pulse1 = LFPulse.ar(freq*2, 0, lfo);
	mod_pulse2 = LFPulse.ar(freq*2);
	mod_pulse3 = LFPulse.ar(freq*4);
	mod_pulse4 = LFPulse.ar(freq*8);
	mod_pulse5 = LFPulse.ar(freq*4*(2.pow(sub_oct)));
	mod_pulse6 = LFPulse.ar(freq*(2.pow(sub_oct)));

	// apply modulation waves to saw and sub
	saw = Select.ar(saw_wave, [
		saw,
		saw*mod_pulse2,
		saw*mod_pulse1,
		saw*mod_pulse4,
		saw*mod_pulse4*mod_pulse2,
	]);
	sub = Select.ar(sub_wave, [
		sub,
		sub,
		sub*mod_pulse5*mod_pulse6,
		sub*Select.ar(2+sub_oct, [mod_pulse2, mod_pulse3, mod_pulse4])*mod_pulse6,
	]);

	sig = SelectX.ar(dco_balance, [pulse, saw]);
	sig = SelectX.ar(sub_amp*0.5, [sig, sub]);
	sig = BLowPass4.ar(sig, 20000);
	sig = SelectX.ar(noise_amp*0.5, [sig, WhiteNoise.ar()]);
	sig = LeakDC.ar(sig);
	// filtering
	filter_freq = filter_freq * LinExp.ar((filter_env_amount * env) + (ffreq_amount * mod), 0, 1, 1, 2);
	sig = HPF.ar(sig, hpf_freq);
	sig = RLPF.ar(sig, filter_freq.clip(20, 20000), filter_res.linexp(0, 1, 1, 0.005));
	sig = sig * env * master_volume * kill_env;
	// output
	Out.ar(out, sig!2);
}).add;

SynthDef(\buchla, {// todos: clip frequency values from going to high, make it analog like i.e. molly the polly, lag all audio controls, write a chorus
	arg freq = 110, gate = 0, kill_gate = 1, portamento = 0, out = 0, // freq params
	mod_rat = 1, car_rat = 1, fm_index = 0, fb = 0, bend = 0, // FM params
	attack = 1, decay = 1,
	env_fold = 0, env_mod = 0,
	f_env_min = 300, f_env_max = 10000,
	clip = 0, folds = 0, master_volume = 1; // shaping params;
	var sig, mod, phase, lpg_env, amp_env, kill_env, carDriftLfo, modDriftLfo;

	// lag inputs
	mod_rat = Lag.kr(mod_rat, 0.005);
	car_rat = Lag.kr(car_rat, 0.005);
	fm_index = Lag.kr(fm_index, 0.005);
	fb = Lag.kr(fb, 0.005);
	bend = Lag.kr(bend, 0.005);
	env_fold = Lag.kr(env_fold, 0.005);
	env_mod = Lag.kr(env_mod, 0.005);
	f_env_min = Lag.kr(f_env_min, 0.005);
	f_env_max = Lag.kr(f_env_max, 0.005);
	clip = Lag.kr(clip, 0.005);
	folds = Lag.kr(folds, 0.005);

	// analogify
	carDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.001,
		add: 1
	);
	modDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.0008,
		add: 1
	);

	lpg_env = EnvGen.ar(Env.new([0, 1, 0], [attack, decay], [4, -20]), gate, doneAction: 0);
	amp_env = EnvGen.ar(Env.new([0, 1, 0], [attack, decay], [4, -10]), gate, doneAction: 2);
	kill_env = EnvGen.ar(Env.asr(0, 1, 0.005), kill_gate, doneAction: 2);

	mod = SinOscFB.ar(freq*mod_rat*modDriftLfo, fb*0.5pi, fm_index + (lpg_env * env_mod));
	phase = LFSaw.ar(freq*car_rat*carDriftLfo);
	phase = phase.pow(10.pow(bend)) + mod;
	sig = SinOsc.ar(0, phase.linlin(-1, 1, 0, 2pi), 0.5);

	// folding
	folds = folds + (env_fold * lpg_env);
	sig = Fold.ar(sig * (1 + (folds * 2)), -0.5, 0.5);
	sig = LPF.ar(sig, 12000); // Hack away some aliasing

	sig = RLPF.ar(sig, lpg_env.linlin(0, 1, f_env_min, f_env_max), 0.9);
	// Saturation amp
	sig = tanh(sig * 1.5 * (1+clip)).softclip;

	sig = sig * amp_env * master_volume * kill_env;
	// output
	Out.ar(out, sig!2);
}).add;

~calc_modal_arrays = {
	arg freq, warp1 = 0.8, warp2 = 1.9, tilt = 0,
	shape1 = 0.6, shape2 = 0.47, shape_depth = 1;
	var amps, freqs, times, f_min, f_max;

	amps = Array.interpolation(20, (1+tilt).clip(0, 1), (1-tilt).clip(0, 1));
	freqs = Array.fill(20, {
		|index|
		(1+index).pow(warp1);
	});
	f_min = freqs[0]; f_max = freqs[19];
	freqs = freqs.linlin(f_min, f_max, 1, 20); // rescale ratios
	freqs = freqs*freq;
	freqs.do({
		|fr, index|
		freqs[index] = fr*(warp2.pow(index));
		if(freqs[index]>22000, {
			amps[index] = 0;
		});
	});

	times = amps.collect({
		|amp, index|
		amp/(index+1);
	});

	amps.do({
		|amp, index|
		amps[index] = (
			(cos(shape1*0.5pi*index).abs) * // comb1
			(cos(shape2*0.333pi*index).abs) * // comb2
			shape_depth + (1-shape_depth) )*amp; // "d/w"control
	});
	[freqs, amps, times];
};
SynthDef(\modal, { // modal, make a synthdef
	arg freq = 110, kill_gate = 1, out = 0,
	attack = 0.1, release = 3, impulse_balance = 1,
	ffilter = 0, resonance = 3, master_volume = 1;
	var sig, kill_env;

	// lag inputs
	impulse_balance = Lag.kr(impulse_balance, 0.005);
	ffilter = Lag.kr(ffilter, 0.005);
	resonance = Lag.kr(resonance, 0.005);

	kill_env = EnvGen.ar(Env.linen(0, 5, 0.005), kill_gate, doneAction: 2); // kill after 5 secs

	sig = SelectX.ar(impulse_balance, [
		Impulse.ar(0, 0, 0.5),
		HPF.ar(
			LPF.ar(
				WhiteNoise.ar(EnvGen.ar(Env.new([0,0.017,0], [attack,release], [4, -10]))),
				ffilter.linexp(-1, 0, 500, 20000)),
			ffilter.linexp(0, 1, 20, 5000)
		);
	]);
	sig = Klank.ar(
		`[
			\freqs.ir((1..20)*100),
			\amps.ir((1..20).reciprocal),
			\times.ir((1..20).reciprocal),
	], sig, decayscale: resonance);
	sig = (sig * EnvGen.ar(Env.perc(0.0001, 5), doneAction: 2) * master_volume).tanh;
	sig = sig * kill_env;
	// output
	Out.ar(out, sig!2);
}).add;

SynthDef(\megafm, {
	arg freq = 110, gate = 1, kill_gate = 1, fb = 0, algorithm = 0, out = 0,
	car_at = 1, car_dec = 0.5, car_sl = 0.5, car_sr = 2, car_rel = 1,
	mod_at = 1, mod_dec = 1.5, mod_sl = 0.75, mod_sr = 1, mod_rel = 1,
	op1_lvl = 1, op2_lvl = 1, op3_lvl = 1, op4_lvl = 1,
	op1_rat = 1, op2_rat = 1, op3_rat = 1, op4_rat = 1,
	op1_det = 0, op2_det = 0, op3_det = 0, op4_det = 0;
	var sig, kill_env, op_amps, op_envs, op_freqs, op2_pm, op3_pm, op4_pm, bitdepth = 8,
	op_ratios, op_detunes, op1, op2, op3, op4, mod_env, car_env, carDriftLfo, modDriftLfo,
	op1toout, op1to2, op1to3, op1to4, op2toout, op2to3, op2to4, op3toout, op3to4, op4toout;

	op1toout = Select.kr(algorithm, [0, 0, 0, 0, 0, 0, 0, 1]);
	op2toout = Select.kr(algorithm, [0, 0, 0, 0, 1, 1, 1, 1]);
	op3toout = Select.kr(algorithm, [0, 0, 0, 0, 0, 1, 1, 1]);
	op4toout = Select.kr(algorithm, [1, 1, 1, 1, 1, 1, 1, 1]);
	op1to2 = Select.kr(algorithm, [1, 0, 0, 1, 1, 1, 1, 0]);
	op1to3 = Select.kr(algorithm, [0, 1, 0, 0, 0, 1, 0, 0]);
	op1to4 = Select.kr(algorithm, [0, 0, 1, 0, 0, 1, 0, 0]);
	op2to3 = Select.kr(algorithm, [1, 1, 1, 0, 0, 0, 0, 0]);
	op2to4 = Select.kr(algorithm, [0, 0, 0, 1, 0, 0, 0, 0]);
	op3to4 = Select.kr(algorithm, [1, 1, 1, 1, 1, 0, 0, 0]);

	// lag inputs
	op1toout = Lag.kr(op1toout, 0.005);
	op2toout = Lag.kr(op2toout, 0.005);
	op3toout = Lag.kr(op3toout, 0.005);
	op4toout = Lag.kr(op4toout, 0.005);
	op1to2 = Lag.kr(op1to2);
	op1to3 = Lag.kr(op1to3);
	op1to4 = Lag.kr(op1to4);
	op2to3 = Lag.kr(op2to3);
	op2to4 = Lag.kr(op2to4);
	op3to4 = Lag.kr(op3to4);
	fb = Lag.kr(fb, 0.005);
	op1_lvl = Lag.kr(op1_lvl, 0.005);
	op2_lvl = Lag.kr(op2_lvl, 0.005);
	op3_lvl = Lag.kr(op3_lvl, 0.005);
	op4_lvl = Lag.kr(op4_lvl, 0.005);

	// analogify
	carDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.001,
		add: 1
	);
	modDriftLfo = LFNoise2.kr(
		freq: 0.1,
		mul: 0.0008,
		add: 1
	);

	mod_env = EnvGen.ar(
		Env( [0, 1, mod_sl, mod_sl/2, 0], [mod_at, mod_dec, mod_sr, mod_rel], 'lin', 3, 2 )
		, gate);
	car_env = EnvGen.ar(
		Env( [0, 1, car_sl, car_sl/2, 0], [car_at, car_dec, car_sr, car_rel], 'lin', 3, 2 )
		, gate, doneAction: 2);
	kill_env = EnvGen.ar(Env.asr(0, 1, 0.005), kill_gate, doneAction: 2);
	kill_env = kill_env * EnvGen.ar(Env.linen(0, 5, 0.005), kill_gate, doneAction: 2); // kill after 5 secs
	op_envs = [
		Select.ar(op1toout, [mod_env, car_env]),
		Select.ar(op2toout, [mod_env, car_env]),
		Select.ar(op3toout, [mod_env, car_env]),
		Select.ar(op4toout, [mod_env, car_env]),
	];
	op_amps = [
		op_envs[0] * op1_lvl,
		op_envs[1] * op2_lvl,
		op_envs[2] * op3_lvl,
		op_envs[3] * op4_lvl,
	];

	op_freqs = [
		Lag.kr(op1_rat*(1+op1_det), 0.005) * Select.kr(op1toout, [modDriftLfo, carDriftLfo]),
		Lag.kr(op2_rat*(1+op2_det), 0.005) * Select.kr(op1toout, [modDriftLfo, carDriftLfo]),
		Lag.kr(op3_rat*(1+op3_det), 0.005) * Select.kr(op1toout, [modDriftLfo, carDriftLfo]),
		Lag.kr(op4_rat*(1+op4_det), 0.005) * Select.kr(op1toout, [modDriftLfo, carDriftLfo]),
	]*freq;

	// operator calculations
	op1 = Decimator.ar( SinOscFB.ar(op_freqs[0], fb*0.5pi, op_amps[0]), 44100, bits:bitdepth );
	op2_pm = (op1*op1to2);
	op2 = Decimator.ar( SinOsc.ar(op_freqs[1], op2_pm*2pi, op_amps[1]), 44100, bits:bitdepth );
	op3_pm = ((op1*op1to3) + (op2*op2to3));
	op3 = Decimator.ar( SinOsc.ar(op_freqs[2], op3_pm*2pi, op_amps[2]), 44100, bits:bitdepth );
	op4_pm = ((op1*op1to4) + (op2*op2to4) + (op3+op3to4));
	op4 = Decimator.ar( SinOsc.ar(op_freqs[3], op4_pm*2pi, op_amps[3]), 44100, bits:bitdepth );

	// mixing
	sig = sig = (op1*op1toout) + (op2*op2toout) + (op3*op3toout) + (op4*op4toout);
	sig = RLPF.ar(sig, op_envs[3].linexp(0, 1, 200, 5000), 0.9).tanh;
	sig = sig * kill_env;
	// output
	Out.ar(out, sig!2);
}).add;

~anushri_current_count = 0!6;
~sh101_current_count = 0!6;
~buchla_current_count = 0!6;
~anushri_active = false!6;
~sh101_active = false!6;
~buchla_active = false!6;
~anushri = nil!6;
~sh101 = nil!6;
~buchla = nil!6;

/*
~hold_anushri = false!6;
~anushri_active = false!6;
~hold_sh101 = false!6;
~sh101_active = false!6;
~hold_buchla = false!6;
~buchla_active = false!6;
*/

~juno6_voices = Dictionary.new!6;
~alpha_juno_voices = Dictionary.new!6;
~megafm_voices = Dictionary.new!6;
~modal_voices = Dictionary.new!6;
~sampler_voices = Dictionary.new!6;

~note_func = {
	// todo check all scaling, implement scaling for sustains, modulation amounts & chorus send
	arg track_index, note_nr, vel, length;

	// for mono synths

	// note on actions:

	// if active
	//   update freq
	// else
	//   play note
	// current_count = (current_count+1)mod(10)
	// this_number = current_count.asInteger
	// active = true

	// note off actions:

	// if this_number == current_count
	//   kill note
	//   active = false
	// else
	//   nothing

	if(vel > 0, {

		switch(~synth_indices[track_index],
			0, {
				var this_count;
				// anushri
				if(~anushri_active[track_index], {
					~anushri[track_index].set(\freq, note_nr.midicps);
				}, {
					if(~anushri[track_index].isNil.not, {
						~anushri[track_index].set(\kill_gate, 0);
					});
					~anushri[track_index] = Synth.new(\anushri, [
						\freq, note_nr.midicps,
						\master_volume, vel.linlin(0.0, 1.0, -60, 0).dbamp,
						\gate, 1,
						\out, ~mixer_busses[track_index],
						\portamento, ~anushri_dicts[track_index][\portamento].linexp(0, 1, 0.0005, 1),
						\fm_on, (~anushri_dicts[track_index][\fm_on]*1.999).floor,
						\fm_index, ~anushri_dicts[track_index][\fm_index],
						\pw, ~anushri_dicts[track_index][\pw],
						\sync_on, (~anushri_dicts[track_index][\sync_on]*1.999).floor,
						\sync, ~anushri_dicts[track_index][\sync]*5,
						\vco_pitch, ~anushri_dicts[track_index][\vco_pitch]*12,
						\vco_balance, ~anushri_dicts[track_index][\vco_balance],
						\sub_oct, (~anushri_dicts[track_index][\sub_oct]*2.999).floor-2,
						\sub_amp, ~anushri_dicts[track_index][\sub_amp],
						\vca_attack, ~anushri_dicts[track_index][\vca_attack].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\vca_decay, ~anushri_dicts[track_index][\vca_decay].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\vca_sustain, ~anushri_dicts[track_index][\vca_sustain],
						\vca_release, ~anushri_dicts[track_index][\vca_release].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\filter_freq, ~anushri_dicts[track_index][\filter_freq].linexp(0, 1, 20, 20000),
						\filter_res, ~anushri_dicts[track_index][\filter_res],
						\filter_env_amount, ~anushri_dicts[track_index][\filter_env_amount]*5,
						\fuzz_on, (~anushri_dicts[track_index][\fuzz_on]*1.999).floor,
						\fuzz_drive, ~anushri_dicts[track_index][\fuzz_drive]*5,
						\vcf_attack, ~anushri_dicts[track_index][\vcf_attack].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\vcf_decay, ~anushri_dicts[track_index][\vcf_decay].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\vcf_sustain, ~anushri_dicts[track_index][\vcf_sustain],
						\vcf_release, ~anushri_dicts[track_index][\vcf_release].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\mod_attack, ~anushri_dicts[track_index][\mod_attack].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\mod_decay, ~anushri_dicts[track_index][\mod_decay].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\lfo_rate, ~anushri_dicts[track_index][\lfo_rate].linexp(0, 1, 0.1, 10),
						\lfo_shape, (~anushri_dicts[track_index][\lfo_shape]*3.999).floor,
						\mod_balance, ~anushri_dicts[track_index][\mod_balance],
						\freq_amount, ~anushri_dicts[track_index][\freq_amount],
						\pwm_amount, ~anushri_dicts[track_index][\pwm_amount],
						\sync_amount, ~anushri_dicts[track_index][\sync_amount],
						\ffreq_amount, ~anushri_dicts[track_index][\ffreq_amount]
					], ~synth_group);
				});
				~anushri_current_count[track_index] = (~anushri_current_count[track_index]+1).mod(10);
				this_count = ~anushri_current_count[track_index].asInteger;
				~anushri_active[track_index] = true;
				{
					~anushri_current_count[track_index];
					if(this_count == ~anushri_current_count[track_index], {
						~anushri[track_index].set(\gate, 0);
						~anushri_active[track_index] = false;
					});
				}.defer(15/~bpm*length-0.02);
			},
			1, {
				var this_count;
				// sh101
				if(~sh101_active[track_index], {
					~sh101[track_index].set(\freq, note_nr.midicps);
				}, {
					if(~sh101[track_index].isNil.not, {
						~sh101[track_index].set(\kill_gate, 0);
					});
					~sh101[track_index] = Synth.new(\sh101, [
						\freq, note_nr.midicps,
						\master_volume, vel.linlin(0.0, 1.0, -60, 0).dbamp,
						\gate, 1,
						\out, ~mixer_busses[track_index],
						\portamento, ~sh101_dicts[track_index][\portamento].linexp(0, 1, 0.0005, 1),
						\pw, ~sh101_dicts[track_index][\pw],
						\vco_pitch, ~sh101_dicts[track_index][\vco_pitch]*12,
						\vco_balance, ~sh101_dicts[track_index][\vco_balance],
						\sub_oct, (~sh101_dicts[track_index][\sub_oct]*2.999).floor-2,
						\sub_amp, ~sh101_dicts[track_index][\sub_amp],
						\noise_amp, ~sh101_dicts[track_index][\noise_amp],
						\env_attack, ~sh101_dicts[track_index][\env_attack].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\env_decay, ~sh101_dicts[track_index][\env_decay].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\env_sustain, ~sh101_dicts[track_index][\env_sustain],
						\env_release, ~sh101_dicts[track_index][\env_release].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\filter_freq, ~sh101_dicts[track_index][\filter_freq].linexp(0, 1, 20, 20000),
						\filter_res, ~sh101_dicts[track_index][\filter_res],
						\filter_env_amount, ~sh101_dicts[track_index][\filter_env_amount]*5,
						\lfo_rate, ~sh101_dicts[track_index][\lfo_rate].linexp(0, 1, 0.1, 10),
						\freq_amount, ~sh101_dicts[track_index][\freq_amount],
						\pwm_amount, ~sh101_dicts[track_index][\pwm_amount],
						\ffreq_amount, ~sh101_dicts[track_index][\ffreq_amount],
					], ~synth_group);
				});
				~sh101_current_count[track_index] = (~sh101_current_count[track_index]+1).mod(10);
				this_count = ~sh101_current_count[track_index].asInteger;
				~sh101_active[track_index] = true;
				{
					if(this_count == ~sh101_current_count[track_index], {
						~sh101[track_index].set(\gate, 0);
						~sh101_active[track_index] = false;
					});
				}.defer(15/~bpm*length-0.02);
			},
			2, {
				var this_count;
				// buchla
				if(~buchla_active[track_index], {
					~buchla[track_index].set(\freq, note_nr.midicps);
				}, {
					if(~buchla[track_index].isNil.not, {
						~buchla[track_index].set(\kill_gate, 0);
					});
					~buchla[track_index] = Synth.new(\buchla,[
						\freq, note_nr.midicps,
						\master_volume, vel.linlin(0.0, 1.0, -60, 0).dbamp,
						\gate, 1,
						\out, ~mixer_busses[track_index],
						\portamento, ~buchla_dicts[track_index][\portamento].linexp(0, 1, 0.0005, 1),
						\mod_rat, (~buchla_dicts[track_index][\mod_rat]*4.999 + 0.0001).ceil,
						\car_rat, (~buchla_dicts[track_index][\car_rat]*4.999 + 0.0001).ceil,
						\fb, ~buchla_dicts[track_index][\fb],
						\fm_index, ~buchla_dicts[track_index][\fm_index]*5,
						\env_mod, ~buchla_dicts[track_index][\env_mod]*5,
						\bend, ~buchla_dicts[track_index][\bend].linlin(0, 1, -1, 1),
						\attack, ~buchla_dicts[track_index][\attack].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\decay, ~buchla_dicts[track_index][\decay].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
						\f_env_min, ~buchla_dicts[track_index][\f_env_min].linexp(0, 1, 20, 1000),
						\f_env_max, ~buchla_dicts[track_index][\f_env_max].linexp(0, 1, 200, 10000),
						\folds, ~buchla_dicts[track_index][\folds]*5,
						\env_fold, ~buchla_dicts[track_index][\env_fold]*5,
						\clip, ~buchla_dicts[track_index][\clip]*5,
					], ~synth_group);
				});
				~buchla_current_count[track_index] = (~buchla_current_count[track_index]+1).mod(10);
				this_count = ~buchla_current_count[track_index].asInteger;
				~buchla_active[track_index] = true;
				{
					if(this_count == ~buchla_current_count[track_index], {
						~buchla[track_index].set(\gate, 0);
						~buchla_active[track_index] = false;
					});
				}.defer(15/~bpm*length-0.02);
			},
			3, {
				// juno6
				if(~juno6_voices[track_index][note_nr]!=nil,{~juno6_voices[track_index][note_nr].set(\kill_gate, 0);});
				~juno6_voices[track_index][note_nr] = Synth.new(\juno6, [
					\freq, note_nr.midicps,
					\master_volume, vel.linlin(0.0, 1.0, -60, 0).dbamp,
					\gate, 1,
					\out, ~mixer_busses[track_index],
					\pw, ~juno6_dicts[track_index][\pw],
					\vco_pitch, ~juno6_dicts[track_index][\vco_pitch]*12,
					\vco_balance, ~juno6_dicts[track_index][\vco_balance],
					\sub_oct, (~juno6_dicts[track_index][\sub_oct]*2.999).floor-2,
					\sub_amp, ~juno6_dicts[track_index][\sub_amp],
					\noise_amp, ~juno6_dicts[track_index][\noise_amp],
					\env_attack, ~juno6_dicts[track_index][\env_attack].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\env_decay, ~juno6_dicts[track_index][\env_decay].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\env_sustain, ~juno6_dicts[track_index][\env_sustain],
					\env_release, ~juno6_dicts[track_index][\env_release].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\filter_freq, ~juno6_dicts[track_index][\filter_freq].linexp(0, 1, 20, 20000),
					\filter_res, ~juno6_dicts[track_index][\filter_res],
					\filter_env_amount, ~juno6_dicts[track_index][\filter_env_amount]*5,
					\lfo_rate, ~juno6_dicts[track_index][\lfo_rate].linexp(0, 1, 0.1, 10),
					\freq_amount, ~juno6_dicts[track_index][\freq_amount],
					\pwm_amount, ~juno6_dicts[track_index][\pwm_amount],
					\ffreq_amount, ~juno6_dicts[track_index][\ffreq_amount],
					\hpf_freq, ~juno6_dicts[track_index][\hpf_freq].linexp(0, 1, 20, 20000),
					\chorus, ~juno6_dicts[track_index][\chorus],
				], ~synth_group);
				{
					if(~juno6_voices[track_index][note_nr]!=nil,{
						~juno6_voices[track_index][note_nr].set(\gate,0);
					});
				}.defer(15/~bpm*length);
			},
			4, {
				// alpha juno
				if(~alpha_juno_voices[track_index][note_nr]!=nil,{~alpha_juno_voices[track_index][note_nr].set(\kill_gate, 0);});
				~alpha_juno_voices[track_index][note_nr] = Synth.new(\alphajuno, [
					\freq, note_nr.midicps,
					\master_volume, vel.linlin(0.0, 1.0, -60, 0).dbamp,
					\gate, 1,
					\out, ~mixer_busses[track_index],
					\pw, ~alpha_juno_dicts[track_index][\pw],
					\dco_pitch, ~alpha_juno_dicts[track_index][\dco_pitch]*12,
					\dco_balance, ~alpha_juno_dicts[track_index][\dco_balance],
					\saw_wave, (~alpha_juno_dicts[track_index][\saw_wave]*4.999).floor,
					\pulse_wave, (~alpha_juno_dicts[track_index][\pulse_wave]*2.999).floor,
					\sub_wave, (~alpha_juno_dicts[track_index][\sub_wave]*3.999).floor,
					\sub_oct, (~alpha_juno_dicts[track_index][\sub_oct]*2.999).floor-2,
					\sub_amp, ~alpha_juno_dicts[track_index][\sub_amp],
					\noise_amp, ~alpha_juno_dicts[track_index][\noise_amp],
					\env_attack, ~alpha_juno_dicts[track_index][\env_attack].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\env_decay, ~alpha_juno_dicts[track_index][\env_decay].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\env_sustain, ~alpha_juno_dicts[track_index][\env_sustain],
					\env_release, ~alpha_juno_dicts[track_index][\env_release].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\filter_freq, ~alpha_juno_dicts[track_index][\filter_freq].linexp(0, 1, 20, 20000),
					\filter_res, ~alpha_juno_dicts[track_index][\filter_res],
					\filter_env_amount, ~alpha_juno_dicts[track_index][\filter_env_amount]*5,
					\lfo_rate, ~alpha_juno_dicts[track_index][\lfo_rate].linexp(0, 1, 0.1, 10),
					\freq_amount, ~alpha_juno_dicts[track_index][\freq_amount],
					\pwm_speed, ~alpha_juno_dicts[track_index][\pwm_speed],
					\pwm_amount, ~alpha_juno_dicts[track_index][\pwm_amount],
					\ffreq_amount, ~alpha_juno_dicts[track_index][\ffreq_amount],
					\hpf_freq, ~alpha_juno_dicts[track_index][\hpf_freq].linexp(0, 1, 20, 20000),
					\chorus, ~alpha_juno_dicts[track_index][\chorus],
				], ~synth_group);
				{
					if(~alpha_juno_voices[track_index][note_nr]!=nil,{
						~alpha_juno_voices[track_index][note_nr].set(\gate,0);
					});
				}.defer(15/~bpm*length);
			},
			5, {
				// megafm
				if(~megafm_voices[track_index][note_nr]!=nil,{~megafm_voices[track_index][note_nr].set(\kill_gate, 0);});
				~megafm_voices[track_index][note_nr] = Synth.new(\megafm, [
					\freq, note_nr.midicps,
					\master_volume, vel.linlin(0.0, 1.0, -60, 0).dbamp,
					\gate, 1,
					\out, ~mixer_busses[track_index],
					\op1_lvl, ~megafm_dicts[track_index][\op1_lvl],
					\op2_lvl, ~megafm_dicts[track_index][\op2_lvl],
					\op3_lvl, ~megafm_dicts[track_index][\op3_lvl],
					\op4_lvl, ~megafm_dicts[track_index][\op4_lvl],
					\algorithm, (~megafm_dicts[track_index][\algorithm]*7.999).floor,
					\fb, ~megafm_dicts[track_index][\fb],
					\op1_rat, ([0.5]++(1..15)).at((~megafm_dicts[track_index][\op1_rat]*15.999).floor),
					\op2_rat, ([0.5]++(1..15)).at((~megafm_dicts[track_index][\op2_rat]*15.999).floor),
					\op3_rat, ([0.5]++(1..15)).at((~megafm_dicts[track_index][\op3_rat]*15.999).floor),
					\op4_rat, ([0.5]++(1..15)).at((~megafm_dicts[track_index][\op4_rat]*15.999).floor),
					\op1_det, ~megafm_dicts[track_index][\op1_det].linexp(0, 1, 0.1, 1.1) - 0.1,
					\op2_det, ~megafm_dicts[track_index][\op2_det].linexp(0, 1, 0.1, 1.1) - 0.1,
					\op3_det, ~megafm_dicts[track_index][\op3_det].linexp(0, 1, 0.1, 1.1) - 0.1,
					\op4_det, ~megafm_dicts[track_index][\op4_det].linexp(0, 1, 0.1, 1.1) - 0.1,
					\car_at, ~megafm_dicts[track_index][\car_at].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\car_dec, ~megafm_dicts[track_index][\car_dec].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\car_sl, ~megafm_dicts[track_index][\car_sl],
					\car_sr, ~megafm_dicts[track_index][\car_sr].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\car_rel, ~megafm_dicts[track_index][\car_rel].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\mod_at, ~megafm_dicts[track_index][\mod_at].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\mod_dec, ~megafm_dicts[track_index][\mod_dec].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\mod_sl, ~megafm_dicts[track_index][\mod_sl],
					\mod_sr, ~megafm_dicts[track_index][\mod_sr].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
					\mod_rel, ~megafm_dicts[track_index][\mod_rel].linexp(0, 1, 0.1, 10).linlin(0.1, 10, 0.0005, 10),
				], ~synth_group);
				{
					if(~megafm_voices[track_index][note_nr]!=nil,{
						~megafm_voices[track_index][note_nr].set(\gate,0);
					});
				}.defer(15/~bpm*length);
			},
			6, {
				// modal
				var fr, am, ti;
				if(~modal_voices[track_index][note_nr]!=nil,{~modal_voices[track_index][note_nr].set(\kill_gate,0);});
				#fr, am, ti = ~calc_modal_arrays.value(
					note_nr.midicps,
					~modal_dicts[track_index][\warp1].linexp(0, 1, 0.5, 2),
					~modal_dicts[track_index][\warp2].linexp(0, 1, 0.5, 2),
					~modal_dicts[track_index][\tilt].linlin(0, 1, -1, 1),
					~modal_dicts[track_index][\shape1],
					~modal_dicts[track_index][\shape2],
					~modal_dicts[track_index][\shape_depth]
				);
				~modal_voices[track_index][note_nr] = Synth.new(\modal, [
					\freq, note_nr.midicps,
					\master_volume, vel.linlin(0.0, 1.0, -60, 0).dbamp,
					\out, ~mixer_busses[track_index],
					\freqs, fr,
					\amps, am,
					\times, ti,
					\impulse_balance, ~modal_dicts[track_index][\impulse_balance],
					\ffilter, ~modal_dicts[track_index][\ffilter].linlin(0, 1, -1, 1),
					\attack, ~modal_dicts[track_index][\attack].linexp(0, 1, 0.005, 3),
					\release, ~modal_dicts[track_index][\release].linexp(0, 1, 0.005, 3),
					\resonance, ~modal_dicts[track_index][\resonance].linexp(0, 1, 0.5, 10),
				], ~synth_group);
				/*
				{
				~modal_voices[track_index][note_nr].set(\gate,0);
				}.defer(15/~bpm*length);
				*/
			},
			7, {
				// sampler
			},
		);
	});
};

SynthDef(\bufplay, {
	arg bufnum, rate = 1, amp = 1, dur = 1, startPos = 0, pan = 0, out;
	var sig, env;
	env = EnvGen.ar( Env([0, 1, 1, 0], [0.0005, dur-0.001, 0.0005]), doneAction: 2);
	sig = PlayBuf.ar(2, bufnum, BufRateScale.ir(bufnum) * rate, startPos: startPos-24, loop: 1, doneAction:0);
	sig = sig * amp * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

~sound_file_buffers = Buffer.allocConsecutive(8, s, 262114, 2);//8.collect({ |index| Buffer.alloc(s, 262144, 2) });

~find_bpm = {
	arg dur;
	var bpm_min = 90, bpm_max = 180, bpm, tries = 100;
	bpm = 60;
	bpm = bpm/dur;
	while(
		{(bpm > bpm_max).or(bpm < bpm_min).or(tries < 0)},
		{
			if(bpm > bpm_max, {
				bpm = bpm/2;
			}, {
				bpm = bpm*2;
			});
			tries = tries-1;
		}
	);
	bpm; // dur 16th = 15/bpm
};

~play_samples = {
	var sf;
	sf = nil!8;
	8.do({
		|index|
		var amp, pan, dur_mult;
		{
			if(~trigger_buttons[index][~trigger_indices[index]].value.asBoolean, {
				var val1, val2, knob_val1, knob_val2, start = 0, bus_nr = 6;
				sf[index] = ~sound_file_dict[
					~sample_folder_menu[index].item.asSymbol
				][
					~sample_menu[index].item.asSymbol
				];

				knob_val1 = ~vel_rand_param_knobs[index][0].value;
				knob_val2 = ~vel_rand_param_knobs[index][2].value;
				val1 = ~vel_bar_vals[index][~global_sample_index];
				val2 = ~vel_pattern_vals[index][~trigger_indices[index]];
				val1 = [knob_val1.linlin(0, 0.5, 0, val1), knob_val1.linlin(0.5, 1, val1, 1)].at((knob_val1*1.999).asInteger);
				val2 = [knob_val2.linlin(0, 0.5, 0, val2), knob_val2.linlin(0.5, 1, val2, 1)].at((knob_val2*1.999).asInteger);
				amp = ~vel_rand_param_knobs[index][1].value.linlin(0, 1, val1, val2);

				knob_val1 = ~pan_rand_param_knobs[index][0].value;
				knob_val2 = ~pan_rand_param_knobs[index][2].value;
				val1 = ~pan_bar_vals[index][~global_sample_index];
				val2 = ~pan_pattern_vals[index][~trigger_indices[index]];
				if(val1 < 0.5, {
					val1 = [knob_val1.linlin(0, 0.5, 0.5, val1), knob_val1.linlin(0.5, 1, val1, 0)].at((knob_val1*1.999).asInteger);
				}, {
					val1 = [knob_val1.linlin(0, 0.5, 0.5, val1), knob_val1.linlin(0.5, 1, val1, 1)].at((knob_val1*1.999).asInteger);
				});
				if(val2 < 0.5, {
					val2 = [knob_val2.linlin(0, 0.5, 0.5, val2), knob_val2.linlin(0.5, 1, val2, 0)].at((knob_val2*1.999).asInteger);
				}, {
					val2 = [knob_val2.linlin(0, 0.5, 0.5, val2), knob_val2.linlin(0.5, 1, val2, 1)].at((knob_val2*1.999).asInteger);
				});
				pan = ~pan_rand_param_knobs[index][1].value.linlin(0, 1, val1, val2).linlin(0, 1, -1, 1);

				knob_val1 = ~dec_rand_param_knobs[index][0].value;
				knob_val2 = ~dec_rand_param_knobs[index][2].value;
				val1 = ~dec_bar_vals[index][~global_sample_index];
				val2 = ~dec_pattern_vals[index][~trigger_indices[index]];
				val1 = [knob_val1.linlin(0, 0.5, 0, val1), knob_val1.linlin(0.5, 1, val1, 1)].at((knob_val1*1.999).asInteger);
				val2 = [knob_val2.linlin(0, 0.5, 0, val2), knob_val2.linlin(0.5, 1, val2, 1)].at((knob_val2*1.999).asInteger);
				dur_mult = ~dec_rand_param_knobs[index][1].value.linlin(0, 1, val1, val2);

				~sound_file_buffers[index].read(sf[index].path);

				if(index > 3, {
					start = 15 / ~find_bpm.value(sf[index].duration) * ~trigger_indices[index];
					bus_nr = 7;
				});

				Synth.new(\bufplay, [
					\bufnum, ~sound_file_buffers[index].bufnum,
					\dur, 15/~bpm*dur_mult,
					\startPos, start*44100,
					\rate, 1,
					\amp, amp.linlin(0, 1, -60, 0).dbamp * ~sample_levels[index],
					\pan, pan,
					\out, ~mixer_busses[bus_nr],
				], ~synth_group);
			});
		}.defer;
	});
};