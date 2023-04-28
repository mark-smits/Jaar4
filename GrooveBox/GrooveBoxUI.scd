
// window and comp views
~window = Window.new("", Rect(50, 100, 800, 450) ); ~window.front;
~comp_view_global = [
	CompositeView(~window, Rect(20, 20, 370, 195) ),
	CompositeView(~window, Rect(20, 235, 370, 195) ),
	CompositeView(~window, Rect(410, 20, 370, 195) ),
	CompositeView(~window, Rect(410, 235, 370, 195) ),
];
4.do({
	|index|
	~comp_view_global[index].background = Color.grey(0.5);
});

// faders and knobs for launchcontrol XL mixer
~mixer_sliders = 8.collect({
	|index|
	var hor_inc;
	hor_inc = 350/8;
	Slider.new(~comp_view_global[3], Rect(10 + (hor_inc*(index+0.375)), 105, hor_inc/4, 80));
});

~mixer_knobs = 8.collect({
	|index|
	var hor_inc;
	hor_inc = 350/8;
	3.collect({
		|index2|
		Knob.new(~comp_view_global[3], Rect(10 + (hor_inc*(index+0.25)), 10 + (30*index2), hor_inc/2, hor_inc/2)).mode_(\vert);
	});
});

~mixer_knobs.do({
	|list, index|
	list[2].value = 0.5;
});

6.do({
	|index|
	~mixer_sliders[index].action_({
		~mixer.set(
			[\lvl1, \lvl2, \lvl3, \lvl4, \lvl5, \lvl6].at(index),
			~mixer_sliders[index].value
		);
	});
	~mixer_knobs[index].do({
		|knob, index2|
		knob.action_({
			|kn|
			var symb;
			symb = [
				[\rv_s1, \rv_s2, \rv_s3, \rv_s4, \rv_s5, \rv_s6].at(index),
				[\ec_s1, \ec_s2, \ec_s3, \ec_s4, \ec_s5, \ec_s6].at(index),
				[\filt1, \filt2, \filt3, \filt4, \filt5, \filt6].at(index)
			].at(index2);
			~mixer.set(
				symb, [kn.value, kn.value, kn.value.linlin(0, 1, -1, 1)].at(index2)
			);
		});
	});
});

