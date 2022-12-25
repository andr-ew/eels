//list yr audio interfaces
ServerOptions.devices;

//Languge > Recompile Class Library (Cmd+Sfit+L) to recompile class files

//reboot & init
(
s.options.device = "Scarlett 2i2 USB"; //set ur interface here ;)
s.reboot;

s.doWhenBooted({
    fork {
        ~eels = Eels.new();
    }
});
)

//send some commands
~eels.synth.set(\time_b, 0.9);
~eels.synth.set(\time_b, 0.3);
~eels.synth.set(\time_b, 0.23);
~eels.synth.set(\time_b, 0.2);
~eels.synth.set(\time_b, 0.15);
~eels.synth.set(\time_b, 0.1);

//free
~eels.free;

//test as resonator w/ midi
(
MIDIClient.init;
MIDIIn.connectAll;

~eels.synth.set(\time_lag_a, 0.03);
~eels.synth.set(\time_lag_b, 0.03);
~eels.synth.set(\feedback_a_a, 0.99186883928257);
~eels.synth.set(\feedback_b_b, 0.99186883928257);

MIDIdef.noteOn(\keybOn, {
	arg vel, nn, chan, src;

    var hz = nn.midicps;
    var s = 1/hz;

    ~eels.synth.set(\time_a, s);
    ~eels.synth.set(\time_b, s);
});
)

//test with ArcComponents https://github.com/andr-ew/ArcComponents
(
~arc = Arc.new("/monome", 0);
~arc.useDevice(0);
~comps = ArcComponents.new(~arc);

~comps.number(0, 4, true, { arg v;
    ~eels.synth.set(\time_a, 1-v);
    ~eels.synth.set(\time_b, (1-v) + 0.1);
});
~comps.number(1, 4, true, { arg v;
    ~eels.synth.set(\decay_a_a, v*10);
    ~eels.synth.set(\decay_b_b, v*10);
});
)

//free arcstuff
~comps.free;

//list engine commands
(
~eels.commandNames.do({ arg name;
    postln(name);
});
)


~fb = { arg delayTime, decayTime; (0.001.log * delayTime / decayTime).exp }

~fb.value(1/440, 1)
~fb.value(0.1, 1)
