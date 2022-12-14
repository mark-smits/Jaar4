+ SequencerPrototype {

	// functions generating velocity information

	calcTimingArray {
		timingArray = (0..15);
		timingArray = sin(pi * timingArray/16)*timingRubato;
		timingArray.do({
			arg item, index;
			if(index.mod(2) == 1, {
				timingArray[index] = item + timingSwing;
			});
			timingArray[index] = timingArray[index].pow(2.5);
		});
		timingArray = timingArray.clip(0, ( (ppqnResolution/4-1) / (ppqnResolution/4) * 0.9) );
	}
}