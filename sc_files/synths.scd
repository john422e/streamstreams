(
// need to incoporate this into the block below for bufs
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
/*
this block adds all synthDefs to server,
loads data and stores in an array ~depthData (3 depths),
instantiates 8 synths (2 at each depth + 2 bufs)
and stores in an array ~synths[0..3]
*/


// SYNTHS --------------------------------------------------------------------------------------------
// get all freq data from files and build synths
var size = 26;
var cwd = PathName.new(thisProcess.nowExecutingPath).parentPath;
var dataDir = cwd ++ "../"; // update this for perf bundle


// SYNTH DEFS
SynthDef.new(\bufPlay, {
	arg buf=0, rate=1, trigRate=1, iphase=0, width=0.5, t_trig, startPos=0, loop=0, da=2, amp=0.5, pan=0, out=0;
	var trig, env, sig, pulseEnv, time=0.05;

	env = EnvGen.kr( Env.asr(0.01, 1.0, 0.01), \gate.kr(0));

	// set width to 1 for sustain, 0-1 for on/off
	trig = LFPulse.kr(trigRate, iphase, width);

	// build env
	pulseEnv = EnvGen.kr( Env.asr(time, 1, time),
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
	sig = sig * amp * pulseEnv;
	sig = Pan2.ar(sig, pan) * env;
	Out.ar(out, sig);
}).add;

SynthDef.new(\sinBank8, {
	arg iphase=0, width=0.5, t_trig, pulse=0;
	var size=8, env, sig, freqs, amps, phases, trig, trigRate, pulseEnv, widthPulse, time=0.05;
	freqs = Array.fill(size, { 440 } );
	amps = Array.fill(size, { 1/size } );
	phases = Array.fill(size, { arg i; i.mod(2pi) } );
	//does this work better? : Array.fill( size, { arg i; (i*rrand(-1.0, 1.0)).mod(2pi) })
	// amp env
	env = EnvGen.kr( Env.asr(0.01, 1.0, 0.01), \gate.kr(0));
	// pulse Ugens
	trigRate = LFNoise0.kr(0.2).linlin(-1, 1, 0.5, 3); // get new value every 0.2 s
	width = LFClipNoise.kr(0.2).linlin(-1, 1, 0.5, 1); // either 0.5 or 1
	trig = LFPulse.kr( trigRate, iphase, width);
	pulseEnv = EnvGen.kr( Env.asr(time, 1, time), gate: trig);
	// apply pulse
	// signal
	sig = DynKlang.ar( `[ \freqs.kr(freqs), \amps.kr(amps), \phases.kr(phases) ] );
	// select with or without amp pulse
	sig = Select.ar(pulse, [ sig, sig * pulseEnv ]);
	// EQ
	sig = BLowShelf.ar(sig, 100, 1.0, 3);
	sig = BHiShelf.ar(sig, 200, rs: 0.5, db: -2);
	sig = BHiShelf.ar(sig, 300, rs: 0.1, db: -2);
	sig = BHiShelf.ar(sig, 400, rs: 0.1, db: -1);
	sig = BHiShelf.ar(sig, 600, rs: 0.2, db: -3);

	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.1)) * env;
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef.new(\sinBank64, {
	arg iphase=0, width=0.5, t_trig, pulse=0;
	var size=64, env, sig, freqs, amps, phases, trig, trigRate, pulseEnv, widthPulse, time=0.05;
	freqs = Array.fill(size, { 440 } );
	amps = Array.fill(size, { 1/size } );
	phases = Array.fill(size, { arg i; i.mod(2pi) } );
	//does this work better? : Array.fill( size, { arg i; (i*rrand(-1.0, 1.0)).mod(2pi) })
	//phases = Array.fill( size, { arg i; (i*rrand(-1.0, 1.0)).mod(2pi) });
	// amp env
	env = EnvGen.kr( Env.asr(0.01, 1.0, 0.01), \gate.kr(0));
	// pulse Ugens
	trigRate = LFNoise0.kr(0.2).linlin(-1, 1, 0.5, 3); // get new value every 0.2 s
	width = LFClipNoise.kr(0.2).linlin(-1, 1, 0.5, 1); // either 0.5 or 1
	trig = LFPulse.kr( trigRate, iphase, width);
	pulseEnv = EnvGen.kr( Env.asr(time, 1, time), gate: trig);
	// apply pulse
	// signal
	sig = DynKlang.ar( `[ \freqs.kr(freqs), \amps.kr(amps), \phases.kr(phases) ] );
	// select with or without amp pulse
	sig = Select.ar(pulse, [ sig, sig * pulseEnv ]);
	// EQ
	sig = BLowShelf.ar(sig, 100, 1.0, 3);
	sig = BHiShelf.ar(sig, 200, rs: 0.5, db: -2);
	sig = BHiShelf.ar(sig, 300, rs: 0.1, db: -2);
	sig = BHiShelf.ar(sig, 400, rs: 0.1, db: -1);
	sig = BHiShelf.ar(sig, 600, rs: 0.2, db: -3);

	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.1)) * env;
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef.new(\sinBank512, {
	arg iphase=0, width=0.5, t_trig, pulse=0;
	var size=512, env, sig, freqs, amps, phases, trig, trigRate, pulseEnv, widthPulse, time=0.05;
	freqs = Array.fill(size, { 440 } );
	amps = Array.fill(size, { 1/size } );
	phases = Array.fill(size, { arg i; i.mod(2pi) } );
	//does this work better? : Array.fill( size, { arg i; (i*rrand(-1.0, 1.0)).mod(2pi) })
	// amp env
	env = EnvGen.kr( Env.asr(0.01, 1.0, 0.01), \gate.kr(0));
	// pulse Ugens
	trigRate = LFNoise0.kr(0.2).linlin(-1, 1, 0.5, 3); // get new value every 0.2 s
	width = LFClipNoise.kr(0.2).linlin(-1, 1, 0.5, 1); // either 0.5 or 1
	trig = LFPulse.kr( trigRate, iphase, width);
	pulseEnv = EnvGen.kr( Env.asr(time, 1, time), gate: trig);
	// apply pulse
	// signal
	sig = DynKlang.ar( `[ \freqs.kr(freqs), \amps.kr(amps*2)] );
	// select with or without amp pulse
	sig = Select.ar(pulse, [ sig, sig * pulseEnv ]);
	// EQ
	sig = BLowShelf.ar(sig, 100, 1.0, 3);
	sig = BHiShelf.ar(sig, 200, rs: 0.5, db: -2);
	sig = BHiShelf.ar(sig, 300, rs: 0.1, db: -2);
	sig = BHiShelf.ar(sig, 400, rs: 0.1, db: -1);
	sig = BHiShelf.ar(sig, 600, rs: 0.2, db: -3);

	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.1)) * env;
	Out.ar(\out.kr(0), sig);
}).add;

// DATA
~depth1Data = Array.fill( size, {
	arg i;
	var fn, subdirectory = dataDir ++ "analyses8/peaks/csv/", raw, freqs, amps;
	fn = subdirectory ++ "m" ++ (i+1).asString ++ ".csv";
	//fn.postln;
	raw = CSVFileReader.read(fn).collect(_.collect(_.interpret));
	freqs = raw[0];
	amps = raw[2];
	[freqs, amps];
});
~depth2Data = Array.fill( size, {
	arg i;
	var fn, subdirectory = dataDir ++ "analyses64/peaks/csv/", raw, freqs, amps;
	fn = subdirectory ++ "m" ++ (i+1).asString ++ ".csv";
	//fn.postln;
	raw = CSVFileReader.read(fn).collect(_.collect(_.interpret));
	freqs = raw[0];
	amps = raw[2];
	[freqs, amps];
});
~depth3Data = Array.fill( size, {
	arg i;
	var fn, subdirectory = dataDir ++ "analyses512/peaks/csv/", raw, freqs, amps;
	fn = subdirectory ++ "m" ++ (i+1).asString ++ ".csv";
	//fn.postln;
	raw = CSVFileReader.read(fn).collect(_.collect(_.interpret));
	freqs = raw[0];
	amps = raw[2];
	[freqs, amps];
});

~depthData = [~depth1Data, ~depth2Data, ~depth3Data];

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