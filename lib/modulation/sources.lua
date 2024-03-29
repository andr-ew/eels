local src = {}

local middle_a = 69

local m = midi.connect()
m.event = function(data)
    local msg = midi.to_msg(data)

    if msg.type == "note_on" then
        local note = msg.note
        local volt = (note - middle_a - params:get('fine') + 1)/12

        mod.set('midi', volt)
    end
end

src.midi = m

src.lfo = {}

for i = 1,2 do
    src.lfo[i] = lfos:add{
        min = 0,
        max = 5,
        depth = 0.1,
        mode = 'free',
        period = 0.25,
        action = function(scaled, raw) 
            mod.set('lfo '..i, scaled) 
        end,
    }
end

src.lfo.reset_params = function()
    params:set('mod time a', tab.key(mod.sources['time a'], 'lfo 1'))
    for i = 1,2 do
        params:set('lfo_mode_lfo_'..i, 2)
        params:set('lfo_max_lfo_'..i, 0.5)
        params:set('lfo_lfo_'..i, 2)
    end
end

src.clock = {}

function src.clock.start()
    local c = clock.run(function()
        while true do
            mod.set('clock', set.time_seconds_volt(clock:get_beat_sec(), DELAY))
            clock.sync(1/16)
        end
    end)

    return c
end

src.crow = {}

-- src: https://github.com/monome/norns/blob/e8ae36069937df037e1893101e73bbdba2d8a3db/lua/core/crow.lua#L14
local function re_enable_clock_source_crow()
    if params.lookup["clock_source"] then
        if params:string("clock_source") == "crow" then
            norns.crow.clock_enable()
        end
    end
end

function src.crow.update()
    local mapped = { false, false }

    for _,dest in ipairs(mod.destinations) do
        local sources = mod.sources[dest]
        local source = params:get('mod '..dest)
    
        if source == tab.key(sources, 'crow in 1') then mapped[1] = true
        elseif source == tab.key(sources, 'crow in 2') then mapped[2] = true end
    end
    
    for i, map in ipairs(mapped) do if map then
        crow.input[i].mode('stream', 0.002)
        crow.input[i].stream = function(v)
            mod.set('crow in '..i, v)
        end
    end end
    if not mapped[1] then re_enable_clock_source_crow() end
end

norns.crow.add = src.crow.update

return src