// comp views for sequencers
~track_buttons = 6.collect({
	|index|
	Button(~comp_view_global[0], Rect(10+(index*60), 10, 50, 10) )
});
~track_buttons.do({
	|button, index|
	button.action_({
		~sequencer_note_comp_views.do({
			|cv, index2|
			cv.animate = false;
		});
		~sequencer_note_comp_views[index].animate = true;
		~sequencer_comp_views.do({
			|cv, index2|
			cv.visible = false;
		});
		~sequencer_comp_views[ index ].visible_(true);
		~synth_comp_views.do({
			|cv, index2|
			cv.visible = false;
		});
		~synth_comp_views[ index ].visible_(true);
	});
});
~sequencer_comp_views = 6.collect({
	|index|
	CompositeView(~comp_view_global[0], Rect(0, 30, 370, 165)).background_(
		Color.grey(0.3)
	).visible_(false)
});
~sequencer_type_buttons = 6.collect({
	|index|
	4.collect({
		|index2|
		Button(~sequencer_comp_views[index], Rect(10, 45+(index2*30), 20, 20) ).action_({
			~groovebox.set_pattern_type(index, index2);
			~sequencer_type_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~sequencer_type_comp_views[index][index2].visible = true;
		});
	})
});
~sequencer_regen_buttons = 6.collect({
	|index|
	Button(~sequencer_comp_views[index], Rect(10, 10, 20, 20) ).action_({
		~groovebox.regen_pattern(index, ~house_engine_menu[index].item.asSymbol);
	});
});
~sequencer_type_comp_views = 6.collect({
	|index|
	4.collect({
		|index2|
		CompositeView(~sequencer_comp_views[index], Rect(40, 60, 330, 115)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});
~sequencer_note_comp_views = 6.collect({
	|index|
	UserView.new(
		~sequencer_comp_views[index],
		Rect(200, 10, 160, 50)
	).drawFunc_({
		// todo: add pattern length visualization
		var notes, min_pitch = 127, max_pitch = 0, width = 160, height = 50, num_notes;
		notes = []; num_notes = ~groovebox.get_pattern_length(index);

		num_notes.do({
			|index2|
			notes = notes ++ [~groovebox.get_note_no_mutation(index, index2)];
		});

		notes.do({
			|note_set, index2|
			if(note_set[0].isNil.not, {
				note_set[0].do({
					|pitch, index3|
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
			|note_set, index2|
			if(note_set[0].isNil.not, {
				note_set[0].do({
					|note, index3|
					if(note_set[1][index3] > 0, {
						var vertical_pos;
						vertical_pos = height*(1-note.linlin(min_pitch-0.5, max_pitch+0.5, 0.0, 1.0));
						Pen.line( index2/num_notes*width@vertical_pos, (index2+note_set[2][index3])/num_notes*width@vertical_pos );
						Pen.strokeColor = Color.grey(1-(note_set[1][index3]/127));
						if(index2 == ~groovebox.get_index(index), {
							Pen.strokeColor = Color.red;
						});
						Pen.width = height/(max_pitch-min_pitch).clip(1, 127);
						Pen.stroke;
					});
				});
			});
		});
	}).background_(Color.white).animate_(false).frameRate_(30);
});
~sequencer_length_labels = 6.collect({
	|index|
	StaticText(~sequencer_comp_views[index], Rect(60, 10, 30, 20) )
	.string_(
		"length: " ++ ~groovebox.get_pattern_length(index).asInteger.asString
	).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
});
~sequencer_length_knobs = 6.collect({
	|index|
	Knob.new(~sequencer_comp_views[index], Rect(40, 10, 20, 20) ).mode_(\vert).action_({
		|knob|
		~groovebox.set_pattern_length(index, (knob.value*126.99).floor+1);
		~sequencer_length_labels[index].string = "length: " ++ ~groovebox.get_pattern_length(index).asInteger.asString;
	});
});
~sequencer_uses_global_scale_buttons = 6.collect({
	|index|
	StaticText(~sequencer_comp_views[index], Rect(110, 10, 30, 20) )
	.string_("global scale").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Button(~sequencer_comp_views[index], Rect(90, 10, 20, 20) )
	.states_([["", Color.white, Color.white], ["", Color.red, Color.red]])
	.action_({|button| ~groovebox.set_uses_global_scale(index, button.value.asBoolean)});
});
~sequencer_sync_length_labels = 6.collect({
	|index|
	StaticText(~sequencer_comp_views[index], Rect(60, 40, 30, 20) )
	.string_("sync len: 1").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
});
~sequencer_sync_length_knobs = 6.collect({
	|index|
	Knob.new(~sequencer_comp_views[index], Rect(40, 40, 20, 20) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_pattern_syncing_lengths_bars(index, (knob.value*7.99).floor+1);
		~sequencer_sync_length_labels[index].string = "sync len: " ++ ((knob.value*7.99).floor+1).asInteger.asString;
	});
});
~sequencer_sync_buttons = 6.collect({
	|index|
	StaticText(~sequencer_comp_views[index], Rect(110, 40, 30, 20) )
	.string_("sync").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Button(~sequencer_comp_views[index], Rect(90, 40, 20, 20) )
	.states_([["", Color.white, Color.white], ["", Color.red, Color.red]])
	.action_({|button| ~groovebox.set_pattern_syncing(index, button.value.asBoolean)});
});
~sequencer_octave_labels = 6.collect({
	|index|
	StaticText(~sequencer_comp_views[index], Rect(160, 40, 30, 20) )
	.string_("octave: 0").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
});
~sequencer_octave_knobs = 6.collect({
	|index|
	Knob.new(~sequencer_comp_views[index], Rect(140, 40, 20, 20) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_octave_offset(index, knob.value.linlin(0, 1, -2, 2.99).floor);
		~sequencer_octave_labels[index].string = "octave: " ++ knob.value.linlin(0, 1, -2, 2.99).floor.asInteger.asString;
	});
});
~sequencer_randomize_buttons = 6.collect({
	|index|
	StaticText(~sequencer_comp_views[index], Rect(160, 10, 30, 20) )
	.string_("rand.").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Button(~sequencer_comp_views[index], Rect(140, 10, 20, 20) );
});

~house_engine_menu = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][0], Rect(50, 30, 230, 10) )
	.string_("sequence key").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	PopUpMenu(~sequencer_type_comp_views[index][0], Rect(50, 50, 230, 20) )
	.items_( [
		\arpeggio,
		\high_strings,
		\keys,
		\keys_low_octave,
		\long_notes_melody,
		\melodious_bass,
		\melodious_bass_harmonic,
		\rhythmic_bass,
		\rhythmic_chords,
		\rhythmic_layered_notes_melody,
		\rhythmic_thin_chords,
		\short_notes_melody,
		\simple_stab_bass_rhythm,
		\simple_stab_chords_rhythm,
		\simple_stab_full_chords_rhythm,
		\simple_stab_note_rhythm,
		\simple_stab_scale_note_rhythm,
		\simple_stab_thin_chords_rhythm,
		\spaced_notes_melody,
	]);
});

~acd_gen_multi_sliders = 6.collect({
	|index|
	9.do({
		|index2|
		StaticText(~sequencer_type_comp_views[index][1], Rect(120, 7.5+(index2*10), 70, 10) ).string_(
			[
				"base velocity",
				"variation chance",
				"algorithm bias",
				"hold probability",
				"slide probability",
				"octave probability",
				"octave balance",
				"triplet accent",
				"random velocity"
			].at(index2)
		).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	});
	MultiSliderView(~sequencer_type_comp_views[index][1], Rect(200, 5, 120, 95) )
	.value_( [60/127.0, 0.3, 0.5, 0.2, 0.5, 0.0, 0.6, 0.67, 0.0] )
	.action_({
		|msv|
		msv.value.do({
			|val, index2|
			~groovebox.set_acdgen_key(index,
				[
					\baseVelocity,
					\variationChance,
					\algorithmBias,
					\holdProbability,
					\slideBias,
					\octaveBias,
					\octaveBalance,
					\tripletAccent,
					\randomVelocity,
				].at(index2),
				[
					msv.value[0].linlin(0, 1, 0, 127).asInteger,
					msv.value[1],
					msv.value[2].linlin(0, 1, -1, 1),
					msv.value[3],
					msv.value[4]+0.5,
					(msv.value[5]*100).asInteger,
					msv.value[6],
					msv.value[7]*0.9,
					msv.value[8].linlin(0, 1, 0, 127).asInteger
			].at(index2));
		});
	})
	.isFilled_(true).indexThumbSize_(10).gap_(0).indexIsHorizontal_(false);
});
~acd_gen_seq_mode_menus = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][1], Rect(10, 65, 100, 10) )
	.string_("sequence algorithm").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	PopUpMenu(~sequencer_type_comp_views[index][1], Rect(10, 77.5, 100, 20) )
	.items_( [
		"Normal", "Floor", "FifthOct",
		"Upwards", "Downwards", "Up-Stepped",
		"Down-Stepped", "Arp3"] )
	.action_({
		|pum|
		~groovebox.set_acdgen_key(index, \seqMode, pum.item);
	});
});
~acd_gen_density_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][1], Rect(0, 50, 50, 10) )
	.string_("density").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Knob.new(~sequencer_type_comp_views[index][1], Rect(10, 20, 30, 30) ).mode_(\vert)
	.action_({|knob| ~groovebox.set_acdgen_key(index, \density, (knob.value*100.99).floor) });
});
~acd_gen_variation_labels = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][1], Rect(35, 50, 50, 10) )
	.string_("variation 0").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
});
~acd_gen_variation_knobs = 6.collect({
	|index|
	Knob.new(~sequencer_type_comp_views[index][1], Rect(45, 20, 30, 30) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_acdgen_key(index, \variation, (knob.value*2.99).floor);
		~acd_gen_variation_labels[index].string = "variation " ++ (knob.value*2.99).floor.asInteger;
	});
});
~acd_gen_mutation_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][1], Rect(70, 50, 50, 10) )
	.string_("mutation").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Knob.new(~sequencer_type_comp_views[index][1], Rect(80, 20, 30, 30) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_mutation_chance(index, knob.value);
	});
});

