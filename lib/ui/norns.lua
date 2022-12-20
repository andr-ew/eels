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
        _enc.control{
            n = props.n,
            controlspec = params:lookup_param(props.id).controlspec,
            state = {
                params:get(props.id), 
                params.set, params, props.id,
            },
        }
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
        x = e[props.n].x,
        y = e[props.n].y,
        margin = 3,
        text = alt==0 and {
            props.name, 
            string.format('%.2f', params:get(props.id)),
            (src > 1) and '+' or nil,
            (src > 1) and string.sub(string.format('%.3f', mod.get(props.mod_id)), 2) or nil
        } or {
            props.name,
            mod.sources[props.mod_id][src]
        },
        levels = { 4, enabled[props.id] and 15 or 4 },
    }
end

local function _del(props)
    _ctl{ n = 1, id = 'time '..props.del, mod_id = 'time '..props.del, name = 'time', }
    _ctl{ n = 2, id = 'fb_level_'..props.del, mod_id = 'feedback '..props.del, name = 'fb' }
    _ctl{ n = 3, id = 'out_level_'..props.del, mod_id = 'output '..props.del, name = 'out' }

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
