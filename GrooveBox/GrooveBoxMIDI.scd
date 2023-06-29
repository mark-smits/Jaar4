MIDIdef.freeAll;

~lppro_out = MIDIOut.newByName( "LPProMK3 MIDI", "LPProMK3 MIDI" );
~lppro_out.sysex( Int8Array[0xF0, 0, 32, 41, 2, 14, 0, 17, 0, 0, 0xF7] );

// macro buttons
4.do({
	|index|
	6.do({
		|index2|
		~lppro_out.noteOn(0, 12+index2+(10*index), [53, 78, 53, 53].at(index));
	});
});
// top buttons
~reset_lppro_top_buttons = {
	(92..97).do({
		|index|
		~lppro_out.noteOn(0, index, 78);
	});
};
~reset_lppro_top_buttons.value;
// right side buttons
~reset_lppro_right_buttons = {
	8.do({
		|index|
		~lppro_out.noteOn(0, 19+(10*index), 53);
	});
};
~reset_lppro_right_buttons.value;
// left side buttons
~reset_lppro_left_buttons = {
	[10, 40, 50, 60, 70, 80].do({
		|index|
		~lppro_out.noteOn(0, index, 78);
	});
};
~reset_lppro_left_buttons.value;
// sequencer global buttons
((81..84)++(71..74)).do({
	|index|
	~lppro_out.noteOn(0, index, 79);
});
// sequencer specific buttons
// todo
~reset_lppro_seq_specific_buttons = {
	((85..88)++(75..78)++(61..68)++(51..58)).do({
		|index|
		~lppro_out.noteOn(0, index, 0);
	});
};
~reset_lppro_seq_specific_buttons.value;

~update_lppro = {
	~reset_lppro_left_buttons.value;
	~reset_lppro_right_buttons.value;
	~reset_lppro_top_buttons.value;
	~reset_lppro_seq_specific_buttons.value;
	~lppro_out.noteOn(2, [38, 48].at(1-~macro_index), 3);
	~lppro_out.noteOn(0, [38, 48].at(~macro_index), 53);
	if(~global_page, {
		~lppro_out.noteOn(2, 10, 3);
	}, {
		~lppro_out.noteOn(2, (92..97).at(~track_index), 3);
		~lppro_out.noteOn(2, [70, 60, 50, 40].at(~sequencer_type_index[~track_index]), 3);
		~lppro_out.noteOn(2, [89, 79, 69, 59, 49, 39, 29].at(~synth_indices[~track_index]), 3);
	});
	4.do({
		|index|
		~lppro_out.noteOn(0, 101+index, 0);
	});
	[4, 3, 3, 3, 3, 3, 2, 2].at(~synth_indices[~track_index]).do({
		|index|
		~lppro_out.noteOn(0, 101+index, 53);
	});
	~lppro_out.noteOn(2, [
		~anushri_page_indices[~track_index],
		~sh101_page_indices[~track_index],
		~buchla_page_indices[~track_index],
		~juno6_page_indices[~track_index],
		~alpha_juno_page_indices[~track_index],
		~megafm_page_indices[~track_index],
		~modal_page_indices[~track_index],
		~sampler_page_indices[~track_index],
	].at(~synth_indices[~track_index]) + 101, 3);
	switch(~sequencer_type_index[~track_index],
		0, {
			[61, 51].do({
				|index|
				~lppro_out.noteOn(0, index, 78);
			});
		},
		1, {
			[61, 51, 62, 52, 63, 53, 64, 54, 85, 86, 87, 88, 75, 76, 77, 78, 65, 67, 68].do({
				|index|
				~lppro_out.noteOn(0, index, 78);
			});
			{
				~lppro_out.noteOn(2, [85, 86, 87, 88, 75, 76, 77, 78, 65].at(~acd_gen_multi_sliders[~track_index].index), 3);
			}.defer;
		},
		2, {
			[61, 51, 62, 52, 63, 53, 64, 54, 65, 55, 66, 56].do({
				|index|
				~lppro_out.noteOn(0, index, 78);
			});
		},
		3, {
			[61, 51, 62, 52, 63, 53].do({
				|index|
				~lppro_out.noteOn(0, index, 78);
			});
		}
	);
};

