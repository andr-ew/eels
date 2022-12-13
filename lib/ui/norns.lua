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

local function _ctl(props)
    _enc.control{
        n = props.n,
        controlspec = params:lookup_param(props.id).controlspec,
        state = {
            params:get(props.id), 
            params.set, params, props.id,
        },
    }
    _screen.list{
        x = e[props.n].x,
        y = e[props.n].y,
        text = { props.id, string.format('%.3f', params:get(props.id)) },
        levels = { 4, 15 },
    }
end

function Norns()
    return function()
        _ctl{
            n = 1, id = 'time a'
        }
    end
end

return Norns
