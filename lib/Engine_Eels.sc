Engine_Eels : CroneEngine {

    var eels;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
        eels = Eels.new();
    }

    free {
        eels.free;
    }
}