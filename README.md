# eels (WIP)

dual digital delay & comb filter with multiple routing modes, internal/external modulation

## hardware

**required**

- [norns](https://github.com/p3r7/awesome-monome-norns) (220321 or later)

**reccommended**

- midi mapping
- mixer with send or line-level compatible modular system

**also supported**

- [crow](https://monome.org/docs/crow/)


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
        - E1: quality
        - E2: feedback
        - E3: time
        - K2: range
- K1: mod assignment
    - options per-control: none, lfo, (crow input) 1, 2

(page b is only accessible in dual mode)

## notes

modes
- stereo: `b` controls match `a`
- dual: separate `a` & `b` controls
- ping-pong: `b` controls match `a`, ping/pong feedback
- send/return: `a` delay only, external feedback loop

range: lo, hi. 
- low is delay, hi is resonator/comb filter/karplus range
- units:
    - lo: seconds
    - hi: note pitch +- cents
- in hi mode time mod is v/oct

## engine commands

- `rate_a(seconds)`
- `rate_b(seconds)`
- `quality_a(crossfade)`
- `quality_b(crossfade)`
- `amp_in_a(ch, amp)`
- `amp_in_b(ch, amp)`
- `amp_out_a(ch, amp)`
- `amp_out_b(ch, amp)`
- `feedback_a(voice_in, amp)`
- `feedback_b(voice_in, amp)`
