
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
	hor_inc = 220/8;
	Slider.new(~comp_view_global[3], Rect(10 + (hor_inc*(index+0.33)), 105, hor_inc/3, 80));
});

~mixer_knobs = 8.collect({
	|index|
	var hor_inc;
	hor_inc = 220/8;
	3.collect({
		|index2|
		Knob.new(~comp_view_global[3], Rect(10 + (hor_inc*(index+0.1667)), 10 + (30*index2), hor_inc/1.5, hor_inc/1.5)).mode_(\vert);
	});
});

~mixer_knobs.do({
	|list, index|
	list[2].value = 0.5;
});

8.do({
	|index|
	~mixer_sliders[index].action_({
		~mixer.set(
			[\lvl1, \lvl2, \lvl3, \lvl4, \lvl5, \lvl6, \lvl7, \lvl8].at(index),
			~mixer_sliders[index].value.linlin(0, 1, -60, 0).dbamp;
		);
		if(~mixer_sliders[index].value == 0, {
			~mixer.set(
			[\lvl1, \lvl2, \lvl3, \lvl4, \lvl5, \lvl6, \lvl7, \lvl8].at(index),
			0;
		);
		});
	});
	~mixer_knobs[index].do({
		|knob, index2|
		knob.action_({
			|kn|
			var symb;
			symb = [
				[\rv_s1, \rv_s2, \rv_s3, \rv_s4, \rv_s5, \rv_s6, \rv_s7, \rv_s8].at(index),
				[\ec_s1, \ec_s2, \ec_s3, \ec_s4, \ec_s5, \ec_s6, \ec_s7, \ec_s8].at(index),
				[\filt1, \filt2, \filt3, \filt4, \filt5, \filt6, \filt7, \filt8].at(index)
			].at(index2);
			~mixer.set(
				symb, [kn.value.linlin(0, 1, -60, 0).dbamp,
					kn.value.linlin(0, 1, -60, 0).dbamp,
					kn.value.linlin(0, 1, -1, 1)].at(index2)
			);
		});
	});
});

