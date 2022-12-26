local function ampdb(amp) return math.log10(amp) * 20.0 end
local function dbamp(db) return math.pow(10.0, db*0.05) end

local log001 = math.log(0.001)

--src: https://github.com/supercollider/supercollider/blob/50281a1f265a8a4684507b3f656b95af9c5c9ad8/include/plugin_interface/SC_InlineUnaryOp.h#L273
local function decay_amp(delay_time, decay_time) 
    if delay_time==0 or decay_time==0 then return 0 end

    local positive = decay_time > 0

    local amp = math.exp(log001 * delay_time/math.abs(decay_time)) 

    if positive then return amp else return -amp end
end
local function amp_decay(delay_time, amp) 
    if delay_time==0 or amp==0 then return 0 end

    local positive = amp > 0     
    local decay = delay_time/(math.log(math.abs(amp))/log001)

    if positive then return decay else return -decay end
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
local function volt_decay(volt)
    return (volt/5)^2 * 10 * (volt>0 and 1 or -1)
end
local function get_feedback_amp(time, del)
    local id, mod_id = 'fb_level_'..del, 'feedback '..del

    local range = params:get('range '..del)
    local volt = params:get(id) + mod.get(mod_id)
    
    if range == COMB then
        local decay = volt_decay(volt)
        local amp = decay_amp(time, decay)
        return amp
    elseif range == DELAY then
        return volt/5
    end
end
local function get_feedback_decay(time, del)
    local id, mod_id = 'fb_level_'..del, 'feedback '..del

    local range = params:get('range '..del)
    local volt = params:get(id) + mod.get(mod_id)

    if range == COMB then
        return volt_decay(volt)
    elseif range == DELAY then
        return amp_decay(time, volt/5)
    end
end

local mults = { [DELAY] = 2^11, [COMB] = 2^2 }

local function time_volt_seconds(volt, range)
    local hz = params:get('root')
    local semitone = params:get('fine') - 1
    local mult = mults[range]
    
    local seconds = 1/(hz * (2^(semitone/12)) * (2^volt) * (1/mult))

    seconds = util.clamp(seconds, (1/20000), 10.9) -- 2^19 samples / 48000

    return seconds
end

local function time_seconds_volt(seconds, range)
    local positive = seconds >= 0
    local hz = params:get('root')
    local semitone = params:get('fine') - 1
    local mult = mults[range]

    --showing my work :)
    --seconds = 1/(hz * (2^(semitone/12)) * (2^volt) * (1/mult))
    --hz * (2^(semitone/12)) * (2^volt) * (1/mult) = 1/seconds
    --2^volt = 1/(seconds * hz * (2^(semitone/12)) * (1/mult))
    local volt = math.log(1/(math.abs(seconds) * hz * (2^(semitone/12)) * (1/mult)), 2)

    if positive then return volt else return -volt end
end

local function get_time_seconds(del)
    if del=='sum' then
        local range = params:get('range a')
        local volt = params:get('time a') 
                + params:get('time b')
                + mod.get('time a')
                + mod.get('time b')

        return time_volt_seconds(volt, range)
    else
        local range = params:get('range '..del)
        local volt = params:get('time '..del)
                + mod.get('time '..del)
        
        return time_volt_seconds(volt, range)
    end
end

local function get_lag_seconds(del)
    local volt = params:get('time lag '..del)
    local range = params:get('range '..del)

    if range == COMB then
        return (volt/5)^4
    elseif range == DELAY then
        return volt
    end
end

local set = {}

set.time_volt_seconds = time_volt_seconds
set.time_seconds_volt = time_seconds_volt
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

function set.time_lags(arc_silent)
    crops.dirty.screen = true
    if not (arc_silent == true) then crops.dirty.arc = true end

    local a = get_lag_seconds('a')
    local b = get_lag_seconds('b')

    if mode == COUPLED then
        enabled['time lag a'] = true
        enabled['time lag b'] = false
        engine.time_lag_a(a)
        engine.time_lag_b(a)
    elseif mode == DECOUPLED or mode == SERIES then
        enabled['time lag a'] = true
        enabled['time lag b'] = true
        engine.time_lag_a(a)
        engine.time_lag_b(b)
    elseif mode == PINGPONG then
        enabled['time lag a'] = true
        enabled['time lag b'] = false
        engine.time_lag_a(a)
        engine.time_lag_b(a)
    elseif mode == SENDRETURN then
        enabled['time lag a'] = true
        enabled['time lag b'] = false
        engine.time_lag_a(a)
        engine.time_lag_b(a)
    end
end

function set.feedbacks(arc_silent)
    crops.dirty.screen = true
    if not (arc_silent == true) then crops.dirty.arc = true end

    local time_a = get_time_seconds('a')
    local time_b = get_time_seconds('b')
    local a_amp = get_feedback_amp(time_a, 'a')
    local b_amp = get_feedback_amp(time_b, 'b')
    local a_decay = get_feedback_decay(time_a, 'a')
    local b_decay = get_feedback_decay(time_b, 'b')

    if mode == COUPLED then
        local time_sum = get_time_seconds('sum')
        local decay_sum = get_feedback_decay(time_sum, 'a')

        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = false
        engine.decay_a_a(a_decay)
        engine.amp_b_a(0)
        engine.amp_a_b(0)
        engine.decay_b_b(decay_sum)
    elseif mode == DECOUPLED then
        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = true
        engine.decay_a_a(a_decay)
        engine.amp_b_a(0)
        engine.amp_a_b(0)
        engine.decay_b_b(b_decay)
    elseif mode == SERIES then
        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = true
        engine.decay_a_a(a_decay)
        engine.amp_b_a(0)
        -- engine.amp_a_b(out_a)
        engine.decay_b_b(a_decay)
    elseif mode == PINGPONG then
        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = false
        engine.decay_a_a(0)
        engine.amp_b_a(a_amp)
        engine.amp_a_b(a_amp)
        engine.decay_b_b(0)
    elseif mode == SENDRETURN then
        enabled['fb_level_a'] = true
        enabled['fb_level_b'] = false
        engine.decay_a_a(0)
        engine.amp_b_a(0)
        engine.amp_a_b(0)
        engine.decay_b_b(0)

        engine.amp_in_right_a(a_amp)
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
