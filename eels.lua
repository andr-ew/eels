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

quants = { 'free', 'oct' }
FREE, OCT = 1, 2

a = arc.connect()

arc.add = function() crops.dirty.arc = true end

enabled = {}

--script lib files

set = include 'lib/engine/setters'            --engine setter functions
mod = include 'lib/modulation/matrix'         --modulation matrix
src = include 'lib/modulation/sources'        --modulation sources

--setup mod matrix

mod.destinations = { 
    'time a', 'time b', 'time lag a', 'time lag b', 'feedback a', 'feedback b', 
    'output a', 'output b', 'input a', 'input b'
}

mod.sources = {}
do
    local time = { 'none', 'lfo', 'crow in 1', 'crow in 2', 'midi', 'clock' }
    local other = { 'none', 'lfo', 'crow in 1', 'crow in 2'  }

    for _,dest in ipairs(mod.destinations) do
        mod.sources[dest] = other
    end
    for _,dest in ipairs{ 'time a', 'time b' } do
        mod.sources[dest] = time 
    end
end

mod.values = {
    ['none'] = 0,
    ['lfo'] = 0,
    ['crow in 1'] = 0,
    ['crow in 2'] = 0,
    ['midi'] = 0,
    ['clock'] = 0,
}

mod.actions = {
    ['none'] = function(arc_silent) end,
    ['time a'] = function(a_s) set.times(a_s); set.feedbacks(a_s) end,
    ['time b'] = function(a_s) set.times(s_s); set.feedbacks(a_s) end,
    ['time lag a'] = set.time_lags,
    ['time lag b'] = set.time_lags,
    ['feedback a'] = set.feedbacks,
    ['feedback b'] = set.feedbacks,
    ['output a'] = set.out_amps,
    ['output b'] = set.out_amps,
    ['input a'] = set.in_amps,
    ['input b'] = set.in_amps,
}

--script lib files

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
    src.lfo.reset_params()

    params:read()
    
    src.lfo:start()
    src.clock.start()
    
    params:bang()
end

function cleanup()
    if params:string('autosave pset') == 'yes' then params:write() end
end