// effect params & global settings
~tempo_knob = Knob.new(~comp_view_global[3], Rect(240, 135, 30, 30)).mode_(\vert).action_({
	|knob|
	~bpm = knob.value.linlin(0, 1, 60, 180);
}).valueAction_(7.0/12);
~swing_knob = Knob.new(~comp_view_global[3], Rect(280, 135, 30, 30)).mode_(\vert).action_({
	|knob|
	~swing = knob.value.linlin(0, 1, 0.5, 0.9);
}).valueAction_(0.4);
~regen_button = Button.new(~comp_view_global[3], Rect(320, 135, 30, 30)).action_({
	~groovebox.regen_chords;
});
~tempo_swing_regen_labels = 3.collect({
	|index|
	StaticText.new(~comp_view_global[3], Rect(235 + (40*index), 170, 40, 10)).string_(
		["tempo", "swing", "regen"].at(index)
	).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
});
~echo_knobs = 3.collect({
	|index|
	StaticText.new(~comp_view_global[3], Rect(235 + (40*index), 110, 40, 10)).string_(
		["time", "feedb.", "wow fl."].at(index)
	).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~comp_view_global[3], Rect(240 + (40*index), 75, 30, 30)).mode_(\vert).action_({
		|knob|
		~mixer.set( [\echo_time, \echo_fb, \wow_flutter].at(index), knob.value);
	}).valueAction_([
		0.5,
		0,
		0.1
	].at(index));
});
~reverb_knobs = 3.collect({
	|index|
	StaticText.new(~comp_view_global[3], Rect(235 + (40*index), 50, 40, 10)).string_(
		["pr. del.", "spring", "darken"].at(index)
	).stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	Knob.new(~comp_view_global[3], Rect(240 + (40*index), 15, 30, 30)).mode_(\vert).action_({
		|knob|
		~mixer.set( [\predelay, \spring_amount, \darken].at(index), [
			knob.value,
			knob.value.linlin(0, 1, 0, 0.1),
			knob.value.linlin(0, 1, 0, -12)
		].at(index));
	}).valueAction_([
		0,
		0.65,
		0.5
	].at(index));
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
~randomize_anushri = {
	arg index;
	//~anushri_page1_knobs[index]["row"]["column"]
	~anushri_page1_knobs[index][0][0].valueAction_(1.0.rand);
	~anushri_page1_knobs[index][0][2].valueAction_([0, 1].wchoose([0.95, 0.05]));
	~anushri_page1_knobs[index][0][3].valueAction_(1.0.rand);
	~anushri_page1_knobs[index][1][0].valueAction_(0.9.rand + 0.05);
	~anushri_page1_knobs[index][1][2].valueAction_([0, 1].choose);
	~anushri_page1_knobs[index][1][3].valueAction_(0.67.rand + 0.33);
	~anushri_page1_knobs[index][2][0].valueAction_([0, 0, 0, 5/12, 7/12].choose);
	~anushri_page1_knobs[index][2][1].valueAction_(1.0.rand);
	~anushri_page1_knobs[index][2][2].valueAction_([0, 0.5, 1].wchoose([0.2, 0.4, 0.4]));
	~anushri_page1_knobs[index][2][3].valueAction_([1.0.rand, 0].wchoose([0.8, 0.2]));
	~anushri_page1_knobs[index][3][1].valueAction_(0.9.rand + 0.1);
	~anushri_page1_knobs[index][3][2].valueAction_(1.0.rand);
	~anushri_page1_knobs[index][3][3].valueAction_(0.9.rand + 0.1);

	~anushri_page2_knobs[index][0][0].valueAction_(1.0.rand);
	~anushri_page2_knobs[index][0][1].valueAction_(0.9.rand);
	~anushri_page2_knobs[index][0][2].valueAction_(1.0.rand);
	~anushri_page2_knobs[index][1][0].valueAction_([0, 1].choose);
	~anushri_page2_knobs[index][1][1].valueAction_(1.0.rand);
	~anushri_page2_knobs[index][3][1].valueAction_(0.9.rand + 0.1);
	~anushri_page2_knobs[index][3][2].valueAction_(1.0.rand);
	~anushri_page2_knobs[index][3][3].valueAction_(0.9.rand + 0.1);

	~anushri_page3_knobs[index][0][1].valueAction_(1.0.rand);
	~anushri_page3_knobs[index][1][0].valueAction_(1.0.rand);
	~anushri_page3_knobs[index][1][1].valueAction_(1.0.rand);
	~anushri_page3_knobs[index][1][3].valueAction_(1.0.rand);
	~anushri_page3_knobs[index][3][0].valueAction_(0);
	~anushri_page3_knobs[index][3][1].valueAction_(0);
	~anushri_page3_knobs[index][3][2].valueAction_(0);
	~anushri_page3_knobs[index][3][3].valueAction_(0);
	2.do({
		switch(4.rand,
			0, {
				if(1.0.rand > 0.9, {
					~anushri_page3_knobs[index][3][0].valueAction_(1.0.rand);
				});
			},
			1, {
				~anushri_page3_knobs[index][3][1].valueAction_(1.0.rand);
			},
			2, {
				~anushri_page3_knobs[index][3][2].valueAction_(1.0.rand);
			},
			3, {
				~anushri_page3_knobs[index][3][3].valueAction_(1.0.rand);
			}
		);
	});

	if([true, false].choose, {
		var val;
		val = 0.35.rand + 0.05;
		~anushri_page1_knobs[index][3][0].valueAction_(val);
		~anushri_page2_knobs[index][3][0].valueAction_(val);
		~anushri_page3_knobs[index][0][0].valueAction_(val);
	}, {
		~anushri_page1_knobs[index][3][0].valueAction_(0);
		~anushri_page2_knobs[index][3][0].valueAction_(0);
		~anushri_page3_knobs[index][0][0].valueAction_(0);
	});
};
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
		~randomize_anushri.value(index);
	});
});
~anushri_page1_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~anushri_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
});
~anushri_page2_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~anushri_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
});
~anushri_page3_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~anushri_comp_views[index][3], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
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
~randomize_sh101 = {
	arg index;
	//~anushri_page1_knobs[index]["row"]["column"]
	~sh101_page1_knobs[index][0][0].valueAction_(1.0.rand);
	~sh101_page1_knobs[index][1][0].valueAction_(0.9.rand + 0.05);
	~sh101_page1_knobs[index][1][3].valueAction_(1.0.rand);
	~sh101_page1_knobs[index][2][0].valueAction_([0, 0, 0, 5/12, 7/12].choose);
	~sh101_page1_knobs[index][2][1].valueAction_(1.0.rand);
	~sh101_page1_knobs[index][2][2].valueAction_([0, 0.5, 1].wchoose([0.2, 0.4, 0.4]));
	~sh101_page1_knobs[index][2][3].valueAction_([1.0.rand, 0].wchoose([0.8, 0.2]));
	~sh101_page1_knobs[index][3][0].valueAction_(1.0.rand);
	~sh101_page1_knobs[index][3][1].valueAction_(0.9.rand);
	~sh101_page1_knobs[index][3][2].valueAction_(1.0.rand);

	~sh101_page2_knobs[index][0][0].valueAction_([0, 0.35.rand + 0.05].choose);
	~sh101_page2_knobs[index][0][1].valueAction_(0.9.rand + 0.1);
	~sh101_page2_knobs[index][0][2].valueAction_(1.0.rand);
	~sh101_page2_knobs[index][0][3].valueAction_(0.9.rand + 0.1);
	~sh101_page2_knobs[index][2][0].valueAction_(1.0.rand);
	~sh101_page2_knobs[index][3][0].valueAction_(0);
	~sh101_page2_knobs[index][3][1].valueAction_(0);
	~sh101_page2_knobs[index][3][2].valueAction_(0);
	2.do({
		switch(3.rand,
			0, {
				if(1.0.rand > 0.9, {
					~sh101_page2_knobs[index][3][0].valueAction_(1.0.rand);
				});
			},
			1, {
				~sh101_page2_knobs[index][3][1].valueAction_(1.0.rand);
			},
			2, {
				~sh101_page2_knobs[index][3][2].valueAction_(1.0.rand);
			}
		);
	});
};
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
		~randomize_sh101.value(index);
	});
});
~sh101_page1_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~sh101_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
});
~sh101_page2_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~sh101_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
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
~randomize_buchla = {
	arg index;
	//~anushri_page1_knobs[index]["row"]["column"]
	~buchla_page1_knobs[index][0][0].valueAction_(1.0.rand);
	~buchla_page1_knobs[index][0][1].valueAction_(1.0.rand);
	~buchla_page1_knobs[index][0][2].valueAction_(1.0.rand);
	~buchla_page1_knobs[index][0][3].valueAction_(1.0.rand);
	~buchla_page1_knobs[index][1][0].valueAction_(0.3.rand);
	~buchla_page1_knobs[index][1][1].valueAction_(0.25.rand);
	~buchla_page1_knobs[index][1][3].valueAction_(1.0.rand);
	~buchla_page1_knobs[index][2][0].valueAction_([0, 0.35.rand + 0.05].choose);
	~buchla_page1_knobs[index][2][1].valueAction_(0.6.rand + 0.4);
	~buchla_page1_knobs[index][2][2].valueAction_(0.5.rand);
	~buchla_page1_knobs[index][2][3].valueAction_(0.5.rand + 0.5);
	~buchla_page1_knobs[index][3][0].valueAction_(0.4.rand);
	~buchla_page1_knobs[index][3][1].valueAction_(0.3.rand);
	~buchla_page1_knobs[index][3][3].valueAction_(1.0.rand);
};
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
		~randomize_buchla.value(index);
	});
});
~buchla_page1_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~buchla_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
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
~randomize_juno6 = {
	arg index;
	//~anushri_page1_knobs[index]["row"]["column"]
	~juno6_page1_knobs[index][0][3].valueAction_(1.0.rand);
	~juno6_page1_knobs[index][1][0].valueAction_(0.9.rand + 0.05);
	~juno6_page1_knobs[index][1][3].valueAction_(1.0.rand);
	~juno6_page1_knobs[index][2][0].valueAction_([0, 0, 0, 5/12, 7/12].choose);
	~juno6_page1_knobs[index][2][1].valueAction_(1.0.rand);
	~juno6_page1_knobs[index][2][2].valueAction_([0, 0.5, 1].wchoose([0.2, 0.4, 0.4]));
	~juno6_page1_knobs[index][2][3].valueAction_([1.0.rand, 0].wchoose([0.8, 0.2]));
	~juno6_page1_knobs[index][3][0].valueAction_(1.0.rand);
	~juno6_page1_knobs[index][3][1].valueAction_(0.9.rand);
	~juno6_page1_knobs[index][3][2].valueAction_(1.0.rand);

	~juno6_page2_knobs[index][0][0].valueAction_([0, 0.35.rand + 0.05].choose);
	~juno6_page2_knobs[index][0][1].valueAction_(0.9.rand + 0.1);
	~juno6_page2_knobs[index][0][2].valueAction_(1.0.rand);
	~juno6_page2_knobs[index][0][3].valueAction_(0.9.rand + 0.1);
	~juno6_page2_knobs[index][2][0].valueAction_(1.0.rand);
	~juno6_page2_knobs[index][3][0].valueAction_(0);
	~juno6_page2_knobs[index][3][1].valueAction_(0);
	~juno6_page2_knobs[index][3][2].valueAction_(0);
	2.do({
		switch(3.rand,
			0, {
				if(1.0.rand > 0.9, {
					~juno6_page2_knobs[index][3][0].valueAction_(1.0.rand);
				});
			},
			1, {
				~juno6_page2_knobs[index][3][1].valueAction_(1.0.rand);
			},
			2, {
				~juno6_page2_knobs[index][3][2].valueAction_(1.0.rand);
			}
		);
	});
};
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
		~randomize_juno6.value(index);
	});
});
~juno6_page1_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~juno6_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
});
~juno6_page2_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~juno6_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
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
~randomize_alpha_juno = {
	arg index;
	//~anushri_page1_knobs[index]["row"]["column"]
	~alpha_juno_page1_knobs[index][0][0].valueAction_(1.0.rand);
	~alpha_juno_page1_knobs[index][0][1].valueAction_(1.0.rand);
	~alpha_juno_page1_knobs[index][0][2].valueAction_(1.0.rand);
	~alpha_juno_page1_knobs[index][0][3].valueAction_(1.0.rand);
	~alpha_juno_page1_knobs[index][1][0].valueAction_(0.9.rand + 0.05);
	~alpha_juno_page1_knobs[index][1][3].valueAction_(1.0.rand);
	~alpha_juno_page1_knobs[index][2][0].valueAction_([0, 0, 0, 5/12, 7/12].choose);
	~alpha_juno_page1_knobs[index][2][1].valueAction_(1.0.rand);
	~alpha_juno_page1_knobs[index][2][2].valueAction_([0, 0.5, 1].wchoose([0.2, 0.4, 0.4]));
	~alpha_juno_page1_knobs[index][2][3].valueAction_([1.0.rand, 0].wchoose([0.8, 0.2]));
	~alpha_juno_page1_knobs[index][3][0].valueAction_(1.0.rand);
	~alpha_juno_page1_knobs[index][3][1].valueAction_(0.5.rand);
	~alpha_juno_page1_knobs[index][3][2].valueAction_(1.0.rand);
	~alpha_juno_page1_knobs[index][3][3].valueAction_(0.65.rand);

	~alpha_juno_page2_knobs[index][0][0].valueAction_([0, 0.35.rand + 0.05].choose);
	~alpha_juno_page2_knobs[index][0][1].valueAction_(0.9.rand + 0.1);
	~alpha_juno_page2_knobs[index][0][2].valueAction_(1.0.rand);
	~alpha_juno_page2_knobs[index][0][3].valueAction_(0.9.rand + 0.1);
	~alpha_juno_page2_knobs[index][2][0].valueAction_(1.0.rand);
	~alpha_juno_page2_knobs[index][2][2].valueAction_(1.0.rand);
	~alpha_juno_page2_knobs[index][3][0].valueAction_(0);
	~alpha_juno_page2_knobs[index][3][1].valueAction_(0);
	~alpha_juno_page2_knobs[index][3][2].valueAction_(0);
	2.do({
		switch(3.rand,
			0, {
				if(1.0.rand > 0.9, {
					~alpha_juno_page2_knobs[index][3][0].valueAction_(1.0.rand);
				});
			},
			1, {
				~alpha_juno_page2_knobs[index][3][1].valueAction_(1.0.rand);
			},
			2, {
				~alpha_juno_page2_knobs[index][3][2].valueAction_(1.0.rand);
			}
		);
	});
};
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
		~randomize_alpha_juno.value(index);
	});
});
~alpha_juno_page1_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~alpha_juno_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
});
~alpha_juno_page2_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~alpha_juno_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
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
~randomize_megafm = {
	arg index;
	var alg, car_ind;
	//~anushri_page1_knobs[index]["row"]["column"]
	alg = 8.rand;
	switch(alg,
		0, { car_ind = [3] },
		1, { car_ind = [3] },
		2, { car_ind = [3] },
		3, { car_ind = [3] },
		4, { car_ind = [1, 3] },
		5, { car_ind = [1, 2, 3] },
		6, { car_ind = [1, 2, 3] },
		7, { car_ind = [0, 1, 2, 3] },
	);
	4.do({
		|op|
		// randomize all levels
		~megafm_page1_knobs[index][0][op].valueAction_(1.0.rand);
		~megafm_page1_knobs[index][2][op].valueAction_(0.05.exprand(1));
		if(1.0.rand > 0.95, {
			~megafm_page1_knobs[index][3][op].valueAction_(0.01.exprand(1));
		}, {
			~megafm_page1_knobs[index][3][op].valueAction_(0.1.rand);
		});
	});
	car_ind.do({
		|op|
		// randomize all car levels but keep them all audible
		~megafm_page1_knobs[index][0][op].valueAction_(0.5.rand + 0.5);
	});
	// make sure at least one carrier is audible
	~megafm_page1_knobs[index][0][car_ind.choose].valueAction_(1);

	~megafm_page2_knobs[index][0][0].valueAction_([0, 0.2.rand + 0.05].choose);
	~megafm_page2_knobs[index][0][1].valueAction_(0.9.rand + 0.1);
	~megafm_page2_knobs[index][1][0].valueAction_(0.9.rand + 0.1);
	~megafm_page2_knobs[index][1][1].valueAction_(0.9.rand + 0.1);
	~megafm_page2_knobs[index][1][2].valueAction_(0.3.rand + 0.1);
	~megafm_page2_knobs[index][2][0].valueAction_([0, 0.2.rand + 0.05].choose);
	~megafm_page2_knobs[index][2][1].valueAction_(0.9.rand + 0.1);
	~megafm_page2_knobs[index][3][0].valueAction_(0.9.rand + 0.1);
	~megafm_page2_knobs[index][3][1].valueAction_(0.9.rand + 0.1);
	~megafm_page2_knobs[index][3][2].valueAction_(0.9.rand + 0.1);
};
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
		~randomize_megafm.value(index);
	});
});
~megafm_page1_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~megafm_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
});
~megafm_page2_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~megafm_comp_views[index][2], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
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
~randomize_modal = {
	arg index;
	~modal_page1_knobs[index][0][0].valueAction_(0.5.rand + 0.25);
	~modal_page1_knobs[index][0][1].valueAction_(0.5.rand + 0.25);
	~modal_page1_knobs[index][0][3].valueAction_(0.5.rand + 0.25);
	~modal_page1_knobs[index][1][0].valueAction_(1.0.rand);
	~modal_page1_knobs[index][1][1].valueAction_(1.0.rand);
	~modal_page1_knobs[index][1][2].valueAction_(0.8.rand);
	~modal_page1_knobs[index][2][0].valueAction_(1.0.rand);
	~modal_page1_knobs[index][2][1].valueAction_(0.5.rand + 0.25);
	~modal_page1_knobs[index][2][2].valueAction_(0.6.rand + 0.15);
	~modal_page1_knobs[index][2][3].valueAction_(0.6.rand + 0.15);
	~modal_page1_knobs[index][3][0].valueAction_(0.7.rand + 0.1);
};
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
		~randomize_modal.value(index);
	});
});
~modal_page1_knobs = 6.collect({
	|index|
	var knobs = nil!4!4;
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
				knobs[index2][index3] = Knob.new(~modal_comp_views[index][1], Rect(45+(index3*60), (index2*40), 50, 25) )
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
	knobs;
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

// comp views for samples
~sample_comp_views = 8.collect({
	|index|
	CompositeView(~comp_view_global[2], Rect(0, 0, 330, 195)).background_(
		Color.grey(0.3)
	).visible_(false)
});
~sample_index = 0;
~sample_label = StaticText(~comp_view_global[2], Rect(335, 10, 30, 10)).string_("track").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
~sample_buttons = 8.collect({
	|index|
	Button(~comp_view_global[2], Rect(340, 25+(index*20), 20, 15) ).action_({
		// todo: make engine use correct synth

		~sample_comp_views.do({
		|cv, ind|
		cv.visible = false;
		});
		~sample_comp_views[index].visible = true;
		~sample_index = index;
	});
});


~euclidean = {
	arg steps, pulses, rotation;
	var euclidean_pos, euclidean_trigs;
	if(pulses > 0, {
		euclidean_pos = (0..(pulses-1))/pulses*steps;
		euclidean_pos = euclidean_pos.asInteger;

		euclidean_trigs = 0!steps;
		euclidean_pos.do({
			|pos, index|
			euclidean_trigs[pos] = 1;
		});
	}, {
		euclidean_trigs = 0!steps;
	});

	euclidean_trigs.rotate(rotation);
};

~euclidean_generate_buttons = 8.collect({
	|index|
	Button.new(~sample_comp_views[index], Rect(10, 30, 15, 15))
	.action_({
		var eucl;
		eucl = ~euclidean.value(~euclidean_knobs[index][0].value.linlin(0, 1, 1, 16.99).floor,
			(~euclidean_knobs[index][0].value.linlin(0, 1, 1, 16.99).floor * ~euclidean_knobs[index][1].value).floor,
			(~euclidean_knobs[index][0].value.linlin(0, 1, 1, 16.99).floor * ~euclidean_knobs[index][2].value).floor.asInteger);
		~trigger_buttons[index].do({
			|button, index2|
			button.value = 0;
		});
		eucl.do({
			|val, index2|
			~trigger_buttons[index][index2].value = val;
		});
	});
});
~euclidean_knobs = 8.collect({
	|index|
	3.collect({
		|index2|
		Knob.new(~sample_comp_views[index], Rect(28 + (18*index2), 30, 15, 15))
		.mode_(\vert).value_([1, 0.5, 0].at(index2));
	});
});

~trigger_buttons = 8.collect({
	|index|
	16.collect({
		|index2| // todo: cut up in 4 sections of 4 buttons
		Button.new(~sample_comp_views[index], Rect(10 + (18*index2) + ((index2/4).floor*7.5) + ((index2/8).floor*2.5), 10, 15, 10)).states_([
			["", Color.white, Color.white],
			["", Color.red, Color.red]
		]);
	});
});
~trigger_indices = 0!8; ~global_sample_index = 0; ~trigger_lengths = 16!8;
~trigger_step_views = 8.collect({
	|index|
	UserView(~sample_comp_views[index], Rect(8, 20, 315, 5))
	.drawFunc_({
		16.do({
			|index2|
			var pos;
			pos = 10 + (18*index2) + ((index2/4).floor*7.5) + ((index2/8).floor*3.5);
			Pen.line(pos@0, pos@5);
			Pen.strokeColor = Color.red;
			if(index2 == ~trigger_indices[index], {
				Pen.strokeColor = Color.green;
			});
			if(~euclidean_knobs[index][0].value.isNil.not, {
				if(index2 > ~euclidean_knobs[index][0].value.linlin(0, 1, 0, 15.99).floor, {
					Pen.strokeColor = Color.black;
				});
			});
			Pen.width = 15;
			Pen.stroke;
		});
		if(~euclidean_knobs[index][0].value.isNil.not, {
			~trigger_lengths[index] = ~euclidean_knobs[index][0].value.linlin(0, 1, 1, 16.99).floor;
		});
	}).animate_(true).frameRate_(30);
});

~euclidean_labels = 8.collect({
	|index|
	[
		StaticText.new(~sample_comp_views[index], Rect(10+72+7.5, 30, 72, 15)).string_("gen, len, pls, phs").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8)),
		StaticText.new(~sample_comp_views[index], Rect(171.5+72+7.5, 30, 72, 15)).string_("rnd, even, odd, pow").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8)),
	]
});
~euclidean_randomize_buttons = 8.collect({
	|index|
	4.collect({
		|index2|
		Button.new(~sample_comp_views[index], Rect(171.5 + (18*index2), 30, 15, 15))
		.action_({
			|button|
			var stepnr;
			switch(index2,
				0, {
					stepnr = 16.rand;
				},
				1, {
					stepnr = 8.rand * 2 + 1;
				},
				2, {
					stepnr = 8.rand * 2;
				},
				3, {
					stepnr = [0, 1, 3, 7, 15].choose;
				}
			);
			~euclidean_knobs[index][0].value = stepnr.linlin(0, 15, 0.0001, 1);
			~euclidean_knobs[index][1].value = 1.0.rand.linlin(0, 1, (1+stepnr)/16, 1);
			~euclidean_knobs[index][2].value = 1.0.rand;
			~euclidean_generate_buttons[index].valueAction = 0;
		});
	});
});

