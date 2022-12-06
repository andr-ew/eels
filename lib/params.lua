local function set_in_amps()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = util.dbamp(params:get('in_level_a'))
    local b = util.dbamp(params:get('in_level_b'))

    if mode == COUPLED and input==STEREO then
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(0)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(a)
    elseif mode == COUPLED and input==MONO then
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(a)
        engine.amp_in_left_b(a)
        engine.amp_in_right_b(a)
    elseif (mode == DECOUPLED or mode == SERIES) and input==STEREO then
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(0)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(b)
    elseif (mode == DECOUPLED or mode == SERIES) and input==MONO then
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(a)
        engine.amp_in_left_b(b)
        engine.amp_in_right_b(b)
    elseif mode == PINGPONG then
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(0)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(b)
    elseif mode == SENDRETURN then
        --TODO
    end
end

local ranges = { 'delay', 'comb' }
local DELAY, COMB = 1, 2
local mults = { [DELAY] = 2^11, [COMB] = 2^2 }

--local
function get_time_seconds(del, add)
    local hz = params:get('root')
    local semitone = params:get('fine') - 1

    local volt, mult
    if del=='sum' then
        volt = params:get('time a') + params:get('time b')
        mult = mults[params:get('range a')]
    else
        volt = params:get('time '..del)
        mult = mults[params:get('range '..del)]
    end

    hz = hz * (2^(semitone/12)) * (2^volt) * (1/mult)

    return 1/hz
end

local function set_times()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = get_time_seconds('a')
    local b = get_time_seconds('b')

    if mode == COUPLED then
        engine.time_a(a)
        engine.time_b(get_time_seconds('sum'))
    elseif mode == DECOUPLED or mode == SERIES then
        engine.time_a(a)
        engine.time_b(b)
    elseif mode == PINGPONG then
        engine.time_a(a)
        engine.time_b(a)
    elseif mode == SENDRETURN then
        engine.time_a(a)
    end
end

local function set_feedbacks()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = util.dbamp(params:get('fb_level_a'))
    local b = util.dbamp(params:get('fb_level_b'))

    if mode == COUPLED then
        engine.feedback_a_a(a)
        engine.feedback_b_a(0)
        engine.feedback_a_b(0)
        engine.feedback_b_b(a)
    elseif mode == DECOUPLED then
        engine.feedback_a_a(a)
        engine.feedback_b_a(0)
        engine.feedback_a_b(0)
        engine.feedback_b_b(b)
    elseif mode == SERIES then
        --TODO
    elseif mode == PINGPONG then
        engine.feedback_a_a(0)
        engine.feedback_b_a(a)
        engine.feedback_a_b(a)
        engine.feedback_b_b(0)
    elseif mode == SENDRETURN then
        --TODO
    end
end

local function set_out_amps()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = util.dbamp(params:get('out_level_a'))
    local b = util.dbamp(params:get('out_level_b'))

    if mode == COUPLED or mode == PINGPONG then
        engine.amp_out_left_a(a)
        engine.amp_out_right_a(0)
        engine.amp_out_left_b(0)
        engine.amp_out_right_b(a)
    elseif mode == DECOUPLED then
        engine.amp_out_left_a(a)
        engine.amp_out_right_a(0)
        engine.amp_out_left_b(0)
        engine.amp_out_right_b(b)
    elseif mode == SERIES then
        --TODO
    elseif mode == SENDRETURN then
        --TODO
    end
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
            id = 'time '..del, type = 'control', action = set_times,
            controlspec = cs.def{
                min = 0, max = 6, default = ({ 2, 0.01 })[i],
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
        warp = 'db', default = -6, units = 'dB',
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
