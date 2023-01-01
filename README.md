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

- **K2**: page
    - pages **A** & **B**
        - **E1**: time
        - **E2**: time lag
        - **E2**: feedback
        - **K3**: range
    - page **M**
        - **E1**: i/o
        - **E2**: lfo rate
        - **E3**: lfo depth
- **K1 (hold)**: mod assignment
    - pages **A** & **B**
        - **E1 - E3**: select modulation source for each param
    
## arc

- time a
- feedback a
- time b
- feedback b

## params

detailed description for each param below. note that many params use eurorack-native voltage units for pairity with crow input modulation, though eels is still designed to work well as standalone effect.

### modes

- **i/o**
    - **coupled**: all **B** controls are coupled with **A**, but **time b** is the sum of the **A** & **B** values.
    - **decoupled**: separate **A** & **B** controls.
    - **series**: decoupled controls, **A** delay routed into **B**.
    - **ping-pong**: all **B** controls coupled with **A**, ping-pong feedback between delays.
    - **send/return**: **A** delay only (left channel), external feedback loop (right channel). **for best results, be sure to zero out the system monitor level.**
        - input L: dry signal
        - output L: wet signal
        - output R: patch to the input of external effect (such as a filter)
        - input R: patch in from the output of external effect
- **range a** & **range b**
    - **delay**: use delay range for **time** (4.65s - 0.07s).
    - **comb**: use comb filter range for **time** (110hz - 7040hz).
- **input**: mono or stereo audio input. only effects **coupled**, **decoupled**, and **series** modes.

### time

- **time a** & **time b**: set the _delay time / comb filter resonant frequency_ as a volt/octave transponsition from the **root** & **fine** values. reference the table below for the actual value of each volt, assuming **fine = A** and **root = 440hz**.

    | volt   | **range = delay**     | **range = comb** |
    | ------ | ------------------- | -----------    |
    | 0      | 4.65 seconds        | 110 hz         |
    | 1      | 2.32 seconds        | 220 hz         |
    | 2      | 1.16 seconds        | 440 hz         |
    | 3      | 0.58 seconds        | 880 hz         |
    | 4      | 0.29 seconds        | 1760 hz        |
    | 5      | 0.14 seconds        | 3520 hz        |
    | 6      | 0.07 seconds        | 7040 hz        |  
- **time a quant** & **time b quant**
    - **free**: continuous control over **time**.
    - **oct**: **time** is quantized to whole numbers. this turns **time** into an octave control in comb range, or a clock multiplier/divider in delay range with clock modulation
- **time lag a** & **time lag b**: set the lag/slew time for **time**. set to 0 for instantaneous changes (clicky), set > 0 for smoothed encoder movements or portamento when sequencing comb filter pitch.
- **fine**: fine tune the time value in semitones. adjusts the musical key when sequencing the comb filter pitch via crow. no need to adjust when sequencing over midi.
- **root**: set the concert pitch frequency for **time**.

### levels

- **feedback a** & **feedback b**: set the feedback level of the delay, or the decay time of the comb filter.
- **input a** & **input b**: audio input level
- **output a** & **output b**: audio output level

### modulation

set the modulation source for each modulatable param:

- **none**
- **lfo**: internal LFO.
- **crow in 1** & **crow in 2**: voltage from crow.
- **midi**: midi note value, converted to volt/octave.
- **clock**: an offset that will sync **time = 0** with the global clock tempo in delay mode. positive whole voltages will be multiples of the clock, negative whole number voltages will be divisions of the clock.

### lfo

set the parameters of the internal lfo. see [`lib/lfo`](https://monome.org/docs/norns/reference/lib/lfo) for more info.