~param_type_index = 0!8;
~param_type_buttons = 8.collect({
	|index|
	3.collect({
		|index2|
		Button.new(~sample_comp_views[index], Rect(35, 55+(20*index2), 15, 15))
		.action_({
			|button|
			~param_type_index[index] = index2;
			switch(index2,
				0, {
					~vel_bar_rand_comp_view[index].visible = true;
					~vel_pattern_rand_comp_view[index].visible = true;
					~dec_bar_rand_comp_view[index].visible = false;
					~dec_pattern_rand_comp_view[index].visible = false;
					~pan_bar_rand_comp_view[index].visible = false;
					~pan_pattern_rand_comp_view[index].visible = false;
					~vel_rand_param_knobs[index].do({ |knob, index3| knob.visible = true });
					~dec_rand_param_knobs[index].do({ |knob, index3| knob.visible = false });
					~pan_rand_param_knobs[index].do({ |knob, index3| knob.visible = false });
				},
				1, {
					~vel_bar_rand_comp_view[index].visible = false;
					~vel_pattern_rand_comp_view[index].visible = false;
					~dec_bar_rand_comp_view[index].visible = true;
					~dec_pattern_rand_comp_view[index].visible = true;
					~pan_bar_rand_comp_view[index].visible = false;
					~pan_pattern_rand_comp_view[index].visible = false;
					~vel_rand_param_knobs[index].do({ |knob, index3| knob.visible = false });
					~dec_rand_param_knobs[index].do({ |knob, index3| knob.visible = true });
					~pan_rand_param_knobs[index].do({ |knob, index3| knob.visible = false });

				},
				2, {
					~vel_bar_rand_comp_view[index].visible = false;
					~vel_pattern_rand_comp_view[index].visible = false;
					~dec_bar_rand_comp_view[index].visible = false;
					~dec_pattern_rand_comp_view[index].visible = false;
					~pan_bar_rand_comp_view[index].visible = true;
					~pan_pattern_rand_comp_view[index].visible = true;
					~vel_rand_param_knobs[index].do({ |knob, index3| knob.visible = false });
					~dec_rand_param_knobs[index].do({ |knob, index3| knob.visible = false });
					~pan_rand_param_knobs[index].do({ |knob, index3| knob.visible = true });

				}
			);
		});
	});
});
~param_type_text = 8.collect({
	|index|
	StaticText.new(~sample_comp_views[index], Rect(10, 75, 25, 15)).string_("type").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8))
});
~param_labels = 8.collect({
	|index|
	3.collect({
		|index2|
		StaticText.new(~sample_comp_views[index], Rect(50, 55+(20*index2), 25, 15))
		.string_(["vel", "dec", "pan"].at(index2))
		.stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8))
	});
});
~param_rand_buttons = 8.collect({
	|index|
	3.collect({
		|index2|
		Button.new(~sample_comp_views[index], Rect(75, 55+(20*index2), 15, 15))
		.action_({
			|button|
			switch(index2,
				0, {
					~vel_bar_vals[index] = {1.0.rand}!16; ~vel_pattern_vals[index] = {1.0.rand}!16;
				},
				1, {
					~dec_bar_vals[index] = {1.0.rand}!16; ~dec_pattern_vals[index] = {1.0.rand}!16;
				},
				2, {
					~pan_bar_vals[index] = {1.0.rand}!16; ~pan_pattern_vals[index] = {1.0.rand}!16;
				}
			);
		});
	});
});
~param_rand_text = 8.collect({
	|index|
	StaticText.new(~sample_comp_views[index], Rect(90, 75, 25, 15)).string_("rand").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 8))
});

