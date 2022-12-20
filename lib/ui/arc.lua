local function _ctl(props)
    _arc.control{
        n = props.n,
        x = props.x,
        controlspec = params:lookup_param(props.id).controlspec,
        levels = props.levels, sensitivity = props.sensitivity,
        state = {
            params:get(props.id), 
            params.set, params, props.id,
        },
    }
end

local function _time(props)
    local w = 9
    local min, max = 42, 42 + (6*w)-1
    if crops.mode == 'redraw' then
        local a = crops.handler
        local spec = params:lookup_param('time '..props.del).controlspec

        for i, x in _arc.util.ring_range(min, max-1) do
            if (i/w)%1 == 0 then
            else a:led(props.n, x+1, 4) end
        end
    end
    if enabled['time '..props.del] then
        _ctl{
            n = props.n, id = 'time '..props.del, levels = { 0, 0, 15 }, 
            sensitivity = 1, x = { min, max },
        }
    end
end

local function _feedback(props)
    local id = 'fb_level_'..props.del
    _ctl{
        n = props.n, id = id,
        levels = { 0, 4, enabled[id] and 15 or 4 }
    }
end

local function Arc()
    return function()
        _time{ del = 'a', n = 1, }
        _feedback{ del = 'a', n = 2, }
        _time{ del = 'b', n = 3, }
        _feedback{ del = 'b', n = 4, }
    end
end

return Arc
