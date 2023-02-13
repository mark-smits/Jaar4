SequencerUIPrototype {

	// class variables
    classvar
	nothing;
	// variables
	var
	testDict,
	// UI objects
	window,
	pageButtons,
	pagenr = 0,
	pageCompositeViews,
	page,
	mockupTextBoxes,

	// zooi om over te hevelen van de huidige UI implementatie
	text,
	compositeViews,
	sliders,
	plotters,
	knobViews,
	knobLists,
	labelLists,
	knobVals,

	// sizing params
	plotHeight = 75, plotWidth = 250,
	titleHeight = 20, titleWidth = 250,
	knobSize = 35,
	labelHeight = 20, labelWidth = 35,
	plotSpacing = 10, globalMargin = 10,
	// colors
	activeColor, inactiveColor, stepColor,
	bipolarPositiveColor1, bipolarNegativeColor1,
	bipolarPositiveColor2, bipolarNegativeColor2,
	articulationColor1, articulationColor2, articulationColor3,
	probabilityActiveColor, probabilityInactiveColor, colorLists;

	// init funcs
	*initClass {
		// Initializations on class level (e.g. to set up classvars)

	}

	init {
		// initialize parameters
		knobVals = 0.5!4!6;

		window = Window("New UI", Rect(20, 30, 540, 680));
		GUI.skin.plot.background = Color.black;
		GUI.skin.plot.gridColorX = Color.new(alpha: 0.0);
		GUI.skin.plot.gridColorY = Color.new(alpha: 0.0);
		GUI.skin.plot.fontColor = Color.new(alpha: 0.0);

		pageButtons = [];
		6.do({
			|index|
			pageButtons = pageButtons ++ Button(window, Rect(index * 60 + 15, 15, 50, 20));
			pageButtons[index].action = { arg butt;
				pagenr = index;
				page.visible = false;
				page = pageCompositeViews.at(pagenr);
				page.visible = true;
				pagenr.postln;
			};
		});

		pageCompositeViews = Array.fill(6, { arg index; var compView, colors;
			colors = [Color.red, Color.green, Color.blue, Color.yellow, Color.cyan, Color.magenta];
			compView = CompositeView(window, Rect(15, 45, 510, 620));
			compView.background = colors[index]; // this doesn't work yet
			compView.visible = false;
			compView;
		});
		page = pageCompositeViews[0];
		page.visible = true;

		mockupTextBoxes = [];
		5.do({
			|index|
			mockupTextBoxes = mockupTextBoxes ++ TextView(pageCompositeViews[index+1], Rect(
				0,
				0,
				150,
				50
			));
			mockupTextBoxes[index].setString("page " ++ index.asString);
		});

		this.initPage1;
		knobVals.postln;

		window.front;
		window.refresh;
	}

	passDict {
		arg dict;
		testDict = dict;
		testDict.put(\testvar, 1);
	}

	// getters

	// setters

}