s.boot;
s.quit;

(
Server.default.options.inDevice_("John's Airpods P");
Server.default.options.outDevice_("John's Airpods P");
)



/*
TO DO:
1. TRy a new synth def with a task (inside or outside the synth?) that triggers envelope on/off rather than LFPulse
1. clean shit up
2. group the samples, then decide whether to cut them down or have a random subselection

FORM: A B A' (where A is some depth, B is just listening to raw samples, A is some different depth
*/

(
// SYNTHS --------------------------------------------------------------------------------------------
SynthDef.new(\bufPlay, {
	arg buf=0, rate=1, trigRate=1, iphase=0, width=0.5, t_trig, startPos=0, loop=0, da=2, amp=0.5, pan=0, out=0;
	var trig, sig, env, time=0.05;

	// need to wrap this whole thing in another Env with gate arg for toggling on/off rather than using amp



	// set width to 1 for sustain, 0-1 for on/off
	trig = LFPulse.kr(trigRate, iphase, width);

	// build env
	env = EnvGen.kr( Env.asr(time, 1, time),
		gate: trig
		);
	sig = PlayBuf.ar(
		1, // mono
		buf,
		BufRateScale.ir(buf) * rate,
		t_trig=t_trig,
		startPos,
		loop,
		da
		);
	sig = sig * amp * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\sinBank8, {
	var size=8, sig, freqs, amps, phases;
	freqs = Array.fill(size, { 440 } );
	amps = Array.fill(size, { 1/size } );
	phases = Array.fill(size, { arg i; i.mod(2pi) } );
	//does this work better? : Array.fill( size, { arg i; (i*rrand(-1.0, 1.0)).mod(2pi) })
	sig = DynKlang.ar( `[ \freqs.kr(freqs), \amps.kr(amps), \phases.kr(phases) ] );
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef.new(\sinBank64, {
	var size=64, sig, freqs, amps, phases;
	freqs = Array.fill(size, { 440 } );
	amps = Array.fill(size, { 1/size } );
	phases = Array.fill(size, { arg i; i.mod(2pi) } );
	//does this work better? : Array.fill( size, { arg i; (i*rrand(-1.0, 1.0)).mod(2pi) })
	sig = DynKlang.ar( `[ \freqs.kr(freqs), \amps.kr(amps), \phases.kr(phases) ] );
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef.new(\sinBank512, {
	var size=512, sig, freqs, amps, phases;
	freqs = Array.fill(size, { 440 } );
	amps = Array.fill(size, { 1/size } );
	phases = Array.fill(size, { arg i; i.mod(2pi) } );
	//does this work better? : Array.fill( size, { arg i; (i*rrand(-1.0, 1.0)).mod(2pi) })
	sig = DynKlang.ar( `[ \freqs.kr(freqs), \amps.kr(amps), \phases.kr(phases) ] );
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5));
	Out.ar(\out.kr(0), sig);
}).add;

)


(
// set audio filenames and read them all into buffers
var init, audioDir, bufTotal=26, bufPlayers=Array.new(bufTotal);
Buffer.freeAll;

~buffers=Array.new(bufTotal);

// audio directory
audioDir = PathName.new(PathName.new(thisProcess.nowExecutingPath).parentPath ++ "../audio/trimmed/shotgun/normalized");

// a routine to read in all the audio files
init = Routine.new( {
	~buffers = audioDir.entries.collect( {
		arg filename;
		Buffer.read(s, filename.fullPath);
	});
	s.sync;

}).play;
)

(
// get all freq data from files and build synths
var size = 26;
var cwd = PathName.new(thisProcess.nowExecutingPath).parentPath;
var dataDir = cwd ++ "../"; // update this for perf bundle
var depth1Data;

~depthState = 1; // 1-4 (no 0 index)
~leftPos = 0; // min to max buffs (right now 26, 0-25)
~rightPosition = 0;

~depth1Data = Array.fill( size, {
	arg i;
	var fn, subdirectory = dataDir ++ "analyses8/peaks/csv/", raw, freqs, amps;
	fn = subdirectory ++ "m" ++ (i+1).asString ++ ".csv";
	fn.postln;
	raw = CSVFileReader.read(fn).collect(_.collect(_.interpret));
	freqs = raw[0];
	amps = raw[2];
	[freqs, amps];
});
~depth2Data = Array.fill( size, {
	arg i;
	var fn, subdirectory = dataDir ++ "analyses64/peaks/csv/", raw, freqs, amps;
	fn = subdirectory ++ "m" ++ (i+1).asString ++ ".csv";
	fn.postln;
	raw = CSVFileReader.read(fn).collect(_.collect(_.interpret));
	freqs = raw[0];
	amps = raw[2];
	[freqs, amps];
});
~depth3Data = Array.fill( size, {
	arg i;
	var fn, subdirectory = dataDir ++ "analyses512/peaks/csv/", raw, freqs, amps;
	fn = subdirectory ++ "m" ++ (i+1).asString ++ ".csv";
	fn.postln;
	raw = CSVFileReader.read(fn).collect(_.collect(_.interpret));
	freqs = raw[0];
	amps = raw[2];
	[freqs, amps];
});

// BUILD SYNTHS (2 per each depth)
~depth1synths = 2.collect( {
	arg chan;
	var pan, width, iphase, synth;
	if( chan==0, { pan = -1 }, { pan = 1 });
	// need to add functionality in synth for amp modulator and then add logic for width and iphase above and below
	synth = Synth.new(\sinBank8);
	synth.set(\pan, pan);
	synth;
});

~depth2synths = 2.collect( {
	arg chan;
	var pan, width, iphase, synth;
	if( chan==0, { pan = -1 }, { pan = 1 });
	// need to add functionality in synth for amp modulator and then add logic for width and iphase above and below
	synth = Synth.new(\sinBank64);
	synth.set(\pan, pan);
	synth;
});

~depth3synths = 2.collect( {
	arg chan;
	var pan, width, iphase, synth;
	if( chan==0, { pan = -1 }, { pan = 1 });
	// need to add functionality in synth for amp modulator and then add logic for width and iphase above and below
	synth = Synth.new(\sinBank64);
	synth.set(\pan, pan);
	synth;
});

// initialize 2 bufPlayers (1 left, 1 right)
~bufPlayers = 2.collect( {
	arg chan;
	var pan, width, iphase;
	if( chan==0, { pan = -1; width = 1; iphase = 0 }, { pan = 1; width = 1; iphase = 0.5 } );
	Synth.new(\bufPlay, [
		\buf, 0,
		\t_trig, 1,
		\loop, 1,
		\pan, pan,
		\iphase, iphase,
		\width, width,
		\amp, 0.9
	]);
});

~synths = [~depth1synths, ~depth2synths, ~depth3synths, ~bufPlayers]; // each object is an array of 2 synths
)

(
// HID STUFF ------------------------------------------
var leftKey=123, rightKey=124, xKey=7, oKey=31, pedalLeft=126, pedalRight=125;
var bufTotal=26; // will merge this block with above--get rid of redundant variables
var onOffKey=31, onOff = Pseq( [0, 0.9], inf).asStream;
var oneKey=18, twoKey=19, threeKey=20, fourKey=21;

var toggleLeft=0, toggleRight=2; // keep these?
var minRate = 1.5, maxRate = 7.5;
var leftPulse=1, rightPulse=1, leftRate, rightRate; // trying this instead of using pattern (so not stuck on event clock)
//var pulseSeqLeft = Pseq( [0.5, 1], inf).asStream;
//var pulseSeqRight = Pseq( [0.5, 1], inf).asStream;

var wWidth=200, wHeight=200;
var title="TEST";

// build window
Window.closeAll;
w = Window(title, Rect(0, 200, wWidth, wHeight))
.front
.alwaysOnTop_(true);


w.view.keyDownAction = {
	arg view, char, modifiers, unicode, keycode;
	//[char, modifiers, unicode, keycode].postln;
	["KEY:", keycode].postln;
	// LEFT cycles forwards through channel 0, RIGHT through channel 1 (wrapping around each time)
	if( (keycode == leftKey or:{ keycode == pedalLeft}), {
		"LEFT".postln; // set left channel ( index 0 )
		// turn off current synth or buffer
		if( ~depthState == 4, { ~synths[~depthState][0].set(\amp, 0) }, {~synths[~depthState][0].set(\gate, 0)});
		// advance position
		if( ~leftPos == (bufTotal-1),
			{ ~leftPos - 0 }, // reset to 0
			{ ~leftPos = ~leftPos + 1 }
		);
		// turn on new synth or buffer
		switch ( ~depthState,
			1, {~synths[~depthState][0].set(\freqs, ~depth1Data[~leftPos], \amps, ~depth1Data[~leftPos], \gate, 1)},
			2, {~synths[~depthState][0].set(\freqs, ~depth2Data[~leftPos], \amps, ~depth2Data[~leftPos], \gate, 1)},
			3, {~synths[~depthState][0].set(\freqs, ~depth3Data[~leftPos], \amps, ~depth3Data[~leftPos], \gate, 1)},
			4, {~synths[~depthState][0].set(\buf, ~buffers[~leftPos], \amp, 0.9)}
		);


		// INSERT LOGIC HERE FOR CHANGING PULSE WIDTH


	});
	if( (keycode == rightKey or:{ keycode == pedalRight}), {
		"RIGHT".postln;
		// turn off current synth or buffer
		if( ~depthState == 4, { ~synths[~depthState][1].set(\amp, 0) }, {~synths[~depthState][1].set(\gate, 0)});
		// advance position
		if( ~rightPos == (bufTotal-1),
			{ ~rightPos - 0 }, // reset to 0
			{ ~rightPos = ~rightPos + 1 }
		);
		// turn on new synth or buffer
		switch ( ~depthState,
			1, {~synths[~depthState][0].set(\freqs, ~depth1Data[~rightPos], \amps, ~depth1Data[~rightPos], \gate, 1)},
			2, {~synths[~depthState][0].set(\freqs, ~depth2Data[~rightPos], \amps, ~depth2Data[~rightPos], \gate, 1)},
			3, {~synths[~depthState][0].set(\freqs, ~depth3Data[~rightPos], \amps, ~depth3Data[~rightPos], \gate, 1)},
			4, {~synths[~depthState][0].set(\buf, ~buffers[~rightPos], \amp, 0.9)}
		);


		// INSERT LOGIC HERE FOR CHANGING PULSE WIDTH


	});
	if( keycode == toggleLeft, { // 'a'
		"PULSE LEFT".postln;
		//~bufPlayers[0].set(\width, pulseSeqLeft.next);
		if( leftPulse == 1, { leftPulse = 0.5; leftRate = rrand(minRate, maxRate) }, { leftPulse = 1; leftRate = 1 });
		~bufPlayers[0].set(\trigRate, leftRate, \width, leftPulse);

	});
	if( keycode == toggleRight, { // 'd'
		"PULSE RIGHT".postln;
		//~bufPlayers[1].set(\width, pulseSeqRight.next);
		if( rightPulse == 1, { rightPulse = 0.5; rightRate = rrand(minRate, maxRate) }, { rightPulse = 1; rightRate = 1 });
		~bufPlayers[1].set(\trigRate, rightRate, \width, rightPulse);

	});

	// manage depths manually for now
	if( keycode < 22 && keycode > 17, {
		~depthState = keycode - 17; // offset for keycodes 18-21, so they will equal 1-4
		~depthState.postln;
	});

	if( keycode == onOffKey, {
		var soundState = onOff.next;
		// turn all sound on/off
		"MASTER SOUND".postln;
		~bufPlayers[0].set(\amp, soundState);
		~bufPlayers[1].set(\amp, soundState);
	});


	["CURRENT BUFFERS:", leftBuf, rightBuf].postln;
};
)

18 < 22 && 15 > 17;