~srm_bl001_bassline_velocity_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][2], Rect(10, 65, 50, 20) )
	.string_("bassline velocity").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Knob.new(~sequencer_type_comp_views[index][2], Rect(15, 25, 40, 40) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_srm_key(index, \basslineVel, (knob.value*127.99).floor);
	});
});
~srm_bl001_front_weight_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][2], Rect(60, 65, 50, 20) )
	.string_("front weight").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Knob.new(~sequencer_type_comp_views[index][2], Rect(65, 25, 40, 40) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_srm_key(index, \frontWeight, (knob.value*100.99).floor);
	});
});
~srm_bl001_note_probability_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][2], Rect(110, 65, 50, 20) )
	.string_("note probability").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Knob.new(~sequencer_type_comp_views[index][2], Rect(115, 25, 40, 40) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_srm_key(index, \noteProbability, (knob.value*100.99).floor);
	});
});
~srm_bl001_accent_probabilty_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][2], Rect(165, 65, 50, 20) )
	.string_("accent probabilty").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Knob.new(~sequencer_type_comp_views[index][2], Rect(170, 25, 40, 40) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_srm_key(index, \accentProbability, (knob.value*100.99).floor);
	});
});
~srm_bl001_accent_intensity_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][2], Rect(215, 65, 50, 20) )
	.string_("accent intensity").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Knob.new(~sequencer_type_comp_views[index][2], Rect(220, 25, 40, 40) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_srm_key(index, \accentIntensity, (knob.value*100.99).floor);
	});
});
~srm_bl001_slide_probability_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][2], Rect(270, 65, 50, 20) )
	.string_("slide probability").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
	Knob.new(~sequencer_type_comp_views[index][2], Rect(275, 25, 40, 40) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_srm_key(index, \slideProbability, (knob.value*100.99).floor);
	});
});

~sting_density_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][3], Rect(70, 70, 60, 20) )
	.string_("density").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sequencer_type_comp_views[index][3], Rect(70, 20, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_sting64_performable_density(index, (knob.value*63.99).floor);
	});
});
~sting_type_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][3], Rect(135, 70, 60, 20) )
	.string_("type").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sequencer_type_comp_views[index][3], Rect(135, 20, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_sting64_pitch_density(index, (knob.value*63.99).floor);
	});
});
~sting_mutation_knobs = 6.collect({
	|index|
	StaticText(~sequencer_type_comp_views[index][3], Rect(200, 70, 60, 20) )
	.string_("mutation").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sequencer_type_comp_views[index][3], Rect(200, 20, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		~groovebox.set_mutation_chance(index, knob.value);
	});
});

