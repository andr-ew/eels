include 'lib/crops/core'
_arc = include 'lib/crops/routines/arc'

a = arc.connect()

engine.name = 'Eels'

time = 1 - 0.2

crops.connect_arc(function() 
    _arc.number{
        n = 1, min = 0, max = 1, sensitivity = 1/64/4,
        state = { 
            time, 
            function(v) 
                time = v 
                crops.dirty.arc = true
                engine.time_a(1 - v)
                engine.time_b((1 - v) + 0.1)
            end 
        }
    }
end, a)

function init()
end
