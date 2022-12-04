-- eels
--
-- dual digital delay 
-- & comb filter
--
-- version 0.1-beta @andrew

--global variables

modes = { 'coupled', 'decoupled', 'series', 'ping-pong', 'send/return' }
COUPLED, DECOUPLED, SERIES, PINGPONG, SENDRETURN = 1, 2, 3, 4, 5
mode = COUPLED 

inputs = { 'stereo', 'mono' }
STEREO, MONO = 1, 2
input = MONO --STEREO

--external libs

tab = require 'tabutil'
cs = require 'controlspec'

--git submodule libs

--script lib files

include 'lib/params'    --add params

engine.name = 'Eels'

function init()
    params:bang()
end