~vel_bar_vals = {1.0.rand}!16!8; ~vel_pattern_vals = {1.0.rand}!16!8;
~vel_bar_rand_comp_view = 8.collect({
	|index|
	UserView.new(~sample_comp_views[index], Rect(120, 55, 175, 25)).background_(Color.white).drawFunc_({
		~vel_bar_vals[index].do({
			|val, index2|
			var pos, knob_val;
			knob_val = ~vel_rand_param_knobs[index][0].value;
			val = [knob_val.linlin(0, 0.5, 0, val), knob_val.linlin(0.5, 1, val, 1)].at((knob_val*1.999).asInteger);
			pos = 175/16*index2+7;
			Pen.line(pos@25, pos@(25*(1-val)));
			Pen.strokeColor = Color.gray(0.5);
			if(index2 == ~global_sample_index, {
				Pen.strokeColor = Color.green;
			});
			Pen.width = 175/16;
			Pen.stroke;
		});
	}).animate_(true).frameRate_(30).visible_(true);
});
~vel_pattern_rand_comp_view = 8.collect({
	|index|
	UserView.new(~sample_comp_views[index], Rect(120, 85, 175, 25)).background_(Color.white).drawFunc_({
		var num_steps;
		if(~euclidean_knobs[index][0].value.isNil.not, {
			num_steps = ~euclidean_knobs[index][0].value.linlin(0, 1, 1, 16.99).floor;
		}, { num_steps = 0 });
		(~vel_pattern_vals[index].at( (0..num_steps-1) )).do({
			|val, index2|
			var pos, knob_val;
			knob_val = ~vel_rand_param_knobs[index][2].value;
			val = [knob_val.linlin(0, 0.5, 0, val), knob_val.linlin(0.5, 1, val, 1)].at((knob_val*1.999).asInteger);
			pos = 175/num_steps*(index2+0.5);
			Pen.line(pos@25, pos@(25*(1-val)));
			Pen.strokeColor = Color.gray(0.5);
			if(index2 == ~trigger_indices[index], {
				Pen.strokeColor = Color.green;
			});
			Pen.width = 175/num_steps;
			Pen.stroke;
		});
	}).animate_(true).frameRate_(30).visible_(true);
});
~vel_rand_param_knobs = 8.collect({
	|index|
	3.collect({
		|index2|
		Knob.new(~sample_comp_views[index], Rect(305, 55 + (index2*20), 15, 15))
		.value_( [1, 0, 0.5].at(index2) ).visible_(true).mode_(\vert);
	});
});

