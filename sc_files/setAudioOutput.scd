// run this to open system audio setup on macOS (
"open -a 'Audio MIDI Setup'".unixCmd; // shift-enter here
(
var inLabel, outLabel, inMenu, outMenu; // command-enter here to open menu for input/output selection
//Window.closeAll;
o = Server.default.options;
o.numWireBufs_(1024);
o.sampleRate_(48000);
s.boot;
s.quit;
o = Server.default.options;
w = Window.new("Audio Output Selection", Rect.new(Window.screenBounds.left, Window.screenBounds.bottom, 805, 130));
inLabel = StaticText(w, Rect.new(10, 5, 100, 10)).string_("INPUT");
inMenu = PopUpMenu(w, Rect.new(0, 20, 400, 100))
.items_(ServerOptions.inDevices)
.action_({
	ServerOptions.inDevices[inMenu.value].postln;
	o.outDevice_(ServerOptions.inDevices[inMenu.value]);
	s.reboot;
	//s.makeWindow;
});
outLabel = StaticText(w, Rect.new(inMenu.bounds.right+10, 5, 100, 10)).string_("OUTPUT");
outMenu = PopUpMenu(w, Rect.new(inMenu.bounds.right+5, 20, 400, 100))
.items_(ServerOptions.outDevices)
.action_({
	ServerOptions.outDevices[outMenu.value].postln;
	o.outDevice_(ServerOptions.outDevices[outMenu.value]);
	s.reboot;
	//s.makeWindow;
});
w.front;
)