// comp views for synths
~synth_comp_views = 6.collect({
	|index|
	CompositeView(~comp_view_global[1], Rect(0, 0, 370, 195)).background_(
		Color.grey(0.3)
	).visible_(false)
});
~synth_type_label = 6.collect({
	|index|
	StaticText(~synth_comp_views[index], Rect(10, 5, 20, 20) )
	.string_("type").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
});
~synth_indices = 0!6;
~synth_type_buttons = 6.collect({
	|index|
	8.collect({
		|index2|
		Button(~synth_comp_views[index], Rect(10, 25+(index2*20), 20, 15) ).action_({
			// todo: make engine use correct synth
			~synth_type_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~synth_type_comp_views[index][index2].visible = true;
			~synth_indices[index] = index2;
		});
	})
});
~synth_type_comp_views = 6.collect({
	|index|
	8.collect({
		|index2|
		CompositeView(~synth_comp_views[index], Rect(40, 0, 330, 195)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});

~anushri_comp_views = 6.collect({
	|index|
	4.collect({
		|index2|
		CompositeView(~synth_type_comp_views[index][0], Rect(0, 30, 330, 165)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});
~anushri_page_buttons = 6.collect({
	|index|
	4.collect({
		|index2|
		Button(~synth_type_comp_views[index][0], Rect(45+(60*index2), 10, 50, 10)).action_({
			~anushri_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~anushri_comp_views[index][index2].visible_(true);
		});
	})
});
~anushri_dicts = 6.collect({
	|index|
	Dictionary.newFrom([
		\portamento, 0,
		\fm_on, 0,
		\fm_index, 0,
		\pw, 0.5,
		\sync_on, 0,
		\sync, 0,
		\vco_pitch, 0,
		\vco_balance, 0.5,
		\sub_oct, 0.5,
		\sub_amp, 1,
		\vca_attack, 0,
		\vca_decay, 0.5,
		\vca_sustain, 0.5,
		\vca_release,0.5,
		\filter_freq, 0.3,
		\filter_res, 0.5,
		\filter_env_amount, 0.5,
		\fuzz_on, 0,
		\fuzz_drive, 0,
		\vcf_attack, 0,
		\vcf_decay, 0.5,
		\vcf_sustain, 0.5,
		\vcf_release, 0.5,
		\mod_attack, 0,
		\mod_decay, 0.5,
		\lfo_rate, 0.5,
		\lfo_shape, 0,
		\mod_balance, 0,
		\freq_amount, 0,
		\pwm_amount, 0,
		\sync_amount, 0,
		\ffreq_amount, 0,
	]);
});
~anushri_macro_knobs1 = 6.collect({
	|index|
	StaticText(~anushri_comp_views[index][0], Rect(10, 95, 60, 20) )
	.string_("macro 1").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~anushri_comp_views[index][0], Rect(10, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~anushri_macro_knobs2 = 6.collect({
	|index|
	StaticText(~anushri_comp_views[index][0], Rect(70, 95, 60, 20) )
	.string_("macro 2").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~anushri_comp_views[index][0], Rect(70, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~anushri_macro_knobs3 = 6.collect({
	|index|
	StaticText(~anushri_comp_views[index][0], Rect(130, 95, 60, 20) )
	.string_("macro 3").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~anushri_comp_views[index][0], Rect(130, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~anushri_macro_knobs4 = 6.collect({
	|index|
	StaticText(~anushri_comp_views[index][0], Rect(190, 95, 60, 20) )
	.string_("macro 4").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~anushri_comp_views[index][0], Rect(190, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~anushri_regen_buttons = 6.collect({
	|index|
	StaticText(~anushri_comp_views[index][0], Rect(250, 95, 60, 20) )
	.string_("regen").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Button(~anushri_comp_views[index][0], Rect(255, 45, 50, 50) ).action_({
		// todo: generate a new patch for the synth
	});
});
~anushri_page1_knobs = 6.collect({
	|index|
	[
		[ "portamento", "", "fm on", "fm index" ],
		[ "pulse width", "", "sync on", "sync amount" ],
		[ "vco pitch", "vco balance", "sub octave", "sub amp" ],
		[ "vca attack", "vca decay", "vca sustain", "vca release" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~anushri_comp_views[index][1], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~anushri_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \portamento, nil, \fm_on, \fm_index ],
						[ \pw, nil, \sync_on, \sync ],
						[ \vco_pitch, \vco_balance, \sub_oct, \sub_amp ],
						[ \vca_attack, \vca_decay, \vca_sustain, \vca_release ],
					].at(index2).at(index3);
					~anushri_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0, nil, 0, 0, ],
					[ 0.5, nil, 0, 0, ],
					[ 0, 0.5, 0.5, 1, ],
					[ 0, 0.5, 0.5, 0.5, ],
				].at(index2).at(index3));
			});
		});
	});
});
~anushri_page2_knobs = 6.collect({
	|index|
	[
		[ "filter freq", "filter res", "filter env", "" ],
		[ "fuzz on", "fuzz drive", "", "" ],
		[ "", "", "", "" ],
		[ "vcf attack", "vcf decay", "vcf sustain", "vcf release" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~anushri_comp_views[index][2], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~anushri_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \filter_freq, \filter_res, \filter_env_amount, nil ],
						[ \fuzz_on, \fuzz_drive, nil, nil ],
						[ nil, nil, nil, nil ],
						[ \vcf_attack, \vcf_decay, \vcf_sustain, \vcf_release ],
					].at(index2).at(index3);
					~anushri_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0.3, 0.5, 0.5, nil, ],
					[ 0, 0, nil, nil, ],
					[ nil, nil, nil, nil, ],
					[ 0, 0.5, 0.5, 0.5, ],
				].at(index2).at(index3));
			});
		});
	});
});
~anushri_page3_knobs = 6.collect({
	|index|
	[
		[ "mod attack", "mod decay", "", "" ],
		[ "lfo rate", "lfo shape", "", "mod balance" ],
		[ "", "", "", "" ],
		[ "freq mod", "pwm mod", "sync mod", "f. freq mod" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~anushri_comp_views[index][3], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~anushri_comp_views[index][3], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \mod_attack, \mod_decay, nil, nil ],
						[ \lfo_rate, \lfo_shape, nil, \mod_balance ],
						[ nil, nil, nil, nil ],
						[ \freq_amount, \pwm_amount, \sync_amount, \ffreq_amount ],
					].at(index2).at(index3);
					~anushri_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0, 0.5, nil, nil, ],
					[ 0.5, 0, nil, 0, ],
					[ nil, nil, nil, nil, ],
					[ 0, 0, 0, 0, ],
				].at(index2).at(index3));
			});
		});
	});
});

~sh101_comp_views = 6.collect({
	|index|
	3.collect({
		|index2|
		CompositeView(~synth_type_comp_views[index][1], Rect(0, 30, 330, 165)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});
~sh101_page_buttons = 6.collect({
	|index|
	3.collect({
		|index2|
		Button(~synth_type_comp_views[index][1], Rect(75+(60*index2), 10, 50, 10)).action_({
			~sh101_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~sh101_comp_views[index][index2].visible_(true);
		});
	})
});
~sh101_dicts = 6.collect({
	|index|
	Dictionary.newFrom([
		\portamento, 0,
		\vco_pitch, 0,
		\vco_balance, 0.5,
		\sub_oct, 0.5,
		\sub_amp, 1,
		\noise_amp, 0,
		\pw, 0.5,
		\env_attack, 0,
		\env_decay, 0.5,
		\env_sustain, 0.5,
		\env_release,0.5,
		\filter_freq, 0.3,
		\filter_res, 0.5,
		\filter_env_amount, 0.5,
		\lfo_rate, 0.5,
		\freq_amount, 0,
		\pwm_amount, 0,
		\ffreq_amount, 0,
	]);
});
~sh101_macro_knobs1 = 6.collect({
	|index|
	StaticText(~sh101_comp_views[index][0], Rect(10, 95, 60, 20) )
	.string_("macro 1").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sh101_comp_views[index][0], Rect(10, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~sh101_macro_knobs2 = 6.collect({
	|index|
	StaticText(~sh101_comp_views[index][0], Rect(70, 95, 60, 20) )
	.string_("macro 2").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sh101_comp_views[index][0], Rect(70, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~sh101_macro_knobs3 = 6.collect({
	|index|
	StaticText(~sh101_comp_views[index][0], Rect(130, 95, 60, 20) )
	.string_("macro 3").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sh101_comp_views[index][0], Rect(130, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~sh101_macro_knobs4 = 6.collect({
	|index|
	StaticText(~sh101_comp_views[index][0], Rect(190, 95, 60, 20) )
	.string_("macro 4").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sh101_comp_views[index][0], Rect(190, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~sh101_regen_buttons = 6.collect({
	|index|
	StaticText(~sh101_comp_views[index][0], Rect(250, 95, 60, 20) )
	.string_("regen").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Button(~sh101_comp_views[index][0], Rect(255, 45, 50, 50) ).action_({
		// todo: generate a new patch for the synth
	});
});
~sh101_page1_knobs = 6.collect({
	|index|
	[
		[ "portamento", "", "", "" ],
		[ "pulse width", "", "", "noise amp" ],
		[ "vco pitch", "vco balance", "sub octave", "sub amp" ],
		[ "filter freq", "filter res", "filter env", "" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~sh101_comp_views[index][1], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~sh101_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \portamento, nil, nil, nil ],
						[ \pw, nil, nil, \noise_amp ],
						[ \vco_pitch, \vco_balance, \sub_oct, \sub_amp ],
						[ \filter_freq, \filter_res, \filter_env_amount, nil ],
					].at(index2).at(index3);
					~sh101_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0, nil, nil, nil, ],
					[ 0.5, nil, nil, 0, ],
					[ 0, 0.5, 0.5, 1, ],
					[ 0.3, 0.5, 0.5, nil, ],
				].at(index2).at(index3));
			});
		});
	});
});
~sh101_page2_knobs = 6.collect({
	|index|
	[
		[ "env attack", "env decay", "env sustain", "env release" ],
		[ "", "", "", "" ],
		[ "lfo rate", "", "", "" ],
		[ "freq mod", "pwm mod", "f. freq mod", "" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~sh101_comp_views[index][2], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~sh101_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \env_attack, \env_decay, \env_sustain, \env_release ],
						[ nil, nil, nil, nil ],
						[ \lfo_rate, nil, nil, nil ],
						[ \freq_amount, \pwm_amount, \ffreq_amount, nil ],
					].at(index2).at(index3);
					~sh101_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0, 0.5, 0.5, 0.5, ],
					[ nil, nil, nil, nil, ],
					[ 0.5, nil, nil, nil, ],
					[ 0, 0, 0, nil, ],
				].at(index2).at(index3));
			});
		});
	});
});

