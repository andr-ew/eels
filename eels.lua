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

ranges = { 'delay', 'comb' }
DELAY, COMB = 1, 2

a = arc.connect()

--external libs

tab = require 'tabutil'
cs = require 'controlspec'

--git submodule libs

include 'lib/crops/core'
_arc = include 'lib/crops/routines/arc'
_enc = include 'lib/crops/routines/enc'
_key = include 'lib/crops/routines/key'
_screen = include 'lib/crops/routines/screen'

--script lib files

include 'lib/params'         --add params
Eels = include 'lib/ui'      --crops-based UI components

--engine

engine.name = 'Eels'

--connect UI components

_eels = { norns = Eels.norns(), arc = Eels.arc() }

crops.connect_arc(_eels.arc, a)
crops.connect_enc(_eels.norns)
crops.connect_key(_eels.norns)
crops.connect_screen(_eels.norns)

--norns global functions

function init()
    params:bang()
end
