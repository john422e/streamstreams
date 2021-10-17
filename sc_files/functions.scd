(
// FUNCTIONS

// display stuff
// function to update view background color
~getColors = {
	/*
	returns an array of two color vals, 0 = card background, 1 = dot color
	*/
	var rgbs=[
		[152, 170, 161], // grey/green
		[89, 84, 34], // moss green
		[104, 99, 64], // olive green *****
		[112, 98, 93], // slate ******
		[165, 108, 84], // brown leafy

		[243, 251, 255], // icy white
		[138, 152, 171], // icy blue
		[168, 184, 215], // sky blue
		[150, 142, 136], // icy grey
	];
	var cardRGBs, dotRGBs, cardColor, dotColor, touch4color;
	//cardColor=rgbs.choose, dotColor=cardColor.copy, hueAlter=rrand(0,2);
	if( rrand(0, 1) == 0,
		{
			cardRGBs = rgbs[0..4];
			dotRGBs = rgbs[5..8];
		},
		{
			cardRGBs = rgbs[5..8];
			dotRGBs = rgbs[0..4];
		}
	);
	cardColor = cardRGBs.choose;
	dotColor = dotRGBs.choose;
	if( dotColor == dotRGBs[0],
		{ touch4color = dotRGBs[3] },
		{ touch4color = dotRGBs[dotRGBs.indexOf(dotColor)-1] }
	);
	//touch4color = dotRGBs.choose;
	//[cardRGBs, dotRGBs].postln;
	//["COLORS", cardColor, dotColor, touch4color].postln;
	/*
	// make dot darker
	dotColor[hueAlter] = dotColor[hueAlter] * rrand(0.2, 2.0);
	if( dotColor[hueAlter] > 255,
		{ dotColor[hueAlter] * rrand(0.2, 0.9) }); // other direction
	*/
	[cardColor, dotColor, touch4color]; // return
};

~setViewColor = {
	arg view, color;
	// set view color
	view.background_(Color.new255(color[0], color[1], color[2]));
};


// chord stuff/file handling
~setCurrentDepth = {
	/*
	random 1-3
	*/
	rrand(1, 3);
};

~getRandomPair = {
	/*
	accepts an array with at least two vals at each index
	randomly selects an index and returns an array with the first value at i=0 and the remaining values in an array at i=1
	if limit == true, returns an array of [location1, location2, [locationsList] (where locations list is an array of size x including location2 (but not location1))
	else, returns an array of [location1, [location1matches]]
	*/
	arg pairArray, limit=false, locationOptions=2; // size of locationsOptions will be +1 including location2
	var return, matches, location1, location2, locations, compList; // compList includes location2 and
	var randSeed = pairArray.choose, fn;

	//randSeed = pairArray[25]; // FOR TESTING ONLY
	locations = (1..pairArray.size); // a list of locations so that a sublist excluding location1 and all its matches can be generated
	location1 = randSeed[0];
	// list of matches for location1
	matches = randSeed.copyRange(1, randSeed.size);


	//locationsIndexes.postln;
	if( limit == true,
		{
			location2 = matches.choose;
			//location2 = matches[1]; // FOR TESTING ONLY
			locations.remove(location1); // remove location1
			//randSeed.postln;
			matches.do( { arg match; locations.remove(match) }); // remove each match
			// now make a list of size <locationOptions> for sublist
			compList = [location2];
			locationOptions.do( {
				var choice;
				choice = locations.choose;
				compList.add(choice);
				locations.remove(choice);
			});
			compList = compList.scramble; // scramble order
			return = [location1, location2, compList] },
		{ return = [randSeed[0], matches] }
	);

	//["LOC1", location1, "LOC2", location2, ].postln;
	//pairArray.postln;

	return;
};

~getSpecificPair = {
	/*
	accepts an array with at least two vals at each index and a specified index to select for
	returns an array at that index (i=0) with the additional values at i=1
	*/
	arg i, pairArray;
	[pairArray[i-1][0], pairArray[i-1].copyRange(1, pairArray[i-1].size)];
};

~getFileName = {
	/*
	accepts an array of two integers and a depth argument (1, 2, or 3) and returns the appropriate .csv filename with freqs for cello chords
	*/
	arg pair, depth, parentPath;
	var fn, subPath;
	fn = "../analyses";
	switch (depth,
		1, { fn = fn ++ "8/" },
		2, { fn = fn ++ "64/" },
		3, { fn = fn ++ "512/" }
	);
	fn = fn +/+ "cello_chords/m%_m%.csv".format(pair[0], pair[1]);
	fn = parentPath +/+ fn;
	//fn = PathName.new(thisProcess.nowExecutingPath).parentPath +/+ fn;
	fn;
};

~getChordsFromFile = {
	/*
	accepts an array of two integers and a depth argument (1, 2, or 3) to get the appropriate .csv file with freqs for cello chords
	reads in the file and returns a chord (randomly selected)
	*/
	arg pair, depth, parentPath;
	var fn, notes, groups, groupNum;
	fn = ~getFileName.value(pair, depth, parentPath);
	//fn.postln;
	//fn = "/Users/johneagle/projects/music/COMP/still_life/new_architecture/fall_creek_gorge_inlet/analyses8/cello_chords/m1_m14.csv";
	// get the raw data from file
	notes = CSVFileReader.readInterpret(fn, skipEmptyLines: true);
	// array to store parsed data in
	groups = Array.fill(notes.size/4, { Array.new(4) }); // include a subarray for each string within each group
	groupNum = 0; // iterator for going through groups
	// iterate through and store organized data in groups
	notes.do( {
		arg freqs, i;
		var stringNum = i.mod(4);
		groups[groupNum].add(freqs);
		if( stringNum == 3, { groupNum = groupNum + 1 }); // increment groupNum
	});
	groups.choose; // select a group at random and return it
};
)