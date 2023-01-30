local phase = 0
local fps = 60
local period = 2

clock.run(function() 
    while true do
        period = params:get('lfo_free_lfo') * 2

        phase = phase + ((1/fps) * (1/period))
        while phase > 1 do phase = phase - 1 end

        crops.dirty.screen = true
        clock.sleep(1/fps)
    end
end)

local function Eel()
    return function(props)
        if crops.device == 'screen' and crops.mode == 'redraw' then
            local width = 40
            local lowamp = 0.4
            local highamp = 3

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
                        1, length / 2, lowamp, highamp, 
                        j < (length / 2) and (j + 6) or length - j - 2
                    ) 
                    - (
                        util.linexp(0, 1, 0.5, 6, j/length) 
                        * (height)
                    ) 
                ) * (
                    1 + (math.abs(height) * (j / length))
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
            
        _eelA{ del = 'a', x = ui.x[1], y = y, phase = 0, swim_y = 0 }
        _eelB{ del = 'a', x = ui.x[2], y = y, phase = 0.5, swim_y = 0 }
    end
end

return Gfx
