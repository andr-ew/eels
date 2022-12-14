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

enabled = {}

--git submodule libs

include 'lib/crops/core'                      --crops, a UI component framework
_arc = include 'lib/crops/routines/arc'
_enc = include 'lib/crops/routines/enc'
_key = include 'lib/crops/routines/key'
_screen = include 'lib/crops/routines/screen'

--script lib files

set = include 'lib/set'                       --engine setter functions
mod = include 'lib/modulation'                --modulation code
include 'lib/params'                          --add params
App = {}
App.norns = include 'lib/ui/norns'            --norns UI component
App.arc = include 'lib/ui/arc'                --arc UI component

--connect UI components

_app = { norns = App.norns(), arc = App.arc() }

crops.connect_arc(_app.arc, a)
crops.connect_enc(_app.norns)
crops.connect_key(_app.norns)
crops.connect_screen(_app.norns)

--norns globals

engine.name = 'Eels'

function init()
    params:set('mod time a', tab.key(mod.sources['time a'], 'lfo'))
    params:set('lfo_mode_lfo', 2)
    params:set('lfo_max_lfo', 0.5)
    params:set('lfo_lfo', 2)
    lfo:start()

    --params:read()
    
    params:bang()
end

function cleanup()
    --params:write()
end
