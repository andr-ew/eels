local function set_in_amps()
    local a = util.dbamp(params:get('in_level_a'))
    local b = util.dbamp(params:get('in_level_b'))

    if mode==COUPLED and input==STEREO then
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(0)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(a)
    elseif mode==COUPLED and input==MONO then
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(a)
        engine.amp_in_left_b(a)
        engine.amp_in_right_b(a)
    elseif mode==DECOUPLED and input==STEREO then
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(0)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(b)
    elseif mode==DECOUPLED and input==MONO then
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(a)
        engine.amp_in_left_b(b)
        engine.amp_in_right_b(b)
    elseif mode==PINGPONG then
    elseif mode==SENDRETURN then
    end
end

local ranges = { 'delay', 'comb' }
local DELAY, COMB = 1, 2

local function get_time_seconds(del)
    local hz = params:get('root')
    local semitone = params:get('fine') - 1
    -- local volt = params:get('course '..del) + params:get('time '..del)
    local volt = params:get('time '..del)
    local mult = ({
        2^10,
        2^3,
    })[params:get('range '..del)]

    hz = hz * (2^(semitone/12)) * (2^volt) * (1/mult)

    local seconds = 1/hz

    print(seconds, hz)
end

local function set_times()
end
local function set_feedbacks()
end
local function set_out_amps()
end

--add global params
do
    params:add_separator('modes')

    params:add{
        name = 'i/o', id = 'io_mode', type = 'option',
        options = modes, default = mode,
        action = function(v)
            mode = v

            set_in_amps()
            set_times()
            set_feedbacks()
            set_out_amps()
        end
    }
    params:add{
        name = 'input', id = 'input_mode', type = 'option',
        options = inputs, default = input,
        action = function(v)
            input = v
            set_in_amps()
        end
    }
    params:add{
        id = 'interpolation', type = 'option',
        options = { 'none', 'linear', 'cubic' }, default = 1,
        action = function(v) engine.interpolation(({ 1, 2, 4 })[v]) end
    }
end

--add time params
do
    params:add_separator('time')

    local notes = { 'A','A#','B','C','C#','D','D#','E','F','F#','G','G#', }

    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            id = 'time '..del, type = 'control',
            controlspec = cs.def{
                min = 0, max = 6, default = ({ 3, 0 })[i],
                units = 'v/oct', quantum = 1/100/6,
            }
        }
    end
    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            id = 'range '..del, type = 'option',
            options = ranges, default = DELAY, action = set_times,
        }
    end
        -- params:add{
        --     id = 'course '..del, type = 'number',
        --     min = -4, max = 4, default = 0, action = set_times,
        --     formatter = function(self) return self.value..' v/oct' end
        -- }

    params:add{
        id = 'root', type = 'control',
        controlspec = cs.def{
            min = 420-50,
            max = 420+50,
            default = 440,
            units = 'hz',
        }, 
        action = set_times,
    }
    params:add{
        id = 'fine', type = 'option',
        options = notes, default = tab.key(notes, 'C'), action = set_times,
    }
end

--add levels params
do
    local db6 = cs.def{
        min = -math.huge, max = 6,
        warp = 'db', default = 0, units = 'dB',
    }
    local db0 = cs.def{
        min = -math.huge, max = 0,
        warp = 'db', default = 0, units = 'dB',
    }

    params:add_separator('levels')

    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            name = 'feedback '..del, id = 'fb_level_'..del, type = 'control',
            controlspec = db0, action = set_feedbacks,
        }
    end
    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            name = 'input '..del, id = 'in_level_'..del, type = 'control',
            controlspec = db6, action = set_in_amps,
        }
    end
    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            name = 'output '..del, id = 'out_level_'..del, type = 'control',
            controlspec = db6, action = set_out_amps,
        }
    end
end

--add destination params
do
    local time = { 'none', 'time a', 'time b' }
    local all = { 'none', 'time a', 'time b', 'feedback a', 'feedback b', 'level a', 'level b' }
    
    params:add_separator('destinations')

    params:add{
        id = 'lfo', type = 'option', options = all,
    }
    for i = 1,2 do
        params:add{
            id = 'crow input '..i, type = 'option', options = all,
        }
        params:add{
            id = 'crow input '..i..' mode', type = 'option', options = { 'cv', 'clock' },
        }
    end
    params:add{
        id = 'midi', type = 'option', options = time,
    }
    params:add{
        id = 'global clock', type = 'option', options = time,
    }
end
