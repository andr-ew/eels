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

local function Del(del)
    return function()
        local w = 9
        local min, max = 42, 42 + (6*w)-1
        if crops.mode == 'redraw' then
            local a = crops.handler
            local spec = params:lookup_param('time '..del).controlspec

            for i, x in _arc.util.ring_range(min, max-1) do
                if (i/w)%1 == 0 then
                else a:led(1, x+1, 4) end
            end
        end
        _ctl{
            n = 1, id = 'time '..del, levels = { 0, 0, 15 }, 
            sensitivity = 0.5, x = { min, max },
        }
    end
end

local function Arc()
    local a = Del('a')

    return function()
        a()
    end
end

return Arc