~dec_bar_vals = {1.0.rand}!16!8; ~dec_pattern_vals = {1.0.rand}!16!8;
~dec_bar_rand_comp_view = 8.collect({
	|index|
	UserView.new(~sample_comp_views[index], Rect(120, 55, 175, 25)).background_(Color.white).drawFunc_({
		~dec_bar_vals[index].do({
			|val, index2|
			var pos, knob_val;
			knob_val = ~dec_rand_param_knobs[index][0].value;
			val = [knob_val.linlin(0, 0.5, 0, val), knob_val.linlin(0.5, 1, val, 1)].at((knob_val*1.999).asInteger);
			pos = 175/16*index2+7;
			Pen.line(pos@25, pos@(25*(1-val)));
			Pen.strokeColor = Color.gray(0.5);
			if(index2 == ~global_sample_index, {
				Pen.strokeColor = Color.green;
			});
			Pen.width = 175/16;
			Pen.stroke;
		});
	}).animate_(true).frameRate_(30).visible_(false);
});
~dec_pattern_rand_comp_view = 8.collect({
	|index|
	UserView.new(~sample_comp_views[index], Rect(120, 85, 175, 25)).background_(Color.white).drawFunc_({
		var num_steps;
		if(~euclidean_knobs[index][0].value.isNil.not, {
			num_steps = ~euclidean_knobs[index][0].value.linlin(0, 1, 1, 16.99).floor;
		}, { num_steps = 0 });
		(~dec_pattern_vals[index].at( (0..num_steps-1) )).do({
			|val, index2|
			var pos, knob_val;
			knob_val = ~dec_rand_param_knobs[index][2].value;
			val = [knob_val.linlin(0, 0.5, 0, val), knob_val.linlin(0.5, 1, val, 1)].at((knob_val*1.999).asInteger);
			pos = 175/num_steps*(index2+0.5);
			Pen.line(pos@25, pos@(25*(1-val)));
			Pen.strokeColor = Color.gray(0.5);
			if(index2 == ~trigger_indices[index], {
				Pen.strokeColor = Color.green;
			});
			Pen.width = 175/num_steps;
			Pen.stroke;
		});
	}).animate_(true).frameRate_(30).visible_(false);
});
~dec_rand_param_knobs = 8.collect({
	|index|
	3.collect({
		|index2|
		Knob.new(~sample_comp_views[index], Rect(305, 55 + (index2*20), 15, 15))
		.value_( [1, 0, 0.5].at(index2) ).visible_(false).mode_(\vert);
	});
});

