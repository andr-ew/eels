Engine_Eels : CroneEngine {

    var eels;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
        eels = Eels.new();

        eels.commandNames.do({ var name;
            this.addCommand(name, \f, { arg msg; eels.synth.set(name, msg[1]) });
        });
    }

    free {
        eels.free;
    }
}