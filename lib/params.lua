--add mode params
do
    params:add_separator('modes')

    params:add{
        name = 'i/o', id = 'io_mode', type = 'option',
        options = modes, default = mode,
        action = function(v)
            mode = v

            set.in_amps()
            set.times()
            set.feedbacks()
            set.out_amps()
        end
    }
    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            id = 'range '..del, type = 'option',
            options = ranges, default = DELAY, action = function()
                set.times()
                set.feedbacks()
            end,
        }
    end
    params:add{
        name = 'input', id = 'input_mode', type = 'option',
        options = inputs, default = input,
        action = function(v)
            input = v
            set.in_amps()
        end
    }
    params:add{
        id = 'interpolation', type = 'option',
        options = { 'none', 'linear', 'cubic' }, default = 3,
        action = function(v) engine.interpolation(({ 1, 2, 4 })[v]) end
    }
end

--add time params
do
    params:add_separator('time')

    local notes = { 'A','A#','B','C','C#','D','D#','E','F','F#','G','G#', }

    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            id = 'time '..del, type = 'control', action = set.times,
            controlspec = cs.def{
                min = 0, max = 6, default = ({ 2, 0.01 })[i],
                units = 'v/oct', quantum = 1/100/6, 
            }
        }
    end
        -- params:add{
        --     id = 'course '..del, type = 'number',
        --     min = -4, max = 4, default = 0, action = set.times,
        --     formatter = function(self) return self.value..' v/oct' end
        -- }

    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            id = 'fine '..del, type = 'option',
            options = notes, action = set.times,
        }
    end

    params:add{
        id = 'root', type = 'control',
        controlspec = cs.def{
            min = 420-50,
            max = 420+50,
            default = 440,
            units = 'hz',
        }, 
        action = set.times,
    }
end

--add levels params
do
    local cs_lvl = cs.def{ min = 0, max = 5, default = 4, units = 'v' }

    params:add_separator('levels')

    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            name = 'feedback '..del, id = 'fb_level_'..del, type = 'control',
            controlspec = cs.def{ min = -5, max = 5, default = (0.5)*5, units = 'v' },
            action = set.feedbacks,
        }
    end
    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            name = 'input '..del, id = 'in_level_'..del, type = 'control',
            controlspec = cs_lvl, action = set.in_amps,
        }
    end
    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            name = 'output '..del, id = 'out_level_'..del, type = 'control',
            controlspec = cs_lvl, action = set.out_amps,
        }
    end
    --TODO: width
end

--add destination params
mod.params()

--add LFO params

params:add_separator('lfo')
lfo:add_params('lfo')
