Eels {
    const maxDelayTime = 5;

    var s;
    var <def;
    var <synth;
    var <buffers;

    *new {
		^super.new.init;
	}

	init {
        s = Server.default;

        buffers = Array.fill(2, { Buffer.alloc(s, s.sampleRate * maxDelayTime) });

        def = SynthDef.new(\eels, {
            var delBuf = \delBuf.kr(0!4);
            var extIn = SoundIn.ar([0,1]);
            var localIn = LocalIn.ar(2);

            var inA = Mix.ar(
                extIn * [\amp_in_left_a.kr(1), \amp_in_right_a.kr(0)]
            ) + Mix.ar(
                localIn * [\feedback_a_a.kr(0.5), \feedback_b_a.kr(0)]
            );
            var inB = Mix.ar(
                extIn * [\amp_in_left_b.kr(0), \amp_in_right_b.kr(1)]
            ) + Mix.ar(
                localIn * [\feedback_b_a.kr(0), \feedback_b_b.kr(0.5)]
            );

            var timeA = \time_a.kr(0.2, 3);
            var timeB = \time_b.kr(0.2, 3);

            var phaseA = DelTapWr.ar(delBuf[0], inA);
            var phaseB = DelTapWr.ar(delBuf[1], inB);

            var interp = \interpolation.kr(1);

            var delA = DelTapRd.ar(delBuf[0], phaseA, timeA, interp);
            var delB = DelTapRd.ar(delBuf[1], phaseB, timeB, interp);

            var outA = delA!2 * [\amp_out_left_a.kr(1), \amp_out_right_a.kr(0)];
            var outB = delB!2 * [\amp_out_left_b.kr(0), \amp_out_right_b.kr(1)];

            LocalOut.ar([delA, delB]);

            Out.ar(\outBus.kr(0), outA + outB);
        }).add;

        s.sync;

        synth = Synth.new(\eels, [\delBuf, Array.fill(2, { arg i; buffers[i].bufnum })]);

        s.sync;

        postln("♪who let the eels out♪");
	}

    free {
        synth.free;
        buffers.free;
    }
}