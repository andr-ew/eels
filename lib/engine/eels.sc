Eels {
    const maxDelayTime = 11; //will be decreased to 2^19 samples = 10.92s (?)

    var s;
    var <def;
    var <commandNames;
    var <synth;
    var <buffers;

    *new {
		^super.new.init;
	}

	init {
        //synthdef controls not to make into engine commands
        var notCommand = [\outBus, \delBuf];

        def = SynthDef.new(\eels, {
            var delBuf = \delBuf.kr(0!2);
            var extIn = SoundIn.ar([0,1]);
            var localIn = LocalIn.ar(2);

            var inA = Mix.ar(
                extIn * [\amp_in_left_a.kr(1), \amp_in_right_a.kr(1)]
            )
            + (localIn[1] *  \amp_b_a.kr(0));
            var inB = Mix.ar(
                extIn * [\amp_in_left_b.kr(1), \amp_in_right_b.kr(1)]
            )
            + (localIn[0] * \amp_a_b.kr(0));

            var timeA = \time_a.kr(0.2, \time_lag_a.kr(3));
            var timeB = \time_b.kr(0.2, \time_lag_b.kr(3));

            var delA = BufCombC.ar(delBuf[0], inA, timeA, \decay_a_a.kr(5));
            var delB = BufCombC.ar(delBuf[1], inB, timeB, \decay_b_b.kr(5));

            var outA = delA!2 * [\amp_out_left_a.kr(1), \amp_out_right_a.kr(0)];
            var outB = delB!2 * [\amp_out_left_b.kr(0), \amp_out_right_b.kr(1)];
            var passThrough = [
                Mix.ar(
                    extIn * [\amp_passthrough_left_left.kr(0), \amp_passthrough_right_left.kr(0)]
                ),
                Mix.ar(
                    extIn * [\amp_passthrough_left_right.kr(0), \amp_passthrough_right_right.kr(0)]
                )
            ];

            LocalOut.ar([delA, delB]);

            Out.ar(\outBus.kr(0), outA + outB + passThrough);
        }).add;

        //make list of commands from NamedControls
        commandNames = List.new();
        def.allControlNames.do({ arg c;
            if(notCommand.indexOf(c.name).isNil, {
                commandNames.add(c.name);
            });
        });

        s = Server.default;

        buffers = Array.fill(2, { Buffer.alloc(s, s.sampleRate * maxDelayTime) });

        s.sync;
        synth = Synth.new(\eels, [\delBuf, Array.fill(2, { arg i; buffers[i].bufnum })]);
        s.sync;

        postln("♪who let the eels out♪");
	}

    free {
        synth.free;
        buffers.do({ arg b; b.free; });
    }
}
