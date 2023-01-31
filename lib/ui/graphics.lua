local v = { a = 0, b = 0 }
local x = { a = 0, b = 0 }
local phase = { a = 0, b = 0 }

local delta_x = -10
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

local fps = 60

--TODO: lfo only effects eels when mapped

clock.run(function() 
    while true do
        local step = 1/fps

        for _,e in ipairs{ 'a', 'b' } do
            do
                local volts = params:get(set.get_id_volts(e))
                local rate = util.linexp(
                    -2, 4, 1/8, 2, volts
                )
                phase[e] = phase[e] + (step * rate)
                while phase[e] > 1 do phase[e] = phase[e] - 1 end
            end
            do
                --src: https://www.khanacademy.org/computing/pixar/simulation/hair-simulation-code/pi/step-3-damped-spring-mass-system
                local f_spring = -1 * spring * x[e]
                local f_damp = damp * v[e]
                local f = f_spring + mass * (0 - f_damp)
                local a = f / mass

                v[e] = v[e] + a*step
                x[e] = x[e] + v[e]*step*2
            end
        end

        crops.dirty.screen = true
        clock.sleep(step)
    end
end)

local function Eel()
    return function(props)
        if crops.device == 'screen' and crops.mode == 'redraw' then
            local del = props.del
            local left = props.x
            local top = props.y
            local ph_off = props.phase
            local height = props.swim_y

            local width = 45
            local lowamp = 0.4
            local highamp = util.linlin(
                -5, 5, -7, 7, params:get('fb_level_'..del)
            )

            local length = math.ceil(util.clamp(width - (math.abs(height) * 10), 1, width))
            local humps = params:string('range '..del) == 'comb' and 3 or 2

            for j = 1, length do
                local amp = (
                    math.sin(
                        (
                            (phase[del] + ph_off)*humps + j/length
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
               
                screen.level(math.floor(ui.out_amps[del] * 10))
                screen.pixel(left + j - 1, top + amp)
                screen.fill()

                local lvl = math.floor(ui.out_amps[del] * 10)
                lvl = math.ceil(j > (length - 8) and lvl or lvl/4)
                lvl = j == (length - 2) and 1 or lvl

                screen.level(lvl)
                screen.pixel(left + j - 1, top + amp - 1)
                screen.fill()
            end
        end
    end
end

local function Gfx()
    local _eelA = Eel()
    local _eelB = Eel()

    return function()
        local y = 25
            
        _eelA{ del = 'a', x = ui.x[1], y = y, phase = 0, swim_y = x.a }
        _eelB{ del = 'b', x = ui.x[2], y = y, phase = 0.5, swim_y = x.b }
    end
end

return Gfx