~pan_bar_vals = {1.0.rand}!16!8; ~pan_pattern_vals = {1.0.rand}!16!8;
~pan_bar_rand_comp_view = 8.collect({
	|index|
	UserView.new(~sample_comp_views[index], Rect(120, 55, 175, 25)).background_(Color.white).drawFunc_({
		~pan_bar_vals[index].do({
			|val, index2|
			var pos, knob_val;
			knob_val = ~pan_rand_param_knobs[index][0].value;
			if(val < 0.5, {
				val = [knob_val.linlin(0, 0.5, 0.5, val), knob_val.linlin(0.5, 1, val, 0)].at((knob_val*1.999).asInteger);
			}, {
				val = [knob_val.linlin(0, 0.5, 0.5, val), knob_val.linlin(0.5, 1, val, 1)].at((knob_val*1.999).asInteger);
			});
			pos = 175/16*index2+7;
			Pen.line(pos@12.5, pos@(25*(1-val)));
			Pen.strokeColor = Color.gray(0.5);
			if(index2 == ~global_sample_index, {
				Pen.strokeColor = Color.green;
			});
			Pen.width = 175/16;
			Pen.stroke;
		});
	}).animate_(true).frameRate_(30).visible_(false);
});
~pan_pattern_rand_comp_view = 8.collect({
	|index|
	UserView.new(~sample_comp_views[index], Rect(120, 85, 175, 25)).background_(Color.white).drawFunc_({
		var num_steps;
		if(~euclidean_knobs[index][0].value.isNil.not, {
			num_steps = ~euclidean_knobs[index][0].value.linlin(0, 1, 1, 16.99).floor;
		}, { num_steps = 0 });
		(~pan_pattern_vals[index].at( (0..num_steps-1) )).do({
			|val, index2|
			var pos, knob_val;
			knob_val = ~pan_rand_param_knobs[index][2].value;
			if(val < 0.5, {
				val = [knob_val.linlin(0, 0.5, 0.5, val), knob_val.linlin(0.5, 1, val, 0)].at((knob_val*1.999).asInteger);
			}, {
				val = [knob_val.linlin(0, 0.5, 0.5, val), knob_val.linlin(0.5, 1, val, 1)].at((knob_val*1.999).asInteger);
			});
			pos = 175/num_steps*(index2+0.5);
			Pen.line(pos@12.5, pos@(25*(1-val)));
			Pen.strokeColor = Color.gray(0.5);
			if(index2 == ~trigger_indices[index], {
				Pen.strokeColor = Color.green;
			});
			Pen.width = 175/num_steps;
			Pen.stroke;
		});
	}).animate_(true).frameRate_(30).visible_(false);
});
~pan_rand_param_knobs = 8.collect({
	|index|
	3.collect({
		|index2|
		Knob.new(~sample_comp_views[index], Rect(305, 55 + (index2*20), 15, 15))
		.value_( [0, 0, 0.5].at(index2) ).visible_(false).mode_(\vert);
	});
});

