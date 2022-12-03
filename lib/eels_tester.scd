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

~eels.synth.set(\time_b, 0.3);
~eels.synth.set(\time_b, 0.2);


//free
~eels.free;
