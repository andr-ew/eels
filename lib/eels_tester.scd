//list yr audio interfaces
ServerOptions.devices;

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

//free
~eels.free;
