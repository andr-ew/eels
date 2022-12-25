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

return m
