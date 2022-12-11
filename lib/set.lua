local function ampdb(amp) return math.log10(amp) * 20.0 end
local function dbamp(db) return math.pow(10.0, db*0.05) end

local function get_amp(id, mod_id)
    local minval = -math.huge
    local maxval = 0
    local range = dbamp(maxval) - dbamp(minval)

    local volt = params:get(id) + mod.get(mod_id)
    local scaled = volt/4
    local db = ampdb(scaled * scaled * range + dbamp(minval))
    local amp = dbamp(db)

    return amp
end
local function get_amp_feedback(id, mod_id)
    local range = params:get('range a')
    local volt = params:get(id) + mod.get(mod_id)
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

local mults = { [DELAY] = 2^11, [COMB] = 2^2 }

local function get_time_seconds(del, add)
    local hz = params:get('root')

    local semitone, volt, mult
    if del=='sum' then
        semitone = params:get('fine a') - 1
        volt = params:get('time a') 
                + params:get('time b')
                + mod.get('time a')
                + mod.get('time b')
        mult = mults[params:get('range a')]
    else
        semitone = params:get('fine '..del) - 1
        volt = params:get('time '..del)
                + mod.get('time '..del)
        mult = mults[params:get('range '..del)]
    end

    hz = hz * (2^(semitone/12)) * (2^volt) * (1/mult)

    return 1/hz
end

local set = {}

function set.in_amps()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = get_amp('in_level_a', 'input a')
    local b = get_amp('in_level_b', 'input b')

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

function set.times()
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

function set.feedbacks()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = get_amp_feedback('fb_level_a', 'feedback a')
    local b = get_amp_feedback('fb_level_b', 'feedback b')

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

function set.out_amps()
    crops.dirty.screen = true
    crops.dirty.arc = true

    local a = get_amp('out_level_a', 'output a')
    local b = get_amp('out_level_b', 'output b')

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

return set