~sound_file_dict = Dictionary.new;

~sample_folder = (PathName(thisProcess.nowExecutingPath).parentPath.asString ++ "GrooveBox\ Samples/").asPathName.folders;
~sample_folder_items = ~sample_folder.size.collect({
	|index|
	var folder_name, files;
	folder_name = ~sample_folder[index].folderName;
	files = ~sample_folder[index].files;
	~sound_file_dict[folder_name.asSymbol] = Dictionary.new;
	files.do({
		|file, index2|
		var path;
		path = file.asAbsolutePath;
		~sound_file_dict[folder_name.asSymbol][file.fileName.asSymbol] = SoundFile.new;
		~sound_file_dict[folder_name.asSymbol][file.fileName.asSymbol].openRead(
			path
		);
	});
	folder_name;
});

~sample_waveforms = 8.collect({
	|index|
	SoundFileView.new(~sample_comp_views[index], Rect(10, 160, 270, 30));
});
~sample_levels = 1!8;
~sample_level_knobs = 8.collect({
	|index|
	Knob.new(~sample_comp_views[index], Rect(290, 160, 30, 30))
	.action_({
		|knob|
		~sample_levels[index] = knob.value.linlin(0, 1, -60, 0).dbamp;
		if(knob.value == 0, { ~sample_levels[index] = 0 });
	}).value_(1).mode_(\vert);
});
~update_waveform = {
	arg index;//, menu_nr, file_nr;
	var sf;
	sf = ~sound_file_dict[
		~sample_folder_menu[index].item.asSymbol
	][
		~sample_menu[index].item.asSymbol
	];
	~sample_waveforms[index].soundfile = sf;
	~sample_waveforms[index].read(0, sf.numFrames);
};

