local x,y = {}, {}

local mar = { left = 2, top = 7, right = 2, bottom = 0 }
local w = 128 - mar.left - mar.right
local h = 64 - mar.top - mar.bottom

x[1] = mar.left
x[2] = 128/2
y[1] = mar.top
y[2] = mar.top + h*(1.5/8)
y[3] = mar.top + h*(5.5/8)
y[4] = mar.top + h*(7/8)

local e = {
    { x = x[1], y = y[1] },
    { x = x[1], y = y[3] },
    { x = x[2], y = y[3] },
}
local k = {
    { x = x[1], y = y[2] },
    { x = x[1], y = y[4] },
    { x = x[2], y = y[4] },
}

alt = 0

local function _ctl(props)
    if alt == 0 then
        local p = params:lookup_param(props.id)

        if p.controlspec then
            _enc.control{
                n = props.n,
                controlspec = p.controlspec,
                state = {
                    params:get(props.id), 
                    params.set, params, props.id,
                },
            }
        elseif p.max then
            _enc.number{
                n = props.n, 
                min = p.min, max = p.max, sensitivity = 1,
                state = {
                    params:get(props.id), 
                    params.set, params, props.id,
                },
            }
        end
    else
        _enc.number{
            n = props.n, max = #mod.sources[props.mod_id], sensitivity = 1,
            state = {
                params:get('mod '..props.mod_id), 
                params.set, params, 'mod '..props.mod_id,
            },
        }
    end

    local src = params:get('mod '..props.mod_id)

    _screen.list{
        x = e[props.n].x, y = e[props.n].y, margin = 3,
        text = alt==0 and {
            props.name, 
            string.format(props.quant or '%.2f', params:get(props.id)),
            (src > 1) and '+' or nil,
            (src > 1) and string.format('%.3f', mod.get(props.mod_id)) or nil
        } or {
            props.name,
            mod.sources[props.mod_id][src]
        },
        levels = { 4, enabled[props.en_id or props.id] and 15 or 4 },
    }
end

local function _del(props)
    _ctl{ 
        name = 'time', n = 1, 
        quant = (params:get('time '..props.del..' quant') == OCT) and '%d' or nil,
        id = set.get_id_volts(props.del), mod_id = 'time '..props.del, en_id = 'time '..props.del,
    }
    _ctl{ n = 2, id = 'time lag '..props.del, mod_id = 'time lag '..props.del, name = 'lag', }
    _ctl{ n = 3, id = 'fb_level_'..props.del, mod_id = 'feedback '..props.del, name = 'fb' }
    -- _ctl{ n = 3, id = 'out_level_'..props.del, mod_id = 'output '..props.del, name = 'out' }

    _key.number{
        n_next = 3, min = 1, max = #ranges,
        state = {
            params:get('range '..props.del), 
            params.set, params, 'range '..props.del,
        },
    }
    _screen.list{
        x = k[3].x, y = k[3].y,
        text = ranges, focus = params:get('range '..props.del),
        levels = { 4, enabled['time '..props.del] and 15 or 4 },
    }
end

local function _mode_mod(props)
    do
        local n, id = 1, 'io_mode'
        _enc.number{
            n = n, max = #modes, sensitivity = 1,
            state = {
                params:get(id), 
                params.set, params, id,
            },
        }
        _screen.list{
            x = e[n].x, y = e[n].y, margin = 3,
            text = { 'i/o', modes[params:get(id)] },
        }
    end
    do
        local n, id = 2, 'lfo_free_lfo'
        _enc.control{
            n = n,
            state = {
                params:get_raw(id), 
                function(v)
                    params:set_raw(id, v)
                    crops.dirty.screen = true
                end
            },
        }
        _screen.list{
            x = e[n].x, y = e[n].y, margin = 3,
            text = { 'rate', params:get(id)..' sec' },
        }
    end
    do
        local n, id = 3, 'lfo_depth_lfo'
        _enc.number{
            n = n,
            min = params:lookup_param(id).min,
            max = params:lookup_param(id).max,
            sensitivity = 1,
            state = {
                params:get(id), 
                function(v)
                    params:set(id, v)
                    crops.dirty.screen = true
                end
            },
        }
        _screen.list{
            x = e[n].x, y = e[n].y, margin = 3,
            text = { 'depth', params:get(id)..'%' },
        }
    end
end

function Norns()
    local tab = 1
    local A, B, M = 1, 2, 3

    return function()
        _key.number{
            n_next = 2, min = 1, max = 3,
            state = { tab, function(v) tab = v; crops.dirty.screen = true end },
        }
        _screen.list{
            x = k[2].x, y = k[2].y, margin = 3,
            text = { 'A', 'B', 'M' }, focus = tab,
        }

        _key.momentary{
            n = 1, state = { alt, function(v) alt = v; crops.dirty.screen = true end }
        }

        if tab == A then
            _del{ del = 'a' }
        elseif tab == B then
            _del{ del = 'b' }
        elseif tab == M then
            _mode_mod{}
        end
    end
end

return Norns