~buchla_comp_views = 6.collect({
	|index|
	2.collect({
		|index2|
		CompositeView(~synth_type_comp_views[index][2], Rect(0, 30, 330, 165)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});
~buchla_page_buttons = 6.collect({
	|index|
	2.collect({
		|index2|
		Button(~synth_type_comp_views[index][2], Rect(105+(60*index2), 10, 50, 10)).action_({
			~buchla_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~buchla_comp_views[index][index2].visible_(true);
		});
	})
});
~buchla_dicts = 6.collect({
	|index|
	Dictionary.newFrom([
		\portamento, 0,
		\mod_rat, 0,
		\car_rat, 0,
		\fb, 0,
		\fm_index, 0,
		\env_mod, 0,
		\bend, 0.5,
		\attack, 0,
		\decay, 0.5,
		\f_env_min, 0,
		\f_env_max, 1,
		\folds, 0,
		\env_fold, 0,
		\clip, 0,
	]);
});
~buchla_macro_knobs1 = 6.collect({
	|index|
	StaticText(~buchla_comp_views[index][0], Rect(10, 95, 60, 20) )
	.string_("macro 1").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~buchla_comp_views[index][0], Rect(10, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~buchla_macro_knobs2 = 6.collect({
	|index|
	StaticText(~buchla_comp_views[index][0], Rect(70, 95, 60, 20) )
	.string_("macro 2").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~buchla_comp_views[index][0], Rect(70, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~buchla_macro_knobs3 = 6.collect({
	|index|
	StaticText(~buchla_comp_views[index][0], Rect(130, 95, 60, 20) )
	.string_("macro 3").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~buchla_comp_views[index][0], Rect(130, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~buchla_macro_knobs4 = 6.collect({
	|index|
	StaticText(~buchla_comp_views[index][0], Rect(190, 95, 60, 20) )
	.string_("macro 4").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~buchla_comp_views[index][0], Rect(190, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~buchla_regen_buttons = 6.collect({
	|index|
	StaticText(~buchla_comp_views[index][0], Rect(250, 95, 60, 20) )
	.string_("regen").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Button(~buchla_comp_views[index][0], Rect(255, 45, 50, 50) ).action_({
		// todo: generate a new patch for the synth
	});
});
~buchla_page1_knobs = 6.collect({
	|index|
	[
		[ "portamento", "mod ratio", "car ratio", "feedback" ],
		[ "fm index", "env mod", "", "bend" ],
		[ "env attack", "env decay", "filter min", "filter max" ],
		[ "folds", "env fold", "", "clip" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~buchla_comp_views[index][1], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~buchla_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \portamento, \mod_rat, \car_rat, \fb ],
						[ \fm_index, \env_mod, nil, \bend ],
						[ \attack, \decay, \f_env_min, \f_env_max ],
						[ \folds, \env_fold, nil, \clip ],
					].at(index2).at(index3);
					~buchla_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0, 0, 0, 0, ],
					[ 0, 0, nil, 0.5, ],
					[ 0, 0.5, 0, 1, ],
					[ 0, 0, nil, 0, ],
				].at(index2).at(index3));
			});
		});
	});
});

~juno6_comp_views = 6.collect({
	|index|
	3.collect({
		|index2|
		CompositeView(~synth_type_comp_views[index][3], Rect(0, 30, 330, 165)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});
~juno6_page_buttons = 6.collect({
	|index|
	3.collect({
		|index2|
		Button(~synth_type_comp_views[index][3], Rect(75+(60*index2), 10, 50, 10)).action_({
			~juno6_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~juno6_comp_views[index][index2].visible_(true);
		});
	})
});
~juno6_dicts = 6.collect({
	|index|
	Dictionary.newFrom([
		\vco_pitch, 0,
		\vco_balance, 0.5,
		\sub_oct, 0.5,
		\sub_amp, 1,
		\noise_amp, 0,
		\pw, 0.5,
		\env_attack, 0,
		\env_decay, 0.5,
		\env_sustain, 0.5,
		\env_release,0.5,
		\filter_freq, 0.3,
		\filter_res, 0.5,
		\filter_env_amount, 0.5,
		\hpf_freq, 0,
		\lfo_rate, 0.5,
		\freq_amount, 0,
		\pwm_amount, 0,
		\ffreq_amount, 0,
		\chorus, 0,
	]);
});
~juno6_macro_knobs1 = 6.collect({
	|index|
	StaticText(~juno6_comp_views[index][0], Rect(10, 95, 60, 20) )
	.string_("macro 1").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~juno6_comp_views[index][0], Rect(10, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~juno6_macro_knobs2 = 6.collect({
	|index|
	StaticText(~juno6_comp_views[index][0], Rect(70, 95, 60, 20) )
	.string_("macro 2").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~juno6_comp_views[index][0], Rect(70, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~juno6_macro_knobs3 = 6.collect({
	|index|
	StaticText(~juno6_comp_views[index][0], Rect(130, 95, 60, 20) )
	.string_("macro 3").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~juno6_comp_views[index][0], Rect(130, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~juno6_macro_knobs4 = 6.collect({
	|index|
	StaticText(~juno6_comp_views[index][0], Rect(190, 95, 60, 20) )
	.string_("macro 4").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~juno6_comp_views[index][0], Rect(190, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~juno6_regen_buttons = 6.collect({
	|index|
	StaticText(~juno6_comp_views[index][0], Rect(250, 95, 60, 20) )
	.string_("regen").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Button(~juno6_comp_views[index][0], Rect(255, 45, 50, 50) ).action_({
		// todo: generate a new patch for the synth
	});
});
~juno6_page1_knobs = 6.collect({
	|index|
	[
		[ "", "", "", "chorus" ],
		[ "pulse width", "", "", "noise amp" ],
		[ "vco pitch", "vco balance", "sub octave", "sub amp" ],
		[ "filter freq", "filter res", "filter env", "hpf freq" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~juno6_comp_views[index][1], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~juno6_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ nil, nil, nil, \chorus ],
						[ \pw, nil, nil, \noise_amp ],
						[ \vco_pitch, \vco_balance, \sub_oct, \sub_amp ],
						[ \filter_freq, \filter_res, \filter_env_amount, \hpf_freq ],
					].at(index2).at(index3);
					~juno6_dicts[index][symbol] = knob.value;
				}).value_([
					[ nil, nil, nil, 0, ],
					[ 0.5, nil, nil, 0, ],
					[ 0, 0.5, 0.5, 1, ],
					[ 0.3, 0.5, 0.5, 0, ],
				].at(index2).at(index3));
			});
		});
	});
});
~juno6_page2_knobs = 6.collect({
	|index|
	[
		[ "env attack", "env decay", "env sustain", "env release" ],
		[ "", "", "", "" ],
		[ "lfo rate", "", "", "" ],
		[ "freq mod", "pwm mod", "f. freq mod", "" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~juno6_comp_views[index][2], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~juno6_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \env_attack, \env_decay, \env_sustain, \env_release ],
						[ nil, nil, nil, nil ],
						[ \lfo_rate, nil, nil, nil ],
						[ \freq_amount, \pwm_amount, \ffreq_amount, nil ],
					].at(index2).at(index3);
					~juno6_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0, 0.5, 0.5, 0.5, ],
					[ nil, nil, nil, nil, ],
					[ 0.5, nil, nil, nil, ],
					[ 0, 0, 0, nil, ],
				].at(index2).at(index3));
			});
		});
	});
});

~alpha_juno_comp_views = 6.collect({
	|index|
	3.collect({
		|index2|
		CompositeView(~synth_type_comp_views[index][4], Rect(0, 30, 330, 165)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});
~alpha_juno_page_buttons = 6.collect({
	|index|
	3.collect({
		|index2|
		Button(~synth_type_comp_views[index][4], Rect(75+(60*index2), 10, 50, 10)).action_({
			~alpha_juno_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~alpha_juno_comp_views[index][index2].visible_(true);
		});
	})
});
~alpha_juno_dicts = 6.collect({
	|index|
	Dictionary.newFrom([
		\dco_pitch, 0,
		\dco_balance, 0.5,
		\saw_wave, 0,
		\pulse_wave, 0,
		\sub_wave, 0,
		\sub_oct, 0.5,
		\sub_amp, 1,
		\noise_amp, 0,
		\pw, 0.5,
		\env_attack, 0,
		\env_decay, 0.5,
		\env_sustain, 0.5,
		\env_release,0.5,
		\filter_freq, 0.3,
		\filter_res, 0.5,
		\filter_env_amount, 0.5,
		\hpf_freq, 0,
		\lfo_rate, 0.5,
		\pwm_speed, 0.5,
		\freq_amount, 0,
		\pwm_amount, 0,
		\ffreq_amount, 0,
		\chorus, 0,
	]);
});
~alpha_juno_macro_knobs1 = 6.collect({
	|index|
	StaticText(~alpha_juno_comp_views[index][0], Rect(10, 95, 60, 20) )
	.string_("macro 1").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~alpha_juno_comp_views[index][0], Rect(10, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~alpha_juno_macro_knobs2 = 6.collect({
	|index|
	StaticText(~alpha_juno_comp_views[index][0], Rect(70, 95, 60, 20) )
	.string_("macro 2").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~alpha_juno_comp_views[index][0], Rect(70, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~alpha_juno_macro_knobs3 = 6.collect({
	|index|
	StaticText(~alpha_juno_comp_views[index][0], Rect(130, 95, 60, 20) )
	.string_("macro 3").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~alpha_juno_comp_views[index][0], Rect(130, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~alpha_juno_macro_knobs4 = 6.collect({
	|index|
	StaticText(~alpha_juno_comp_views[index][0], Rect(190, 95, 60, 20) )
	.string_("macro 4").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~alpha_juno_comp_views[index][0], Rect(190, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~alpha_juno_regen_buttons = 6.collect({
	|index|
	StaticText(~alpha_juno_comp_views[index][0], Rect(250, 95, 60, 20) )
	.string_("regen").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Button(~alpha_juno_comp_views[index][0], Rect(255, 45, 50, 50) ).action_({
		// todo: generate a new patch for the synth
	});
});
~alpha_juno_page1_knobs = 6.collect({
	|index|
	[
		[ "saw wave", "pulse wave", "sub wave", "chorus" ],
		[ "pulse width", "", "", "noise amp" ],
		[ "dco pitch", "dco balance", "sub octave", "sub amp" ],
		[ "filter freq", "filter res", "filter env", "hpf freq" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~alpha_juno_comp_views[index][1], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~alpha_juno_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \saw_wave, \pulse_wave, \sub_wave, \chorus ],
						[ \pw, nil, nil, \noise_amp ],
						[ \dco_pitch, \dco_balance, \sub_oct, \sub_amp ],
						[ \filter_freq, \filter_res, \filter_env_amount, \hpf_freq ],
					].at(index2).at(index3);
					~alpha_juno_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0, 0, 0, 0, ],
					[ 0.5, nil, nil, 0, ],
					[ 0, 0.5, 0.5, 1, ],
					[ 0.3, 0.5, 0.5, 0, ],
				].at(index2).at(index3));
			});
		});
	});
});
~alpha_juno_page2_knobs = 6.collect({
	|index|
	[
		[ "env attack", "env decay", "env sustain", "env release" ],
		[ "", "", "", "" ],
		[ "lfo rate", "", "pwm speed", "" ],
		[ "freq mod", "f. freq mod", "pwm mod", "" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~alpha_juno_comp_views[index][2], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~alpha_juno_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \env_attack, \env_decay, \env_sustain, \env_release ],
						[ nil, nil, nil, nil ],
						[ \lfo_rate, nil, \pwm_speed, nil ],
						[ \freq_amount, \ffreq_amount, \pwm_amount, nil ],
					].at(index2).at(index3);
					~alpha_juno_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0, 0.5, 0.5, 0.5, ],
					[ nil, nil, nil, nil, ],
					[ 0.5, nil, 0.5, nil, ],
					[ 0, 0, 0, nil, ],
				].at(index2).at(index3));
			});
		});
	});
});

~megafm_comp_views = 6.collect({
	|index|
	3.collect({
		|index2|
		CompositeView(~synth_type_comp_views[index][5], Rect(0, 30, 330, 165)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});
~megafm_page_buttons = 6.collect({
	|index|
	3.collect({
		|index2|
		Button(~synth_type_comp_views[index][5], Rect(75+(60*index2), 10, 50, 10)).action_({
			~megafm_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~megafm_comp_views[index][index2].visible_(true);
		});
	})
});
~megafm_dicts = 6.collect({
	|index|
	Dictionary.newFrom([
		\op1_lvl, 0.5,
		\op2_lvl, 0.5,
		\op3_lvl, 0.5,
		\op4_lvl, 1,
		\algorithm, 0,
		\fb, 0,
		\op1_rat, 0,
		\op2_rat, 0,
		\op3_rat, 0,
		\op4_rat, 0,
		\op1_det, 0,
		\op2_det, 0,
		\op3_det, 0,
		\op4_det, 0,
		\car_at, 0.5,
		\car_dec, 0.5,
		\car_sl, 0.5,
		\car_sr, 0.5,
		\car_rel, 0.5,
		\mod_at, 0.5,
		\mod_dec, 0.5,
		\mod_sl, 0.5,
		\mod_sr, 0.5,
		\mod_rel, 0.5,
	]);
});
~megafm_macro_knobs1 = 6.collect({
	|index|
	StaticText(~megafm_comp_views[index][0], Rect(10, 95, 60, 20) )
	.string_("macro 1").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~megafm_comp_views[index][0], Rect(10, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~megafm_macro_knobs2 = 6.collect({
	|index|
	StaticText(~megafm_comp_views[index][0], Rect(70, 95, 60, 20) )
	.string_("macro 2").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~megafm_comp_views[index][0], Rect(70, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~megafm_macro_knobs3 = 6.collect({
	|index|
	StaticText(~megafm_comp_views[index][0], Rect(130, 95, 60, 20) )
	.string_("macro 3").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~megafm_comp_views[index][0], Rect(130, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~megafm_macro_knobs4 = 6.collect({
	|index|
	StaticText(~megafm_comp_views[index][0], Rect(190, 95, 60, 20) )
	.string_("macro 4").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~megafm_comp_views[index][0], Rect(190, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~megafm_regen_buttons = 6.collect({
	|index|
	StaticText(~megafm_comp_views[index][0], Rect(250, 95, 60, 20) )
	.string_("regen").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Button(~megafm_comp_views[index][0], Rect(255, 45, 50, 50) ).action_({
		// todo: generate a new patch for the synth
	});
});
~megafm_page1_knobs = 6.collect({
	|index|
	[
		[ "op 1 lvl", "op 2 lvl", "op 3 lvl", "op 4 lvl" ],
		[ "algorithm", "", "", "feedback" ],
		[ "op 1 rat", "op 2 rat", "op 3 rat", "op 4 rat" ],
		[ "op 1 det", "op 2 det", "op 3 det", "op 4 det" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~megafm_comp_views[index][1], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~megafm_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \op1_lvl, \op2_lvl, \op3_lvl, \op4_lvl ],
						[ \algorithm, nil, nil, \fb ],
						[ \op1_rat, \op2_rat, \op3_rat, \op4_rat ],
						[ \op1_det, \op2_det, \op3_det, \op4_det ],
					].at(index2).at(index3);
					~megafm_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0.5, 0.5, 0.5, 1 ],
					[ 0, nil, nil, 0 ],
					[ 0, 0, 0, 0 ],
					[ 0, 0, 0, 0 ],
				].at(index2).at(index3));
			});
		});
	});
});
~megafm_page2_knobs = 6.collect({
	|index|
	[
		[ "car attack", "car decay", "", "" ],
		[ "car sus lvl", "car sus rate", "car release", "" ],
		[ "mod attack", "mod decay", "", "" ],
		[ "mod sus lvl", "mod sus rate", "mod release", "" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~megafm_comp_views[index][2], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~megafm_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \car_at, \car_dec, nil, nil ],
						[ \car_sl, \car_sr, \car_rel, nil ],
						[ \mod_at, \mod_dec, nil, nil ],
						[ \mod_sl, \mod_sr, \mod_rel, nil ],
					].at(index2).at(index3);
					~megafm_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0.5, 0.5, nil, nil ],
					[ 0.5, 0.5, 0.5, nil ],
					[ 0.5, 0.5, nil, nil ],
					[ 0.5, 0.5, 0.5, nil ],
				].at(index2).at(index3));
			});
		});
	});
});

