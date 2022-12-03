Eels {

    var s;

    var <def;
    var <synth;


    *new {
		^super.new.init;
	}

	init {
        s = Server.default;

        def = SynthDef.new(\eels, {
            var in = SoundIn.ar([0,1]);

            Out.ar(\outbus.kr(0), in);
        }).add;

        s.sync;

        synth = Synth.new(\eels);

        s.sync;

        postln("who let the eels out");
	}

    free {
        synth.free;
    }
}