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

## documentation

- K2: page
- pages
    - m
        - E1: mode
        - E2: lfo rate
        - E3: lfo depth
    - a & (b)
        - E1: time
        - E2: level
        - E2: feedback
        - K3: range
- K1: mod assignment
    - options per-control (time): none, lfo, midi, cv 1, cv 2, clock 1, clock 2, clock global
    - options per-control (other): none, lfo, volt 1, volt 2


(page b is only accessible in dual mode)

## notes

routing
- **coupled**: `b` controls match `a`, but `time b` is the sum of the `a` & `b` controls.
- **decoupled**: separate `a` & `b` controls.
- **series**: decoupled controls, `a` routed into `b`.
- **ping-pong**: `b` controls match `a`, ping-pong feedback between delays.
- **send/return**: `a` delay only, external feedback loop.

range: low, high. 
- low is delay, hi is resonator/comb filter/karplus range
- units:
    - low: seconds
    - high: note pitch +- cents
- in hi mode time mod is v/oct

## engine commands

- `amp_in_left_a(amp)`
- `amp_in_right_a(amp)`
- `amp_in_left_b(amp)`
- `amp_in_right_b(amp)`
- `feedback_b_a(amp)`
- `feedback_b_b(amp)`
- `feedback_a_a(amp)`
- `feedback_a_b(amp)`
- `time_a(seconds)`
- `time_b(seconds)`
- `interpolation(<1: none, 2: linear, 4: cubic>)`
- `amp_out_left_a(amp)`
- `amp_out_right_a(amp)`
- `amp_out_left_b(amp)`
- `amp_out_right_b(amp)`
