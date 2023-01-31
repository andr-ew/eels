local v = { a = 0, b = 0 }
local x = { a = 0, b = 0 }

local delta_x = -15
local spring = 20
local damp = 5
local mass = 0.4

function ui.set_time(del, t)
    local old = ui.time[del]
    local new = t
    local d = new - old
    local dx = (d * delta_x)
    local sign = dx < 0 and -1 or 1
    
    x[del] = x[del] + (dx^1 * 1)*2

    ui.time[del] = new
end

local phase = 0
local fps = 60

--TODO: lfo only effects eels when mapped

clock.run(function() 
    while true do
        local step = 1/fps

        do
            local period = params:get('lfo_free_lfo') * 2
            phase = phase + (step * (1/period))
            while phase > 1 do phase = phase - 1 end
        end

        --src: https://www.khanacademy.org/computing/pixar/simulation/hair-simulation-code/pi/step-3-damped-spring-mass-system
        for _,e in ipairs{ 'a', 'b' } do
            local f_spring = -1 * spring * x[e]
            local f_damp = damp * v[e]
            local f = f_spring + mass * (0 - f_damp)
            local a = f / mass

            v[e] = v[e] + a*step
            x[e] = x[e] + v[e]*step*2
        end

        crops.dirty.screen = true
        clock.sleep(step)
    end
end)

local function Eel()
    return function(props)
        if crops.device == 'screen' and crops.mode == 'redraw' then
            local width = 40
            local lowamp = 0.4
            local highamp = 3 + (params:get('lfo_depth_lfo') / 10)

            local del = props.del
            local left = props.x
            local top = props.y
            local ph_off = props.phase
            local height = props.swim_y

            screen.level(math.floor(ui.out_amps[del] * 10))

            local length = width
            local humps = 2


            for j = 1, length do
                local amp = (
                    math.sin(
                        (
                            (phase + ph_off)*humps + j/length
                        )
                        * (humps * 2) * math.pi
                    ) 
                    * util.linlin(
                        1, length / 2, lowamp, 
                        util.clamp(highamp - math.abs(height*2), lowamp/2, highamp), 
                        j < (length / 2) and (j + 10) or length - j - 3
                    ) 
                    - (
                        util.linexp(0, 1, 0.5, 6, j/length) * (height)
                    ) 
                ) * (
                    1 + (math.abs(height) * ((j / length) + 0.1))
                )
               
                screen.pixel(left + j - 1, top + amp)
            end
            screen.fill()
        end
    end
end

local function Gfx()
    local _eelA = Eel()
    local _eelB = Eel()

    return function()
        local y = 25
            
        _eelA{ del = 'a', x = ui.x[1], y = y, phase = 0, swim_y = x.a }
        _eelB{ del = 'a', x = ui.x[2], y = y, phase = 0.5, swim_y = x.b }
    end
end

return Gfx
