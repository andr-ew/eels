local function ampdb(amp) return math.log10(amp) * 20.0 end
local function dbamp(db) return math.pow(10.0, db*0.05) end

local function get_amp(id)
    local minval = -math.huge
    local maxval = 0
    local range = dbamp(maxval) - dbamp(minval)

    local volt = params:get(id)
    local scaled = volt/4
    local db = ampdb(scaled * scaled * range + dbamp(minval))
    local amp = dbamp(db)

    return amp
end
local function get_amp_feedback(id)
    local range = params:get('range a')
    local volt = params:get(id)
    local scaled = volt/5
    
    if range == COMB then
        if volt > 0 then
            scaled = scaled^(1/5)
        else
            scaled = math.abs(scaled)^(1/5)
        end
    end

    return scaled
end

local function set_in_amps()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = get_amp('in_level_a')
    local b = get_amp('in_level_b')

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
        engine.amp_in_left_a(a)
        -- engine.amp_in_right_a(feedback)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(0)
    end
end

local mults = { [DELAY] = 2^11, [COMB] = 2^2 }

--local
function get_time_seconds(del, add)
    local hz = params:get('root')

    local semitone, volt, mult
    if del=='sum' then
        semitone = params:get('fine a') - 1
        volt = params:get('time a') + params:get('time b')
        mult = mults[params:get('range a')]
    else
        semitone = params:get('fine '..del) - 1
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
        engine.time_b(a)
    end
end

local function set_feedbacks()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = get_amp_feedback('fb_level_a')
    local b = get_amp_feedback('fb_level_b')

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
        engine.feedback_a_a(a)
        engine.feedback_b_a(0)
        -- engine.feedback_a_b(out_a)
        engine.feedback_b_b(b)
    elseif mode == PINGPONG then
        engine.feedback_a_a(0)
        engine.feedback_b_a(a)
        engine.feedback_a_b(a)
        engine.feedback_b_b(0)
    elseif mode == SENDRETURN then
        engine.feedback_a_a(0)
        engine.feedback_b_a(0)
        engine.feedback_a_b(0)
        engine.feedback_b_b(0)

        engine.amp_in_right_a(a)
    end
end

local function set_out_amps()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = get_amp('out_level_a')
    local b = get_amp('out_level_b')

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
        engine.amp_out_left_a(a)
        engine.amp_out_right_a(0)
        engine.amp_out_left_b(0)
        engine.amp_out_right_b(b)

        engine.feedback_a_b(a)
    elseif mode == SENDRETURN then
        engine.amp_out_left_a(a)
        engine.amp_out_right_a(1)
        engine.amp_out_left_b(0)
        engine.amp_out_right_b(0)
    end
end

--add mode params
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
    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            id = 'range '..del, type = 'option',
            options = ranges, default = DELAY, action = function()
                set_times()
                set_feedbacks()
            end,
        }
    end
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
        -- params:add{
        --     id = 'course '..del, type = 'number',
        --     min = -4, max = 4, default = 0, action = set_times,
        --     formatter = function(self) return self.value..' v/oct' end
        -- }

    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            id = 'fine '..del, type = 'option',
            options = notes, action = set_times,
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
        action = set_times,
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
            action = set_feedbacks,
        }
    end
    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            name = 'input '..del, id = 'in_level_'..del, type = 'control',
            controlspec = cs_lvl, action = set_in_amps,
        }
    end
    for i,del in ipairs{ 'a', 'b' } do
        params:add{
            name = 'output '..del, id = 'out_level_'..del, type = 'control',
            controlspec = cs_lvl, action = set_out_amps,
        }
    end
    --TODO: width
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
