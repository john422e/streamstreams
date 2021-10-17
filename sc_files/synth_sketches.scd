s.boot;

(
{
	arg minX, maxX, rate;
	var sig;
	sig = LFNoise0.kr(10).range(1, 100).round(1).poll;
}.play;
)


round(10.123124, 1);

(
x = {
	arg amp=0.3;
	SinOsc.ar([220, 330], mul: [amp, );
}.play;
x.set(\amp, 0.2);

)

(
SynthDef.new(\sinBank8, {
	var size=8, sig, freqs, amps, phases, ampMod;
	freqs = Array.fill(size, { rrand(200.0, 400.0) } );
	amps = Array.fill(size, { 1/size } );
	phases = Array.fill(size, { arg i; i.mod(2pi) } );
	sig = DynKlang.ar( `[ \freqs.kr(freqs), \amps.kr(amps), \phases.kr(phases) ] );
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5));
	Out.ar(\out.kr(0), sig);
}).add;
)

SynthDef.new(\sinBank8, {
	arg gate=0, out=0, amp=0.9;
	var size=8, sig, phases, amps, env, freqs, specs, time=rampTime;
	phases = Array.fill(size, { arg i; i.mod(2pi) } );
	freqs = Array.fill( size, { rrand(200.0, 400.0) });
	amps = Array.fill( size, { 1/size });
	env = EnvGen.kr(Env.asr( time, 1.0, time ), gate);
	sig = SinOsc.ar(NamedControl.kr(\freqs1, freqs), phases, NamedControl.kr(\amps1, amps));
	sig = Mix.ar( sig ); // mix down to 1 channels
	sig = Pan2.ar(sig); //  now to 2 channels? need to see what studio setup will be
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

(
a = Array.fill(8, { 1/8 } );
x = Synth.new(\sinBank8);
t = Task( {
	2.wait;
	loop{
		var i, oldAmp;
		i = rrand(0, 7);
		oldAmp = a[i];
		a[i] = 0;
		x.set(\amps, a);
		a.postln;
		0.05.wait;
		a[i] = oldAmp;
	};
});
)

t.start;