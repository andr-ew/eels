Eels {

    const maxDelayTime = 1;

    var s;

    var <def;
    var <synth;
    var <buffers;


    *new {
		^super.new.init;
	}

	init {
        s = Server.default;

        buffers = Array.fill(4, { Buffer.alloc(s, s.sampleRate * maxDelayTime) });

        def = SynthDef.new(\eels, {
            var delBuf = \delBuf.kr(0!4);
            var extIn = SoundIn.ar([0,1]);
            var localIn = LocalIn.ar(2);

            var inA = Mix.ar(
                extIn * \amp_in_a.kr([1, 0])
            ) + Mix.ar(
                localIn * \feedback_a.kr([0.6, 0])
            );
            var inB = Mix.ar(
                extIn * \amp_in_b.kr([0, 1])
            ) + Mix.ar(
                localIn * \feedback_b.kr([0, 0.6])
            );

            var timeA = \time_a.kr(0.2, 0.5);
            var timeB = \time_b.kr(0.2, 0.5);

            // var delA = XFade2.ar(
            //     BufDelayN.ar(delBuf[0], inA, timeA),
            //     BufDelayC.ar(delBuf[1], inA, timeA),
            //     \quality_a.kr(1, 0.01)
            // );
            // var delB = XFade2.ar(
            //     BufDelayN.ar(delBuf[2], inB, timeB),
            //     BufDelayC.ar(delBuf[3], inB, timeB),
            //     \quality_b.kr(1, 0.01)
            // );
            // var delA = XFade2.ar(
            //     DelayN.ar(inA, maxDelayTime, timeA),
            //     DelayC.ar(inA, maxDelayTime, timeA),
            //     \quality_a.kr(1, 0.01)
            // );
            // var delB = XFade2.ar(
            //     DelayN.ar(inB, maxDelayTime, timeB),
            //     DelayC.ar(inB, maxDelayTime, timeB),
            //     \quality_b.kr(1, 0.01)
            // );

            var delA = DelayN.ar(inA, maxDelayTime, timeA, 2);
            var delB = DelayN.ar(inB, maxDelayTime, timeB, 2);

            var outA = delA!2 * \amp_out_a.kr([1, 0]);
            var outB = delB!2 * \amp_out_b.kr([0, 1]);

                // LocalOut.ar([delA, delB]);
            LocalOut.ar([0, 0]);

            Out.ar(\outBus.kr(0), outA + outB);
        }).add;

        s.sync;

        synth = Synth.new(\eels, [\delBuf, Array.fill(4, { arg i; buffers[i].bufnum })]);

        s.sync;

        postln("♪who let the eels out♪");
	}

    free {
        synth.free;
        buffers.free;
    }
}