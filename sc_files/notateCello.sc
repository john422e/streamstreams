// adjust buff gain - 168, 169
// sinBank512 - 156

// first load functions (functions.scd)
// do this second (boot server)
(
s = Server.local;
o = Server.default.options;
o.numOutputBusChannels = 8;
s.options.sampleRate_(48000);
s.options.memSize_(2.pow(20)); // roughly a gig of memory
// cleanup
s.newBusAllocators;
ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;

s.options.inDevice_(
	//"BlackHole 16ch"
	//"MacBook Pro Microphone"
	"Scarlett 18i20 USB"
);
s.options.outDevice_(
	//"BlackHole 16ch"
	//"External Headphones"
	//"MacBook Pro Speakers"
	"Scarlett 18i20 USB"
);

s.reboot;
)
// then load buffers and synthdefs (synths.scd)

ServerOptions.devices;


// then start mic
(
~micChan = 5; // set this from interface chan
// run this for live mic on cello
~dpa = Synth.new(\mic2out, [\in, ~micChan, \out1, 2, \out2, 7]);
)
s.meter;


// then this to start! (mute speakers at board)
(
// MUST LOAD functions.scd and synths.scd FIRST
// RECORDING VARS -- UPDATE FOR EACH RECORDING
var logCount = 4, fileLog; // 4 = concert 10.21.21

// display vars
var title = "streams, summed (stream)";
var mainWindow, wWidth=800, wHeight=920, vWidth=(wWidth-200), dView;

var card, colors, cardColor, dotColor, touch4color; // for storing background colors
var label;
var padding=30, stringHeight=700, stringGap=120, stringPad=120;
// HID stuff
var leftKey=123, rightKey=124, pedalLeft=126, pedalRight=125, xKey=7, oKey=31;
// cello info
var vcStrings, vcStringsRange, frets;
// file vars
var cwd = PathName.new(thisProcess.nowExecutingPath).parentPath;
var depth1dir = cwd ++ "../analyses8/", depth2dir = cwd ++ "../analyses64/", depth3dir = cwd ++ "../analyses512/";
var depth1pairs = CSVFileReader.read(depth1dir++"pairs.csv").collect(_.collect(_.interpret));
var depth2pairs = CSVFileReader.read(depth2dir++"pairs.csv").collect(_.collect(_.interpret));
var depth3pairs = CSVFileReader.read(depth3dir++"pairs.csv").collect(_.collect(_.interpret));
var allPairs = [depth1pairs, depth2pairs, depth3pairs];
var currentDepth, currentPair, location1, location2, compList, currentComp, location1peaks, location2peaks, compPeakList, currentFileName, freqs;
// audio stuff
var panPositions, synth1pan, synth2pan, depthAmp;
var stereo=false, buffOut = [3, 5];
//stereo = true;
//stereo = false; // for testing in stereo, set to false for quad
if( stereo, { buffOut = [0, 1] }, { buffOut = [3, 5] });

// START RECORDING
// START RECORDING RIGHT AWAY
r = Recorder(s);
r.recHeaderFormat_('wav');
f = cwd ++ "../recOutput/" ++ Date.getDate.stamp ++ ".wav".postln;
r.record(f, numChannels:8);

// BUILD WINDOW -----------------------------------------------------------------------------------
//Window.closeAll;
mainWindow = Window(title, Rect(0, 200, wWidth, wHeight), resizable: false, scroll: true)
.front
.alwaysOnTop_(false);


mainWindow.onClose_( {
	~synths.do( {
		arg subSynths;
		subSynths.do( {
			arg synth;
			synth.set(\gate, 0);
		});
	});
	r.stopRecording;
	s.quit;
	//~closeFile.("../performanceLogs/log" ++ logCount.asString ++ ".txt");
});
	//r.stopRecording;
	//bufPlayers.do( { arg buf; buf.free });
	//"FILE CLOSED".postln;

// padding + flow layout
mainWindow.view.decorator_(FlowLayout(mainWindow.bounds, 100@10, 100@10));

// make view
dView = UserView(mainWindow, vWidth@(wHeight-20));

// a label, will display pairing info
label = StaticText(dView, Rect(vWidth/2-70, 10, 150, 11)).string_("<PAIRING>")
.font_(Font("Monaco", 14))
.align_(\center);

// cello string data
// tune to A=440 Hz
vcStrings = [ 220, 220/1.5, 220/1.5/1.5, 220/1.5/1.5/1.5];
vcStrings = vcStrings.reverse; // go IV -> I
vcStringsRange = vcStrings.collect( {
	arg freq;
	freq*2; // will display the lowest octave for each string
});
// a "fret" will display at the nut, the fifth, and the octave
frets = [1, 3/2, 2/1];

// INITIALIZATION --------------------------
~setNew = {
	var fn;
	// get random initial colors
	colors = ~getColors.value;
	cardColor = colors[0];
	dotColor = colors[1];
	touch4color = colors[2];

	~setViewColor.value(dView, cardColor);
	// get pairs
	currentDepth = ~setCurrentDepth.value;
	//currentDepth = 1; // FOR TESTING ONLY
	currentPair = ~getRandomPair.(allPairs[currentDepth-1], limit: true);
	location1 = currentPair[0];
	location2 = currentPair[1];
	compList = currentPair[2]; // holds the list of location2 options for matching

	//["STATE", currentDepth, currentPair].postln;
	/*
	to get synth data: (currentDepth, location1, and location2 are NOT zero indexed
	location1peaks = ~depthData[currentDepth-1][location1-1] (0=freqs, 1=amps)
	~synths[currentDepth-1]
	*/
	["LOCATIONS:", currentDepth, location1, location2, compList].postln;

	location1peaks = ~depthData[currentDepth-1][location1-1];
	//location2peaks = ~depthData[currentDepth-1][location2-1]; // make this a list of peak vals instead
	compPeakList = []; // empty list
	compList.do( {
		arg location, i;
		compPeakList = compPeakList.add(~depthData[currentDepth-1][location-1]);
	});
	currentComp = 0;
	//["1 PEAKS:", location1peaks[0]].postln;
	//["2 PEAKS:", location2peaks[0]].postln;
	//["CURRENT DEPTH", currentDepth].postln;
	//currentDepth = 1; // for testing
	//currentPair = [26, 1];

	//["--", currentPair, currentDepth].postln;
	fn = ~getFileName.(currentPair, currentDepth, cwd);
	currentFileName = PathName.new(fn).fileNameWithoutExtension;
	freqs = ~getChordsFromFile.(currentPair, currentDepth, cwd);
	// set pans
	panPositions = [-1, 1];
	synth1pan = panPositions.choose;
	panPositions.remove(synth1pan);
	synth2pan = panPositions.pop;
	// set amp
	switch ( currentDepth,
		1, { depthAmp = 1.0 },
		2, { depthAmp = 0.9 },
		3, { depthAmp = 7.0 }
	);
	// update file
	fileLog = currentFileName ++ ", DEPTH: " ++ currentDepth.asString ++ " " ++ compList.asString;
	//~updateFile.("../performanceLogs/log.txt", "RANDOM STUFF");
	~updateFile.("log" ++ logCount.asString ++ ".txt", fileLog);
	//"SOMETHING ELSE".postln;
};

// first time
~setNew.value;
// location1peaks are stored and can be sent to synth
// compPeakList is holding 3 peakLists to send to synth2

// SET SYNTHS
~synths[currentDepth-1][0].set(\freqs, location1peaks[0], \amps, location1peaks[1], \pan, synth1pan, \amp, depthAmp, \gate, 1);
~synths[currentDepth-1][1].set(\freqs, compPeakList[currentComp][0], \amps, compPeakList[currentComp][1], \pan, synth2pan, \pulse, 1, \amp, depthAmp, \gate, 1); // "LEFT" control cycles through these
// set
~synths[3][0].set(\buf, location1-1, \pan, synth1pan, \out, buffOut[0], \amp, 0.5, \gate, 1);
~synths[3][1].set(\buf, currentComp-1, \pan, synth2pan, \out, buffOut[1], \amp, 0.5, \gate, 1); // chan setup? does it need to be reversed?


// add drawing function for view
dView.drawFunc = {
	var labelString;

	~count = 0;

	// pen settings
	Pen.strokeColor = Color.black;
	Pen.width_(3);

	// draw horizontal frets
	frets.do( {
		arg fret;
		var x=stringPad, xEnd=stringGap*4, y, freq;
		freq = vcStrings[0] * fret;
		y = freq.explin(vcStrings[0], vcStrings[0]*2, padding, padding+stringHeight);
		Pen.moveTo( x@y );
		Pen.lineTo( xEnd@y );
		Pen.fillStroke;
	});

	// update label with pair and depth values
	labelString = currentFileName ++ ", DEPTH: " ++ currentDepth.asString;
	label.string_(labelString);

	// now draw string and finger location
	4.do( {
		arg i;
		var x, y;

		//["RANGE:", vcStrings[i], vcStringsRange[i]].postln;
		//["string" + (4-i)].asString.postln;
		//["string" + i.asString].postln;
		x = (i * stringGap) + stringPad;

		// draw the string
		Pen.fillColor = Color.new255(dotColor[0], dotColor[1], dotColor[2]);
		Pen.strokeColor = Color.black;
		Pen.moveTo( x@padding);
		Pen.lineTo( x@(stringHeight+120+ padding) );
		Pen.fillStroke;

		// draw notes for each string

		freqs[i].do( {
			arg freq;
			var touch4;
			if( freq != 0, { ~count = ~count + 1});
			touch4 = false;
			// check for touch fours here
			if( freq > vcStringsRange[i], {
				touch4 = true;
				freq = freq/4; // display stop location down 2 octaves
			});
			y = freq.explin(vcStrings[i], vcStrings[i]*4, padding, padding+(stringHeight*2)); // VERIFY?

			// draw a circle for finger location IF NOTE
			if( freq != 0, {
				if( touch4,
					{
						//("DRAWING TOUCH4:" + freq.asString).postln;
						Pen.fillColor = Color.new255(touch4color[0], touch4color[1], touch4color[2]);
						Pen.addRect( Rect(x-8, y+8, 16, 16)) },
					{
						//("DRAWING STOPPED" + freq.asString).postln;
						Pen.fillColor = Color.new255(dotColor[0], dotColor[1], dotColor[2]);
						Pen.addArc( x@y, 10, 2pi, 2pi) }
				);
				Pen.perform(\fill);
			});
		});
	});
	//["FREQS:", ~count].postln;
};

// KEY CONTROLS
mainWindow.view.keyDownAction = {
	arg view, char, modifiers, unicode, keycode;
	//[char, modifiers, unicode, keycode].postln;
	//keycode.postln;

	if( (keycode == leftKey or:{ keycode == pedalLeft }), {
		"LEFT, new comparison".postln;
		// cycle through compPeakList options
		// turn off current synths
		~synths[currentDepth-1][1].set(\gate, 0); // chan 2
		~synths[3][1].set(\gate, 0);
		// iterate currentComp (0-2)
		currentComp = currentComp + 1;
		if( currentComp > 2, {currentComp = 0}); // wrap to 0
		// set new freqs/amps and turn on
		//compPeakList[currentComp][0].postln;
		~synths[currentDepth-1][1].set(\freqs, compPeakList[currentComp][0], \amps, compPeakList[currentComp][1], \gate, 1);
		// update buffer and turn on
		~synths[3][1].set(\buf, currentComp-1, \gate, 1);
	});

	if( (keycode == rightKey or:{ keycode == pedalRight }), {
		"RIGHT, new cycle".postln;
		// get new pair/start new cycle
		// turn off current synths
		~synths[currentDepth-1][0].set(\gate, 0); // chan 1
		~synths[currentDepth-1][1].set(\gate, 0); // chan 2
		~synths[3][0].set(\gate, 0);
		~synths[3][1].set(\gate, 0);
		// add for chan 2
		// get new values
		~setNew.value;
		dView.refresh;
		// turn on new synths
		~synths[currentDepth-1][0].set(\freqs, location1peaks[0], \amps, location1peaks[1], \pan, synth1pan, \amp, depthAmp, \gate, 1);
		~synths[currentDepth-1][1].set(\freqs, compPeakList[currentComp][0], \amps, compPeakList[currentComp][1], \pan, synth2pan, \amp, depthAmp, \gate, 1);
		// turn on buffers
		~synths[3][0].set(\buf, location1-1, \pan, synth1pan, \gate, 1);
		~synths[3][1].set(\buf, currentComp-1, \pan, synth2pan, \gate, 1);
		//location1peaks[0].sort.postln;
	});
};



)


~synths[2][1].set(\gate, 1, \amp, 6);

a = [1, 2, 3];
a*2
~depth3Data[5][1].sum;
/* need to check that:
-bufsynths are working
-panning is correct
-cycling is working correctly through comps
to do:
-add pulse behavior to synths
-consolidate synths.scd