~apcmini_out = MIDIOut.newByName( "APC mini mk2", "APC mini mk2" );
~update_apcmini = {
	~apcmini_out.sysex( Int8Array[0xF0, 0x47, 0x7F, 0x4F, 0x24, 0x00, 0x40,

		0x20, 0x27,
		0x77, 0x77, 0x1F, 0x1F, 0x1B, 0x1B, // EF3E36
		0x29, 0x2B,
		0x77, 0x77, 0x1F, 0x1F, 0x1B, 0x1B, // EF3E36

		0x08, 0x0B,
		0x7F, 0x7F, 0x6E, 0x6E, 0x2F, 0x2F, // FFDC5E
		0x10, 0x13,
		0x7F, 0x7F, 0x6E, 0x6E, 0x2F, 0x2F, // FFDC5E
		0x18, 0x1B,
		0x7F, 0x7F, 0x6E, 0x6E, 0x2F, 0x2F, // FFDC5E

		0x16, 0x17,
		0x0B, 0x0B, 0x5F, 0x5F, 0x5D, 0x5D, // 17BEBB
		0x1E, 0x1F,
		0x0B, 0x0B, 0x5F, 0x5F, 0x5D, 0x5D, // 17BEBB

		0x30, 0x3F,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00,

		0xF7] );

	{ ~euclidean_knobs[~sample_index][0].value.linlin(0, 1, 1, 16.99).asInteger.do({
		|index|
			var button_hex = [0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37].at(index);
		if(~trigger_buttons[~sample_index][index].value == 1, {
			~apcmini_out.sysex( Int8Array[0xF0, 0x47, 0x7F, 0x4F, 0x24, 0x00, 0x08,
				button_hex, button_hex,
				0x42, 0x42, 0x61, 0x61, 0x0C, 0x0C, // 84C318
				0xF7] );
		}, {
			~apcmini_out.sysex( Int8Array[0xF0, 0x47, 0x7F, 0x4F, 0x24, 0x00, 0x08,
				button_hex, button_hex,
				0x45, 0x45, 0x0E, 0x0E, 0x3E, 0x3E, // 8A1C7C
				0xF7] );
		});
	}); }.defer;

	8.do({
		|index|
		~apcmini_out.noteOn(0, 112+index, 0);
	});

	~apcmini_out.noteOn(0, 112+~sample_index, 127);
};
~update_apcmini.value;
/*~apcmini_out.sysex( Int8Array[0xF0, 0x47, 0x7F, 0x4F, 0x24, 0x00, 0x08, 0x00, 0x3F,
	0x7F, 0x00, 0x7F, 0x00, 0x7F, 0x00,
	0xF7] );*/

MIDIdef.noteOn(\MFT_notes, {
	arg vel, note, chan, src;

	[vel, note, chan, src].postln;

	// todo: add mute and solo functionality

}, srcID: MIDIClient.sources.detect { |all| all.device.containsi("Midi Fighter Twister") }.uid);

