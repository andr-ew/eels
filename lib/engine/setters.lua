local function ampdb(amp) return math.log10(amp) * 20.0 end
local function dbamp(db) return math.pow(10.0, db*0.05) end

local log001 = math.log(0.001)

--src: https://github.com/supercollider/supercollider/blob/50281a1f265a8a4684507b3f656b95af9c5c9ad8/include/plugin_interface/SC_InlineUnaryOp.h#L273
local function decay_amp(delay_time, decay_time) 
    return math.exp(log001 * delay_time/decay_time) 
end
local function amp_decay(delay_time, amp) 
    return delay_time/(math.log(amp)/log001) 
end

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

local function get_time_seconds(del)
    local hz = params:get('root')

    local semitone, volt, mult
    if del=='sum' then
        semitone = params:get('fine') - 1
        volt = params:get('time a') 
                + params:get('time b')
                + mod.get('time a')
                + mod.get('time b')
        mult = mults[params:get('range a')]
    else
        semitone = params:get('fine') - 1
        volt = params:get('time '..del)
                + mod.get('time '..del)
        mult = mults[params:get('range '..del)]
    end

    hz = hz * (2^(semitone/12)) * (2^volt) * (1/mult)

    return 1/hz
end

local set = {}

set.get_time_seconds = get_time_seconds
set.get_amp_feedback = get_amp_feedback

function set.in_amps(arc_silent)
    crops.dirty.screen = true
    if not (arc_silent == true) then crops.dirty.arc = true end

    local a = get_amp('in_level_a', 'input a')
    local b = get_amp('in_level_b', 'input b')

    if mode == COUPLED and input==STEREO then
        enabled['in_level_a'] = true
        enabled['in_level_b'] = false
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(0)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(a)
    elseif mode == COUPLED and input==MONO then
        enabled['in_level_a'] = true
        enabled['in_level_b'] = false
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(a)
        engine.amp_in_left_b(a)
        engine.amp_in_right_b(a)
    elseif (mode == DECOUPLED or mode == SERIES) and input==STEREO then
        enabled['in_level_a'] = true
        enabled['in_level_b'] = true
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(0)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(b)
    elseif (mode == DECOUPLED or mode == SERIES) and input==MONO then
        enabled['in_level_a'] = true
        enabled['in_level_b'] = true
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(a)
        engine.amp_in_left_b(b)
        engine.amp_in_right_b(b)
    elseif mode == PINGPONG then
        enabled['in_level_a'] = true
        enabled['in_level_b'] = true
        engine.amp_in_left_a(a)
        engine.amp_in_right_a(0)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(b)
    elseif mode == SENDRETURN then
        enabled['in_level_a'] = true
        enabled['in_level_b'] = false
        engine.amp_in_left_a(a)
        -- engine.amp_in_right_a(feedback)
        engine.amp_in_left_b(0)
        engine.amp_in_right_b(0)
    end
end

function set.times(arc_silent)
    crops.dirty.screen = true
    if not (arc_silent == true) then crops.dirty.arc = true end

    local a = get_time_seconds('a')
    local b = get_time_seconds('b')

    if mode == COUPLED then
        enabled['time a'] = true
        enabled['time b'] = true
        engine.time_a(a)
        engine.time_b(get_time_seconds('sum'))
    elseif mode == DECOUPLED or mode == SERIES then
        enabled['time a'] = true
        enabled['time b'] = true
        engine.time_a(a)
        engine.time_b(b)
    elseif mode == PINGPONG then
        enabled['time a'] = true
        enabled['time b'] = false
        engine.time_a(a)
        engine.time_b(a)
    elseif mode == SENDRETURN then
        enabled['time a'] = true
        enabled['time b'] = false
        engine.time_a(a)
        engine.time_b(a)
    end
end

function set.time_lags()
    local a = params:get('time lag a')
    local b = params:get('time lag b')

    if mode == COUPLED then
        engine.time_lag_a(a)
        engine.time_lag_b(a)
    elseif mode == DECOUPLED or mode == SERIES then
        engine.time_lag_a(a)
        engine.time_lag_b(b)
    elseif mode == PINGPONG then
        engine.time_lag_a(a)
        engine.time_lag_b(a)
    elseif mode == SENDRETURN then
        engine.time_lag_a(a)
        engine.time_lag_b(a)
    end
end

function set.feedbacks(arc_silent)
    crops.dirty.screen = true
    if not (arc_silent == true) then crops.dirty.arc = true end

    local a = get_amp_feedback('fb_level_a', 'feedback a')
    local b = get_amp_feedback('fb_level_b', 'feedback b')
    local time_a = get_time_seconds('a')
    local time_b = get_time_seconds('b')

    if mode == COUPLED then
        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = false
        engine.decay_a_a(amp_decay(time_a, a))
        engine.amp_b_a(0)
        engine.amp_a_b(0)
        engine.decay_b_b(amp_decay(get_time_seconds('sum'), a))
    elseif mode == DECOUPLED then
        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = true
        engine.decay_a_a(amp_decay(time_a, a))
        engine.amp_b_a(0)
        engine.amp_a_b(0)
        engine.decay_b_b(amp_decay(time_b, b))
    elseif mode == SERIES then
        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = true
        engine.decay_a_a(amp_decay(time_a, a))
        engine.amp_b_a(0)
        -- engine.amp_a_b(out_a)
        engine.decay_b_b(amp_decay(time_b, b))
    elseif mode == PINGPONG then
        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = false
        engine.decay_a_a(amp_decay(time_a, 0))
        engine.amp_b_a(a)
        engine.amp_a_b(a)
        engine.decay_b_b(amp_decay(time_b, 0))
    elseif mode == SENDRETURN then
        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = false
        engine.decay_a_a(amp_decay(time_a, 0))
        engine.amp_b_a(0)
        engine.amp_a_b(0)
        engine.decay_b_b(amp_decay(time_b, 0))

        engine.amp_in_right_a(a)
    end
end

function set.out_amps(arc_silent)
    crops.dirty.screen = true
    if not (arc_silent == true) then crops.dirty.arc = true end

    local a = get_amp('out_level_a', 'output a')
    local b = get_amp('out_level_b', 'output b')

    if mode == COUPLED or mode == PINGPONG then
        enabled['out_level_a'] = true
        enabled['out_level_b'] = false
        engine.amp_out_left_a(a)
        engine.amp_out_right_a(0)
        engine.amp_out_left_b(0)
        engine.amp_out_right_b(a)
    elseif mode == DECOUPLED then
        enabled['out_level_a'] = true
        enabled['out_level_b'] = true
        engine.amp_out_left_a(a)
        engine.amp_out_right_a(0)
        engine.amp_out_left_b(0)
        engine.amp_out_right_b(b)
    elseif mode == SERIES then
        enabled['out_level_a'] = true
        enabled['out_level_b'] = true
        engine.amp_out_left_a(a)
        engine.amp_out_right_a(0)
        engine.amp_out_left_b(0)
        engine.amp_out_right_b(b)

        engine.amp_a_b(a)
    elseif mode == SENDRETURN then
        enabled['out_level_a'] = true
        enabled['out_level_b'] = true
        engine.amp_out_left_a(a)
        engine.amp_out_right_a(1)
        engine.amp_out_left_b(0)
        engine.amp_out_right_b(0)
    end
end

return set
