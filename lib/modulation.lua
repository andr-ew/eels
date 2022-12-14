local mod = {}

mod.destinations = { 
    'time a', 'time b', 'feedback a', 'feedback b', 
    'output a', 'output b', 'input a', 'input b'
}

mod.sources = {}

do
    local time = { 'none', 'lfo', 'crow input 1', 'crow input 2', 'midi', 'clock' }
    local other = { 'none', 'lfo', 'crow input 1', 'crow input 2'  }

    for _,dest in ipairs(mod.destinations) do
        mod.sources[dest] = other
    end
    for _,dest in ipairs{ 'time a', 'time b' } do
        mod.sources[dest] = time 
    end
end

mod.values = {
    ['none'] = 0,
    ['lfo'] = 0,
    ['crow input 1'] = 0,
    ['crow input 2'] = 0,
    ['midi'] = 0,
    ['clock'] = 0,
}

mod.actions = {
    ['none'] = function() end,
    ['time a'] = set.times,
    ['time b'] = set.times,
    ['feedback a'] = set.feedbacks,
    ['feedback b'] = set.feedbacks,
    ['output a'] = set.out_amps,
    ['output b'] = set.out_amps,
    ['input a'] = set.in_amps,
    ['input b'] = set.in_amps,
}

function mod.params()
    params:add_separator('modulation')

    for _,dest in ipairs(mod.destinations) do
        params:add{
            name = dest, id = 'mod '..dest, type = 'option', 
            options = mod.sources[dest]
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