MIDIdef.cc(\MFT_cc, {
	arg val, cc, chan, src;

	[val, cc, chan, src].postln;

	if(~global_page, {
		"global page".postln;
		switch(cc,
			8, {
				switch(val,
					65, { { ~tempo_knob.increment }.defer },
					63, { { ~tempo_knob.decrement }.defer },
				);
			},
			9, {
				switch(val,
					65, { { ~swing_knob.increment }.defer },
					63, { { ~swing_knob.decrement }.defer },
				);
			},
			10, { { ~regen_button.valueAction_(1) }.defer },
			4, {
				switch(val,
					65, { { ~echo_knobs[0].increment }.defer },
					63, { { ~echo_knobs[0].decrement }.defer },
				);
			},
			5, {
				switch(val,
					65, { { ~echo_knobs[1].increment }.defer },
					63, { { ~echo_knobs[1].decrement }.defer },
				);
			},
			6, {
				switch(val,
					65, { { ~echo_knobs[2].increment }.defer },
					63, { { ~echo_knobs[2].decrement }.defer },
				);
			},
			0, {
				switch(val,
					65, { { ~reverb_knobs[0].increment }.defer },
					63, { { ~reverb_knobs[0].decrement }.defer },
				);
			},
			1, {
				switch(val,
					65, { { ~reverb_knobs[1].increment }.defer },
					63, { { ~reverb_knobs[1].decrement }.defer },
				);
			},
			2, {
				switch(val,
					65, { { ~reverb_knobs[2].increment }.defer },
					63, { { ~reverb_knobs[2].decrement }.defer },
				);
			},
		);
	}, {
		var row = (cc/4).asInteger, column = cc.mod(4), page, knob, macros1, macros2;

		page = [
			[nil, ~anushri_page1_knobs[~track_index], ~anushri_page2_knobs[~track_index], ~anushri_page3_knobs[~track_index]],
			[nil, ~sh101_page1_knobs[~track_index], ~sh101_page2_knobs[~track_index]],
			[nil, ~buchla_page1_knobs[~track_index], ~buchla_page2_knobs[~track_index]],
			[nil, ~juno6_page1_knobs[~track_index], ~juno6_page2_knobs[~track_index]],
			[nil, ~alpha_juno_page1_knobs[~track_index], ~alpha_juno_page2_knobs[~track_index]],
			[nil, ~megafm_page1_knobs[~track_index], ~megafm_page2_knobs[~track_index]],
			[nil, ~modal_page1_knobs[~track_index]],
			[nil, nil],
		].at(~synth_indices[~track_index]).at( [
			~anushri_page_indices[~track_index],
			~sh101_page_indices[~track_index],
			~buchla_page_indices[~track_index],
			~juno6_page_indices[~track_index],
			~alpha_juno_page_indices[~track_index],
			~megafm_page_indices[~track_index],
			~modal_page_indices[~track_index],
			~sampler_page_indices[~track_index],
		].at(~synth_indices[~track_index]) );

		macros1 = [
			~anushri_macro_knobs1,
			~sh101_macro_knobs1,
			~buchla_macro_knobs1,
			~juno6_macro_knobs1,
			~alpha_juno_macro_knobs1,
			~megafm_macro_knobs1,
			~modal_macro_knobs1,
			~sampler_macro_knobs1,
		];

		macros2 = [
			~anushri_macro_knobs2,
			~sh101_macro_knobs2,
			~buchla_macro_knobs2,
			~juno6_macro_knobs2,
			~alpha_juno_macro_knobs2,
			~megafm_macro_knobs2,
			~modal_macro_knobs2,
			~sampler_macro_knobs2,
		];

		if(page.isNil, {
			knob = [
				[
					macros1.at(~synth_indices[0]).at([0]), macros2.at(~synth_indices[0]).at([0]),
					macros1.at(~synth_indices[3]).at([3]), macros2.at(~synth_indices[3]).at([3]),
				],[
					macros1.at(~synth_indices[1]).at([1]), macros2.at(~synth_indices[1]).at([1]),
					macros1.at(~synth_indices[4]).at([4]), macros2.at(~synth_indices[4]).at([4]),
				],[
					macros1.at(~synth_indices[2]).at([2]), macros2.at(~synth_indices[2]).at([2]),
					macros1.at(~synth_indices[5]).at([5]), macros2.at(~synth_indices[5]).at([5]),
				],[
					nil, macros1.at(~synth_indices[~track_index]).at([~track_index]),
					macros2.at(~synth_indices[~track_index]).at([~track_index]), nil
				]
			].at(row).at(column);
		}, {
			knob = page.at(row).at(column);
		});

		if(knob.isArray, { knob = knob[0] });

		if(knob.isNil.not, {
			switch(val,
				63, { { knob.decrement }.defer },
				65, { { knob.increment }.defer },
			);
		});
	});

	// todo: add mute and solo functionality

}, srcID: MIDIClient.sources.detect { |all| all.device.containsi("Midi Fighter Twister") }.uid);

MIDIdef.noteOn(\LCXL_notes, {
	arg vel, note, chan, src;

	[vel, note, chan, src].postln;

	// todo: add mute and solo functionality

}, srcID: MIDIClient.sources.detect { |all| all.device.containsi("Launch Control XL") }.uid);

