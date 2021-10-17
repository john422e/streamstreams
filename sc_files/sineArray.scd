Signal.sineFill(5, 1!5, 0!5).plot;

(
SynthDef.new(\sineBank, {
	var size=50, sig, freqs, amps, phases;
	freqs = Array.fill(size, { 440 } );
	amps = Array.fill(size, { 1/size } );
	phases = Array.fill(size, { arg i; i.mod(2pi) } );
	//does this work better? : Array.fill( size, { arg i; (i*rrand(-1.0, 1.0)).mod(2pi) })
	sig = DynKlang.ar( `[ \freqs.kr(freqs), \amps.kr(amps), \phases.kr(phases) ] );
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5));
	Out.ar(\out.kr(0), sig);
}).add;
)



// AUDIO --------------------------------------------------------------------------------------

// SYNTH DEFS ----------------------------------------------------------------------------------
/* SYNTH STRUCTURE:
1 sinBank8 (Depth 1)
1 sinBank64 (Depth 2)
1 sinBank512 (Depth 3)
8 bufPlays (one for each raw sound file (Depth 4)
bufPlays are gate controlled turning on/off for each station
sinBanks are updated with freqs so each depth works for all stations
*/
// make one synthDef for each depth size
// DEPTH 1
(
SynthDef.new(\sinBank8, {
	arg gate=0, out=0, amp=0.9;
	var size=50, sig, phases, amps, env, freqs, specs, time=0.1;
	phases = Array.fill( size, { arg i; (i*rrand(-1.0, 1.0)).mod(2pi) }); // phase offset, try mod'ing if cycle is too obvious
	freqs = Array.fill( size, { 440 });
	amps = Array.fill( size, { 1/size });
	env = EnvGen.kr(Env.asr( time, 1.0, time ), gate);
	sig = SinOsc.ar(NamedControl.kr(\freqs1, freqs), phases, NamedControl.kr(\amps1, amps));
	sig = Mix.ar( sig ); // mix down to 1 channels
	sig = Pan2.ar(sig); //  now to 2 channels? need to see what studio setup will be
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)



s.boot;
x = Synth(\sineBank);
x = Synth(\sinBank8);

(
a = Array.fill(50, { rrand(100.0, 500) });
a.postln;
x.set(\freqs, a);
)

Array.fill(20, { arg i; [i, 2pi/i].postln } );

SinOsc


100.do( { arg i; i.mod(2pi).postln; });
s.meter;


FFT

s.quit