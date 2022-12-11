-- eels
--
-- dual digital delay 
-- & comb filter
--
-- version 0.1-beta @andrew

--external libs

tab = require 'tabutil'
cs = require 'controlspec'
lfos = require 'lfo'

--git submodule libs

include 'lib/crops/core'                      --crops, a UI component framework
_arc = include 'lib/crops/routines/arc'
_enc = include 'lib/crops/routines/enc'
_key = include 'lib/crops/routines/key'
_screen = include 'lib/crops/routines/screen'

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

lfo = lfos:add{
    min = 0,
    max = 5,
    depth = 0.1,
    mode = 'free',
    period = 0.25,
    action = function(scaled) mod.set('lfo', scaled) end,
}

--script lib files

set = include 'lib/set'                       --engine setter functions
mod = include 'lib/modulation'                --modulation code
include 'lib/params'                          --add params
Eels = include 'lib/ui'                       --crops-based UI components

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
    params:set('mod time a', tab.key(mod.sources['time a'], 'lfo'))
    params:set('lfo_mode_lfo', 2)
    params:set('lfo_max_lfo', 0.5)
    params:set('lfo_lfo', 2)
    lfo:start()

    --params:read()
    
    params:bang()
end
