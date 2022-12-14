+ SequencerPrototype {

	// functions generating ornamentation information

	calcOrnamentationGraceNoteArray {
		var order;
		ornamentationGraceNoteArray = 0!64!dimensionSize;
		order = (0..15).scramble;
		order = order ++ order.scramble;
		order = order ++ order.scramble;
		(dimensionSize-1).do({
			|index|
			var ratio;
			ratio = (index.asFloat + 1.0)/(dimensionSize-1);
			4.do({
				|index2|
				(ratio*16).asInteger.do({
					|index3|
					ornamentationGraceNoteArray[index+1][ order[index3] + (index2*16) ] = 1;
				});
			});
			/*
			if specific values triggering "specific grace notes" ever gets implemented
			uncomment this
			ornamentationGraceNotesArray[index+1].do({
			arg val, ind;
			ornamentationGraceNotesArray[index+1][ind] = val * [1, 2, 3].choose;
			});
			*/
		});
	}

	calcOrnamentationFigureArray {
		var order;
		ornamentationFigureArray = 0!64!dimensionSize;
		order = (0..15).scramble;
		order = order ++ order.scramble;
		order = order ++ order.scramble;
		(dimensionSize-1).do({
			|index|
			var ratio;
			ratio = (index.asFloat + 1.0)/(dimensionSize-1);
			4.do({
				|index2|
				(ratio*16).asInteger.do({
					|index3|
					ornamentationFigureArray[index+1][ order[index3] + (index2*16) ] = 1;
				});
			});
			/*
			if specific values triggering "specific figures" ever gets implemented
			uncomment this
			ornamentationFiguresArray[index+1].do({
			arg val, ind;
			ornamentationFiguresArray[index+1][ind] = val * [1, 2, 3].choose;
			});
			*/
		});
	}
}