~sample_folder_menu = 8.collect({
	|index|
	StaticText(~sample_comp_views[index], Rect(10, 115, 150, 10) )
	.string_("sample folder").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	PopUpMenu(~sample_comp_views[index], Rect(10, 130, 150, 20) )
	.items_(
		~sample_folder_items
	).action_({ |menu|
		~sample_menu[index].items =
		~sample_folder[ menu.value ].files.collect({
			|file| file.fileName;
		});
		~update_waveform.value(index);
	});
});

~set_sample_items = {
	~sample_items = nil!8;
	8.do({
		|index|
		var files;
		files = (PathName(thisProcess.nowExecutingPath).parentPath.asString ++ "GrooveBox\ Samples/").asPathName.folders[ ~sample_folder_menu[index].value ].files;
		~sample_items[index] = files.collect({
			|file, index2|
			file.fileName;
		});
	});
};
~set_sample_items.value;

~sample_menu = 8.collect({
	|index|
	StaticText(~sample_comp_views[index], Rect(170, 115, 150, 10) )
	.string_("sample select").stringColor_(Color.white).align_(\center).font_( Font("Monaco", 10) );
	PopUpMenu(~sample_comp_views[index], Rect(170, 130, 150, 20) )
	.items_(
		~sample_items[index];
	).action_({
		|menu|
		~update_waveform.value(index);
	});
});

8.do({
	|index|
	~update_waveform.value(index);
});

// effect send params

// initialization
~track_buttons[0].valueAction = 1;
6.do({
	|index|
	~sequencer_type_comp_views[index][0].visible = true;
	~synth_type_buttons[index][0].valueAction = 1;
	~anushri_page_buttons[index][0].valueAction = 1;
});
~sample_buttons[0].valueAction = 1;