MIDIdef.cc(\LCXL_cc, {
	arg val, cc, chan, src;

	[val, cc, chan, src].postln;

	if( (cc>76).and(cc<85), {
		var slider_nr = cc-77;
		{ ~mixer_sliders[slider_nr].valueAction_(val/127) }.defer;
	});

	if( (cc>48).and(cc<57), {
		var knob_nr = cc-49;
		{ ~mixer_knobs[knob_nr][2].valueAction_(val/127) }.defer;
	});

	if( (cc>28).and(cc<37), {
		var knob_nr = cc-29;
		{ ~mixer_knobs[knob_nr][1].valueAction_(val/127) }.defer;
	});

	if( (cc>12).and(cc<21), {
		var knob_nr = cc-13;
		{ ~mixer_knobs[knob_nr][0].valueAction_(val/127) }.defer;
	});

}, srcID: MIDIClient.sources.detect { |all| all.device.containsi("Launch Control XL") }.uid);

MIDIdef.noteOn(\APCMini_notes, {
	arg vel, note, chan, src;

	[vel, note, chan, src].postln;

	// right side buttons
	if( (note>111).and(note<120), {
		var track_index = note-112;
		{ ~sample_buttons[track_index].valueAction_(1) }.defer;
	});

	// top 16 buttons
	if( (note>47).and(note<64), {
		var step_nr = note-48;
		step_nr = (step_nr+8).mod(16);
		{
			~trigger_buttons[~sample_index][step_nr].valueAction_(
				1 - ~trigger_buttons[~sample_index][step_nr].value;
			);
		}.defer;
	});

	// second 16 buttons
	switch(note,
		32, {
			{ ~euclidean_generate_buttons[~sample_index].valueAction_(1) }.defer;
		},
		33, { { ~euclidean_knobs[~sample_index][0].decrement }.defer },
		41, { { ~euclidean_knobs[~sample_index][0].increment }.defer },
		34, { { ~euclidean_knobs[~sample_index][1].decrement }.defer },
		42, { { ~euclidean_knobs[~sample_index][1].increment }.defer },
		35, { { ~euclidean_knobs[~sample_index][2].decrement }.defer },
		43, { { ~euclidean_knobs[~sample_index][2].increment }.defer },
		36, {
			{ ~euclidean_randomize_buttons[~sample_index][0].valueAction_(1) }.defer;
		},
		37, {
			{ ~euclidean_randomize_buttons[~sample_index][1].valueAction_(1) }.defer;
		},
		38, {
			{ ~euclidean_randomize_buttons[~sample_index][2].valueAction_(1) }.defer;
		},
		39, {
			{ ~euclidean_randomize_buttons[~sample_index][3].valueAction_(1) }.defer;
		},
	);

	// param buttons
	switch(note,
		8, { { ~param_type_buttons[~sample_index][2].valueAction_(1) }.defer },
		16, { { ~param_type_buttons[~sample_index][1].valueAction_(1) }.defer },
		24, { { ~param_type_buttons[~sample_index][0].valueAction_(1) }.defer },
		9, { { ~param_rand_buttons[~sample_index][2].valueAction_(1) }.defer },
		17, { { ~param_rand_buttons[~sample_index][1].valueAction_(1) }.defer },
		25, { { ~param_rand_buttons[~sample_index][0].valueAction_(1) }.defer },
		26, { {
			switch(~param_type_index[~sample_index],
				0, {~vel_rand_param_knobs[~sample_index][0].decrement},
				1, {~dec_rand_param_knobs[~sample_index][0].decrement},
				2, {~pan_rand_param_knobs[~sample_index][0].decrement},
			);
		}.defer },
		27, { {
			switch(~param_type_index[~sample_index],
				0, {~vel_rand_param_knobs[~sample_index][0].increment},
				1, {~dec_rand_param_knobs[~sample_index][0].increment},
				2, {~pan_rand_param_knobs[~sample_index][0].increment},
			);
		}.defer },
		18, { {
			switch(~param_type_index[~sample_index],
				0, {~vel_rand_param_knobs[~sample_index][1].decrement},
				1, {~dec_rand_param_knobs[~sample_index][1].decrement},
				2, {~pan_rand_param_knobs[~sample_index][1].decrement},
			);
		}.defer },
		19, { {
			switch(~param_type_index[~sample_index],
				0, {~vel_rand_param_knobs[~sample_index][1].increment},
				1, {~dec_rand_param_knobs[~sample_index][1].increment},
				2, {~pan_rand_param_knobs[~sample_index][1].increment},
			);
		}.defer },
		10, { {
			switch(~param_type_index[~sample_index],
				0, {~vel_rand_param_knobs[~sample_index][2].decrement},
				1, {~dec_rand_param_knobs[~sample_index][2].decrement},
				2, {~pan_rand_param_knobs[~sample_index][2].decrement},
			);
		}.defer },
		11, { {
			switch(~param_type_index[~sample_index],
				0, {~vel_rand_param_knobs[~sample_index][2].increment},
				1, {~dec_rand_param_knobs[~sample_index][2].increment},
				2, {~pan_rand_param_knobs[~sample_index][2].increment},
			);
		}.defer },
	);

	// sample menus
	switch(note,
		30, { {
			~sample_folder_menu[~sample_index].valueAction_(
				(~sample_folder_menu[~sample_index].value+1).mod(
					~sample_folder_menu[~sample_index].items.size)
			)
		}.defer },
		22, { {
			~sample_folder_menu[~sample_index].valueAction_(
				(~sample_folder_menu[~sample_index].value-1).mod(
					~sample_folder_menu[~sample_index].items.size)
			)
		}.defer },
		31, { {
			~sample_menu[~sample_index].valueAction_(
				(~sample_menu[~sample_index].value+1).mod(
					~sample_menu[~sample_index].items.size)
			)
		}.defer },
		23, { {
			~sample_menu[~sample_index].valueAction_(
				(~sample_menu[~sample_index].value-1).mod(
					~sample_menu[~sample_index].items.size)
			)
		}.defer },
	);
	{ ~update_apcmini.value; }.defer(0.1);

}, srcID: MIDIClient.sources.detect { |all| all.device.containsi("APC mini mk2") }.uid);

