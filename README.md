# eels
dual digital delay / comb filter (WIP)

## hardware

**required**

- [norns](https://github.com/p3r7/awesome-monome-norns) (220321 or later)

**reccommended**

- midi mapping

**also supported**

- [crow](https://monome.org/docs/crow/)


## install

~ not done yet ~

## documentation

- K2: page
- pages
    - m
        - E1: mode
        - E2: mod rate
        - E3: mod depth
    - 1 & (2)
        - E1: quality
        - E2: feedback
        - E3: time
        - K2: range
- K1: mod assignment
    - options per-control: none, int, (crow input) 1, 2

(page 2 is only accessible in dual mode)

## notes

modes
- stereo
- dual (separate controls)
- ping-pong
- send/return

range: lo, hi. 
- low is delay, hi is resonator/comb filter/karplus range
- units:
    - lo: seconds
    - hi: note pitch +- cents
- in hi mode time mod is v/oct

## engine commands

- `rate(voice, seconds)`
- `quality(voice, val)`
- `amp_in(ch, voice, amp)`
- `amp_out(voice, ch, amp)`
- `feedback(voice_out, voice_in, amp)`
