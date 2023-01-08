local function Param()
    local remainder_number = 0.0

    return function(props)
        local p = params:lookup_param(props.id)
        local not_control = not p.controlspec

        if not_control and crops.mode == 'input' then
            _arc.integer{
                n = props.n,
                min = p.min, max = p.max,
                state = {
                    params:get(props.id), 
                    params.set, params, props.id,
                },
                state_remainder = {
                    remainder_number, function(v) remainder_number = v end
                }
            }
        else
            _arc.control{
                n = props.n,
                x = props.x,
                controlspec = not_control and props.spec or p.controlspec,
                levels = props.levels, sensitivity = props.sensitivity,
                state = {
                    params:get(props.id), 
                    params.set, params, props.id,
                },
            }
        end
    end
end

local function Time()
    local _time = Param()

    return function(props)
        local spec = params:lookup_param('time free '..props.del).controlspec
        local w = 9
        local min, max = 42, 42 + (6*w)-1
        if crops.mode == 'redraw' then
            local a = crops.handler

            for i, x in _arc.util.ring_range(min, max-1) do
                if (i/w)%1 == 0 then
                else a:led(props.n, x+1, 4) end
            end
        end
        if enabled['time '..props.del] then
            _time{
                n = props.n, id = set.get_id_volts(props.del), levels = { 0, 0, 15 }, 
                sensitivity = 1, x = { min, max }, spec = spec,
            }
        end
    end
end

local function Feedback()
    local _fb = Param()

    return function(props)
        local id = 'fb_level_'..props.del
        _fb{
            n = props.n, id = id,
            levels = { 0, 4, enabled[id] and 15 or 4 }
        }
    end
end

local function Arc()
    local _time_a, _time_b = Time(), Time()
    local _fb_a, _fb_b = Feedback(), Feedback()

    return function()
        _time_a{ del = 'a', n = 1, }
        _fb_a{ del = 'a', n = 2, }
        _time_b{ del = 'b', n = 3, }
        _fb_b{ del = 'b', n = 4, }
    end
end

return Arc
