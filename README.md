# eels (WIP)

dual digital delay / comb filter with a variety of i/o modes and modulation options

## hardware

**required**

- [norns](https://github.com/p3r7/awesome-monome-norns) (220321 or later)

**also supported**

- [crow](https://monome.org/docs/crow/)
- arc

## install

~ not done yet ~

## norns

- K2: page
    - pages
        - a & b
            - E1: time
            - E2: time lag
            - E2: feedback
            - K3: range
        - m
            - E1: mode
            - E2: lfo rate
            - E3: lfo depth
- K1 (hold): mod assignment
    - modulation sources: none, lfo, midi, crow in 1, crow in 2, clock
    
## arc

- time a
- feedback a
- time b
- feedback b

## params

### modes

- i/o
    - **coupled**: `b` controls coupled with `a`, but `time b` is the sum of the `a` & `b` controls.
    - **decoupled**: separate `a` & `b` controls.
    - **series**: decoupled controls, `a` delay routed into `b`.
    - **ping-pong**: `b` controls coupled with `a`, ping-pong feedback between delays.
    - **send/return**: `a` delay only, external feedback loop.