MIDIdef.cc(\APCMini_cc, {
	arg val, cc, chan, src;

	[val, cc, chan, src].postln;

	// faders
	if( (cc>47).and(cc<56), {
		var track_index = cc-48;
		{ ~sample_level_knobs[track_index].valueAction_(val/127) }.defer;
	});

}, srcID: MIDIClient.sources.detect { |all| all.device.containsi("APC mini mk2") }.uid);


~macro_index = 0;
MIDIdef.noteOn(\LPPro_notes, {
	arg vel, note, chan, src;

	[vel, note, chan, src].postln;

	// global settings
	switch(note,
		81, { { ~sequencer_length_knobs[~track_index].increment }.defer },
		82, { { ~sequencer_sync_length_knobs[~track_index].increment }.defer },
		83, {
			{ ~sequencer_uses_global_scale_buttons[~track_index].valueAction_( 1-~sequencer_uses_global_scale_buttons[~track_index].value ) }.defer
		},
		84, { { ~sequencer_octave_knobs[~track_index].increment }.defer },
		71, { { ~sequencer_length_knobs[~track_index].decrement }.defer },
		72, { { ~sequencer_sync_length_knobs[~track_index].decrement }.defer },
		73, { { ~sequencer_sync_buttons[~track_index].valueAction_( 1-~sequencer_sync_buttons[~track_index].value ) }.defer },
		74, { { ~sequencer_octave_knobs[~track_index].decrement }.defer },
	);

	// house engine settings
	if(~sequencer_type_index[~track_index] == 0, {
		switch(note,
			61, { { ~house_engine_menu[~track_index].valueAction_( ( ~house_engine_menu[~track_index].value+1 ).mod(~house_engine_menu[~track_index].items.size) ) }.defer },
			51, { { ~house_engine_menu[~track_index].valueAction_( ( ~house_engine_menu[~track_index].value-1 ).mod(~house_engine_menu[~track_index].items.size) ) }.defer },
		);
	});

	// acdgen settings
	if(~sequencer_type_index[~track_index] == 1, {
		switch(note,
			61, { {~acd_gen_density_knobs[~track_index].increment}.defer },
			51, { {~acd_gen_density_knobs[~track_index].decrement}.defer },
			62, { {~acd_gen_variation_knobs[~track_index].increment}.defer },
			52, { {~acd_gen_variation_knobs[~track_index].decrement}.defer },
			63, { {~acd_gen_mutation_knobs[~track_index].increment}.defer },
			53, { {~acd_gen_mutation_knobs[~track_index].decrement}.defer },
			64, { { ~acd_gen_seq_mode_menus[~track_index].valueAction_( ( ~acd_gen_seq_mode_menus[~track_index].value+1 ).mod(~acd_gen_seq_mode_menus[~track_index].items.size) ) }.defer },
			54, { { ~acd_gen_seq_mode_menus[~track_index].valueAction_( ( ~acd_gen_seq_mode_menus[~track_index].value-1 ).mod(~acd_gen_seq_mode_menus[~track_index].items.size) ) }.defer },
			85, { { ~acd_gen_multi_sliders[~track_index].index_(0) }.defer },
			86, { { ~acd_gen_multi_sliders[~track_index].index_(1) }.defer },
			87, { { ~acd_gen_multi_sliders[~track_index].index_(2) }.defer },
			88, { { ~acd_gen_multi_sliders[~track_index].index_(3) }.defer },
			75, { { ~acd_gen_multi_sliders[~track_index].index_(4) }.defer },
			76, { { ~acd_gen_multi_sliders[~track_index].index_(5) }.defer },
			77, { { ~acd_gen_multi_sliders[~track_index].index_(6) }.defer },
			78, { { ~acd_gen_multi_sliders[~track_index].index_(7) }.defer },
			65, { { ~acd_gen_multi_sliders[~track_index].index_(8) }.defer },
			67, { {
				~acd_gen_multi_sliders[~track_index].currentvalue_(
					(~acd_gen_multi_sliders[~track_index].currentvalue - 0.1).clip(0, 1)
			) }.defer
			},
			68, { {
				~acd_gen_multi_sliders[~track_index].currentvalue_(
					(~acd_gen_multi_sliders[~track_index].currentvalue + 0.1).clip(0, 1)
			) }.defer
			},
		);
	});

	// srm bl001 settings
	if(~sequencer_type_index[~track_index] == 2, {
		switch(note,
			61, { { ~srm_bl001_bassline_velocity_knobs[~track_index].increment }.defer },
			51, { { ~srm_bl001_bassline_velocity_knobs[~track_index].decrement }.defer },
			62, { { ~srm_bl001_front_weight_knobs[~track_index].increment }.defer },
			52, { { ~srm_bl001_front_weight_knobs[~track_index].decrement }.defer },
			63, { { ~srm_bl001_note_probability_knobs[~track_index].increment }.defer },
			53, { { ~srm_bl001_note_probability_knobs[~track_index].decrement }.defer },
			64, { { ~srm_bl001_accent_probabilty_knobs[~track_index].increment }.defer },
			54, { { ~srm_bl001_accent_probabilty_knobs[~track_index].decrement }.defer },
			65, { { ~srm_bl001_accent_intensity_knobs[~track_index].increment }.defer },
			55, { { ~srm_bl001_accent_intensity_knobs[~track_index].decrement }.defer },
			66, { { ~srm_bl001_slide_probability_knobs[~track_index].increment }.defer },
			56, { { ~srm_bl001_slide_probability_knobs[~track_index].decrement }.defer },
		);
	});

	// sting64 settings
	if(~sequencer_type_index[~track_index] == 3, {
		switch(note,
			61, { { ~sting_density_knobs[~track_index].increment }.defer },
			51, { { ~sting_density_knobs[~track_index].decrement }.defer },
			62, { { ~sting_type_knobs[~track_index].increment }.defer },
			52, { { ~sting_type_knobs[~track_index].decrement }.defer },
			63, { { ~sting_mutation_knobs[~track_index].increment }.defer },
			53, { { ~sting_mutation_knobs[~track_index].decrement }.defer },
		);
	});

	// global controls
	if( (note>11).and(note<18), {
		var track_index = note-12;
		{ ~sequencer_regen_buttons[track_index].valueAction_(1) }.defer;
	});
	if( (note>21).and(note<28), {
		var track_index = note-22;
		switch(~synth_indices[track_index],
			0, { { ~anushri_regen_buttons[track_index].valueAction_(1) }.defer },
			1, { { ~sh101_regen_buttons[track_index].valueAction_(1) }.defer },
			2, { { ~buchla_regen_buttons[track_index].valueAction_(1) }.defer },
			3, { { ~juno6_regen_buttons[track_index].valueAction_(1) }.defer },
			4, { { ~alpha_juno_regen_buttons[track_index].valueAction_(1) }.defer },
			5, { { ~megafm_regen_buttons[track_index].valueAction_(1) }.defer },
			6, { { ~modal_regen_buttons[track_index].valueAction_(1) }.defer },
			7, { { ~sampler_regen_buttons[track_index].valueAction_(1) }.defer },
		)
	});
	if( (note>31).and(note<38), {
		var track_index = note-32;
		if(~macro_index == 0, {
			switch(~synth_indices[track_index],
				0, { { ~anushri_macro_knobs1[track_index].decrement }.defer },
				1, { { ~sh101_macro_knobs1[track_index].decrement }.defer },
				2, { { ~buchla_macro_knobs1[track_index].decrement }.defer },
				3, { { ~juno6_macro_knobs1[track_index].decrement }.defer },
				4, { { ~alpha_juno_macro_knobs1[track_index].decrement }.defer },
				5, { { ~megafm_macro_knobs1[track_index].decrement }.defer },
				6, { { ~modal_macro_knobs1[track_index].decrement }.defer },
				7, { { ~sampler_macro_knobs1[track_index].decrement }.defer },
			);
		}, {
			switch(~synth_indices[track_index],
				0, { { ~anushri_macro_knobs2[track_index].decrement }.defer },
				1, { { ~sh101_macro_knobs2[track_index].decrement }.defer },
				2, { { ~buchla_macro_knobs2[track_index].decrement }.defer },
				3, { { ~juno6_macro_knobs2[track_index].decrement }.defer },
				4, { { ~alpha_juno_macro_knobs2[track_index].decrement }.defer },
				5, { { ~megafm_macro_knobs2[track_index].decrement }.defer },
				6, { { ~modal_macro_knobs2[track_index].decrement }.defer },
				7, { { ~sampler_macro_knobs2[track_index].decrement }.defer },
			);
		});
	});
	if( (note>41).and(note<48), {
		var track_index = note-42;
		if(~macro_index == 0, {
			switch(~synth_indices[track_index],
				0, { { ~anushri_macro_knobs1[track_index].increment }.defer },
				1, { { ~sh101_macro_knobs1[track_index].increment }.defer },
				2, { { ~buchla_macro_knobs1[track_index].increment }.defer },
				3, { { ~juno6_macro_knobs1[track_index].increment }.defer },
				4, { { ~alpha_juno_macro_knobs1[track_index].increment }.defer },
				5, { { ~megafm_macro_knobs1[track_index].increment }.defer },
				6, { { ~modal_macro_knobs1[track_index].increment }.defer },
				7, { { ~sampler_macro_knobs1[track_index].increment }.defer },
			);
		}, {
			switch(~synth_indices[track_index],
				0, { { ~anushri_macro_knobs2[track_index].increment }.defer },
				1, { { ~sh101_macro_knobs2[track_index].increment }.defer },
				2, { { ~buchla_macro_knobs2[track_index].increment }.defer },
				3, { { ~juno6_macro_knobs2[track_index].increment }.defer },
				4, { { ~alpha_juno_macro_knobs2[track_index].increment }.defer },
				5, { { ~megafm_macro_knobs2[track_index].increment }.defer },
				6, { { ~modal_macro_knobs2[track_index].increment }.defer },
				7, { { ~sampler_macro_knobs2[track_index].increment }.defer },
			);
		});
	});
	if(note == 48, {
		~macro_index = 0;
	});
	if(note == 38, {
		~macro_index = 1;
	});
	~update_lppro.value;

}, srcID: MIDIClient.sources.detect { |all| all.device.containsi("LPProMK3 MIDI") }.uid);

