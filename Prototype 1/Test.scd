s.boot;
("./SequencerPrototypeMIDI.scd").loadRelative;
("./SequencerPrototypeSynthDefs.scd").loadRelative;
("./SequencerPrototypeInit.scd").loadRelative;
("./SequencerPrototypeTasks.scd").loadRelative;
r.play;
r.stop;

~controlDicts.dopostln;
~mutation1.dopostln;

p = SequencerPrototype.new;
p.init; // breekt ergens in het tekenen van de araticulatie
p.setFocusColor(7);
p.setMutations(1, 2, 3, 1, 2);
p.getVelocityDynamicsArray.dopostln;
p.translateTonality(0.4, -1, -1);
p.getPitchConfirmingArray.do({ |array| array.sum.postln });
p.getPitchStepsArray.do({ |array| array.sum.postln });
q.setVelocityDensity(0);
p.resetMutations;
p.getMutatedGateSlideArray;
p.getGateSlideArray;
p.mutateGate(3);
~soundParams.postln;

(
var func;
func = {|in| in.postln};
func.value("lol");
)

(
var ppqn = 1536;
p = SequencerPrototype.new;
q = SequencerPrototype.new;
p.init;
q.init;

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
~voice2 = nil;
/*
~voice2 = Synth.new(\foldy,
	[
		\amp, 0,
		\freq, 110,
		\fmIndex, 0.2,
		\waveFolds, 0.5,
		\decay, 3,
		\gate, 1
	]
);
*/
r = Task({
	var delta, count = 0, pulse1, pulse2, slide1 = 0, slide2 = 0, qncount = 0, trigger_buffer = 0.1; // triggerbuffer is to counteract gate messages being ignored due to being send to close to eachother
	while {
		delta = 60/130/ppqn;
		delta.notNil;
	} {
		// kick
		if(count == 0, {
			Synth.new(\kik);
			if(qncount.mod(4) == 0, {
				// sequencable mutations
				if(~mutation1 > 0, {
					p.mutateGate(~mutation1);
					p.mutateOctave(~mutation1);
					p.mutatePitch(~mutation1);
					p.mutateVelocity(~mutation1);
				});
				if(~mutation2 > 0, {
					q.mutateGate(~mutation2);
					q.mutateOctave(~mutation2);
					q.mutatePitch(~mutation2);
					q.mutateVelocity(~mutation2);
				});
			});
			if(qncount == 0, {
				if(~mutation1 > 0, {
					p.resetMutations;
				});
				if(~mutation2 > 0, {
					q.resetMutations;
				});
			});
			qncount = (qncount + 1).mod(16);
		});
		// bass
		pulse1 = p.handlePulse;
		if(count.mod(ppqn/8) == 0, {
			{p.updatePlotters}.defer;
		});
		if(pulse1.isNil.not, {
			if(pulse1[\vel] == 0, {
				// kill staccato
				~voice1.set(
					\decay, 0.3
				);
			}, {
				// playnote
				//pulse1.postln;
				~voice1.set(
					\amp, pulse1[\vel] * ~soundParams[\acid_drive],
					\freq, pulse1[\pitch].midicps/2,
					\decay, (2 + pulse1[\vel]) * ~soundParams[\acid_decay],
					\gate, 1,
					\cutoff, ~soundParams[\acid_cutoff],
					\res, ~soundParams[\acid_resonance],
					\glide, ~soundParams[\acid_glide],
					\waveform, ~soundParams[\acid_waveshape],
				);
				slide1 = pulse1[\slide];
			});
		});
		// pluck
		pulse2 = q.handlePulse;
		if(count.mod(ppqn/8) == 0, {
			{q.updatePlotters}.defer;
		});
		if(pulse2.isNil.not, {
			if(pulse2[\vel] == 0, {
				// kill staccato
				/*
				if(~voice2.isNil.not, {
					~voice2.set(
						\decay, 0.2
					);
				});
				*/
			}, {
				// playnote
				//pulse2.postln;
				~voice2 = Synth.new(\foldy,
					[
						\amp, pulse2[\vel] * ~soundParams[\foldy_drive],
						\freq, pulse2[\pitch].midicps,
						\fmIndex1, ~soundParams[\foldy_index1],
						\fmIndex2, ~soundParams[\foldy_index2],
						\fmRatio1, ~soundParams[\foldy_ratio1],
						\fmRatio2, ~soundParams[\foldy_ratio2],
						\waveFolds, ~soundParams[\foldy_folding],
						\decay, pulse2[\vel] * ~soundParams[\foldy_decay],
						\gate, 1
					]
				);
				slide2 = pulse2[\slide];
			});
		});
		if(count.mod(ppqn/4) == ((ppqn/4 - 1) * (1 - trigger_buffer)).asInteger, {
			if(slide1.asBoolean.not, {
				~voice1.set(\gate, 0);
			});
			if(slide2.asBoolean.not, {
				if(~voice2.isNil.not, {
					~voice2.set(\gate, 0);
					~voice2 = nil;
				});
			});
			slide1 = 0;
			slide2 = 0;
		});
		delta.yield;
		count = (count + 1).mod(ppqn);
	}
}).play;
)

r.stop;
r.play;
~voice1.set(\kill, 0);
~voice2.set(\kill, 0);

p.mutatePitch(3);
p.mutateOctave(3);
p.mutateGate(3);
p.mutateVelocity(3);

p = p.init;
q = q.init;

p.getMutatedPitchArray;
q.getMutatedPitchArray;
