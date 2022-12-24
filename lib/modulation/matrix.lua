local mod = {}

mod.destinations = {}
mod.sources = {}
mod.values = {}
mod.actions = {}

function mod.params()
    params:add_separator('modulation')

    for _,dest in ipairs(mod.destinations) do
        params:add{
            name = dest, id = 'mod '..dest, type = 'option', 
            options = mod.sources[dest],
            action = function() crops.dirty.screen = true end
        }
    end
end

local arc_silent = true

function mod.set(src, v)
    mod.values[src] = v

    for _,dest in ipairs(mod.destinations) do
        if mod.sources[dest][params:get('mod '..dest)] == src then 
            mod.actions[dest](arc_silent) 
        end
    end
end

function mod.get(dest)
    local src = mod.sources[dest][params:get('mod '..dest)]

    return mod.values[src]
end

return mod