~modal_comp_views = 6.collect({
	|index|
	2.collect({
		|index2|
		CompositeView(~synth_type_comp_views[index][6], Rect(0, 30, 330, 165)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});
~modal_page_buttons = 6.collect({
	|index|
	2.collect({
		|index2|
		Button(~synth_type_comp_views[index][6], Rect(105+(60*index2), 10, 50, 10)).action_({
			~modal_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~modal_comp_views[index][index2].visible_(true);
		});
	})
});
~modal_dicts = 6.collect({
	|index|
	Dictionary.newFrom([
		\warp1, 0.5,
		\warp2, 0.5,
		\tilt, 0.5,
		\shape1, 0,
		\shape2, 0,
		\shape_depth, 0,
		\impulse_balance, 0,
		\ffilter, 0.5,
		\attack, 0.5,
		\release, 0.5,
		\resonance, 0.5,
	]);
});
~modal_macro_knobs1 = 6.collect({
	|index|
	StaticText(~modal_comp_views[index][0], Rect(10, 95, 60, 20) )
	.string_("macro 1").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~modal_comp_views[index][0], Rect(10, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~modal_macro_knobs2 = 6.collect({
	|index|
	StaticText(~modal_comp_views[index][0], Rect(70, 95, 60, 20) )
	.string_("macro 2").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~modal_comp_views[index][0], Rect(70, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~modal_macro_knobs3 = 6.collect({
	|index|
	StaticText(~modal_comp_views[index][0], Rect(130, 95, 60, 20) )
	.string_("macro 3").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~modal_comp_views[index][0], Rect(130, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~modal_macro_knobs4 = 6.collect({
	|index|
	StaticText(~modal_comp_views[index][0], Rect(190, 95, 60, 20) )
	.string_("macro 4").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~modal_comp_views[index][0], Rect(190, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~modal_regen_buttons = 6.collect({
	|index|
	StaticText(~modal_comp_views[index][0], Rect(250, 95, 60, 20) )
	.string_("regen").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Button(~modal_comp_views[index][0], Rect(255, 45, 50, 50) ).action_({
		// todo: generate a new patch for the synth
	});
});
~modal_page1_knobs = 6.collect({
	|index|
	[
		[ "warp 1", "warp 2", "", "tilt" ],
		[ "shape 1", "shape 2", "shape depth", "" ],
		[ "imp. bal.", "filter", "attack", "release" ],
		[ "resonance", "", "", "" ],
	].do({
		|list, index2|
		list.do({
			|item, index3|
			StaticText(~modal_comp_views[index][1], Rect(45+(index3*60), 25+(index2*40), 50, 10) )
			.string_(item).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8) );
			if(item.size > 0, {
				Knob.new(~modal_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
				.mode_(\vert).action_({
					|knob|
					// todo: set values
					var symbol;
					symbol = [
						[ \warp1, \warp2, nil, \tilt ],
						[ \shape1, \shape2, \shape_depth, nil ],
						[ \impulse_balance, \ffilter, \attack, \release ],
						[ \resonance, nil, nil, nil ],
					].at(index2).at(index3);
					~modal_dicts[index][symbol] = knob.value;
				}).value_([
					[ 0.5, 0.5, nil, 0.5, ],
					[ 0, 0, 0, nil, ],
					[ 0, 0.5, 0.5, 0.5, ],
					[ 0.5, nil, nil, nil, ],
				].at(index2).at(index3));
			});
		});
	});
});

~sampler_comp_views = 6.collect({
	|index|
	2.collect({
		|index2|
		CompositeView(~synth_type_comp_views[index][7], Rect(0, 30, 330, 165)).background_(
			Color.grey(0.3)
		).visible_(false)
	})
});
~sampler_page_buttons = 6.collect({
	|index|
	2.collect({
		|index2|
		Button(~synth_type_comp_views[index][7], Rect(105+(60*index2), 10, 50, 10)).action_({
			~sampler_comp_views[index].do({
				|cv, ind|
				cv.visible = false;
			});
			~sampler_comp_views[index][index2].visible_(true);
		});
	})
});
~sampler_macro_knobs1 = 6.collect({
	|index|
	StaticText(~sampler_comp_views[index][0], Rect(10, 95, 60, 20) )
	.string_("macro 1").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sampler_comp_views[index][0], Rect(10, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~sampler_macro_knobs2 = 6.collect({
	|index|
	StaticText(~sampler_comp_views[index][0], Rect(70, 95, 60, 20) )
	.string_("macro 2").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sampler_comp_views[index][0], Rect(70, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~sampler_macro_knobs3 = 6.collect({
	|index|
	StaticText(~sampler_comp_views[index][0], Rect(130, 95, 60, 20) )
	.string_("macro 3").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sampler_comp_views[index][0], Rect(130, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~sampler_macro_knobs4 = 6.collect({
	|index|
	StaticText(~sampler_comp_views[index][0], Rect(190, 95, 60, 20) )
	.string_("macro 4").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~sampler_comp_views[index][0], Rect(190, 45, 60, 50) ).mode_(\vert)
	.action_({
		|knob|
		// todo: set values
	});
});
~sampler_regen_buttons = 6.collect({
	|index|
	StaticText(~sampler_comp_views[index][0], Rect(250, 95, 60, 20) )
	.string_("regen").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Button(~sampler_comp_views[index][0], Rect(255, 45, 50, 50) ).action_({
		// todo: generate a new patch for the synth
	});
});

// effect send params

// initialization
~track_buttons[0].valueAction = 1;
6.do({
	|index|
	~sequencer_type_comp_views[index][0].visible = true;
});

