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

src.lfo = lfos:add{
    min = 0,
    max = 5,
    depth = 0.1,
    mode = 'free',
    period = 0.25,
    action = function(scaled) mod.set('lfo', scaled) end,
}

src.clock = {}

function src.clock.start()
    local c = clock.run(function()
        while true do
            mod.set('clock', set.time_seconds_volt(clock:get_beat_sec(), DELAY))
            clock.sync(1/96)
        end
    end)

    return c
end

return src