~global_page = false;

MIDIdef.cc(\LPPro_cc, {
	arg val, cc, chan, src;

	[val, cc, chan, src].postln;

	if(val == 127, {
		~global_page = cc == 10;
		switch(cc,

			// left side buttons
			80, {
				{ ~sequencer_regen_buttons[~track_index].valueAction_(1) }.defer;
			},
			70, {
				{ ~sequencer_type_buttons[~track_index][0].valueAction_(1) }.defer;
			},
			60, {
				{ ~sequencer_type_buttons[~track_index][1].valueAction_(1) }.defer;
			},
			50, {
				{ ~sequencer_type_buttons[~track_index][2].valueAction_(1) }.defer;
			},
			40, {
				{ ~sequencer_type_buttons[~track_index][3].valueAction_(1) }.defer;
			},

			// right side buttons
			89, {
				{ ~synth_type_buttons[~track_index][0].valueAction_(1) }.defer;
			},
			79, {
				{ ~synth_type_buttons[~track_index][1].valueAction_(1) }.defer;
			},
			69, {
				{ ~synth_type_buttons[~track_index][2].valueAction_(1) }.defer;
			},
			59, {
				{ ~synth_type_buttons[~track_index][3].valueAction_(1) }.defer;
			},
			49, {
				{ ~synth_type_buttons[~track_index][4].valueAction_(1) }.defer;
			},
			39, {
				{ ~synth_type_buttons[~track_index][5].valueAction_(1) }.defer;
			},
			29, {
				{ ~synth_type_buttons[~track_index][6].valueAction_(1) }.defer;
			},
			19, {
				{ ~synth_type_buttons[~track_index][7].valueAction_(1) }.defer;
			},

			// top buttons
			92, {
				{ ~track_buttons[0].valueAction_(1) }.defer;
			},
			93, {
				{ ~track_buttons[1].valueAction_(1) }.defer;
			},
			94, {
				{ ~track_buttons[2].valueAction_(1) }.defer;
			},
			95, {
				{ ~track_buttons[3].valueAction_(1) }.defer;
			},
			96, {
				{ ~track_buttons[4].valueAction_(1) }.defer;
			},
			97, {
				{ ~track_buttons[5].valueAction_(1) }.defer;
			},

			// bottom buttons
			101, {
				switch(~synth_indices[~track_index],
					0, { { ~anushri_page_buttons    [~track_index][0].valueAction_(1); }.defer; },
					1, { { ~sh101_page_buttons      [~track_index][0].valueAction_(1); }.defer; },
					2, { { ~buchla_page_buttons     [~track_index][0].valueAction_(1); }.defer; },
					3, { { ~juno6_page_buttons      [~track_index][0].valueAction_(1); }.defer; },
					4, { { ~alpha_juno_page_buttons [~track_index][0].valueAction_(1); }.defer; },
					5, { { ~megafm_page_buttons     [~track_index][0].valueAction_(1); }.defer; },
					6, { { ~modal_page_buttons      [~track_index][0].valueAction_(1); }.defer; },
					7, { { ~sampler_page_buttons    [~track_index][0].valueAction_(1); }.defer; },
				);
			},
			102, {
				switch(~synth_indices[~track_index],
					0, { { ~anushri_page_buttons    [~track_index][1].valueAction_(1); }.defer; },
					1, { { ~sh101_page_buttons      [~track_index][1].valueAction_(1); }.defer; },
					2, { { ~buchla_page_buttons     [~track_index][1].valueAction_(1); }.defer; },
					3, { { ~juno6_page_buttons      [~track_index][1].valueAction_(1); }.defer; },
					4, { { ~alpha_juno_page_buttons [~track_index][1].valueAction_(1); }.defer; },
					5, { { ~megafm_page_buttons     [~track_index][1].valueAction_(1); }.defer; },
					6, { { ~modal_page_buttons      [~track_index][1].valueAction_(1); }.defer; },
					7, { { ~sampler_page_buttons    [~track_index][1].valueAction_(1); }.defer; },
				);
			},
			103, {
				switch(~synth_indices[~track_index],
					0, { { ~anushri_page_buttons    [~track_index][2].valueAction_(1); }.defer; },
					1, { { ~sh101_page_buttons      [~track_index][2].valueAction_(1); }.defer; },
					2, { { ~buchla_page_buttons     [~track_index][2].valueAction_(1); }.defer; },
					3, { { ~juno6_page_buttons      [~track_index][2].valueAction_(1); }.defer; },
					4, { { ~alpha_juno_page_buttons [~track_index][2].valueAction_(1); }.defer; },
					5, { { ~megafm_page_buttons     [~track_index][2].valueAction_(1); }.defer; },
				);
			},
			104, {
				switch(~synth_indices[~track_index],
					0, { { ~anushri_page_buttons    [~track_index][3].valueAction_(1); }.defer; },
				);
			},

		);
	});
	~update_lppro.value;

}, srcID: MIDIClient.sources.detect { |all| all.device.containsi("LPProMK3 MIDI") }.uid);