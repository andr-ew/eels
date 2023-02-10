# patch notes

watch the full video: [link]

## 1. DK Mountain

[video]

set the modulation source of **time** to **clock** to sync a delay with norns' global clock at whole number intervals. setting **time a quant** or **time b quant** to **oct** locks **time** into whole-number multiples & divisions of the clock. play with time to add scattered, pitch-shifted fills.

**input:** plucked synthesizer arpeggio, synced to global clock

**key settings**
- clock tempo: 48bpm
- i/o: coupled
- range a: delay
- range b: delay
- time a: 0. increase to add fills
- time a quant: oct
- time b: 0.01
- time lag a: 3.00
- feedback a: 2.5
- modulation sources
  - time a: clock

## 2. bbbbbbbbouncebouncebboouunceee

[video]

**time** is animated especially well with stepped modulation slewed with the internal lag, lending the bouncy ball effect as time ramps up or down. coupling feedback to the same mod source ups the anty. with crow connected, send in stepped voltages from a sequencer, keyboard, or sample and hold module. alternatively, you can source modulation from a midi keyboard or an internal lfo with **shape** set to **random** and **lfo min**, **lfo max**, and **lfo depth** increased to add 3-6 volts of range to the output.

**input:** polysynth melody

**key settings**
- i/o: coupled
- range a: delay
- range b: delay
- time a: -2
- time b: 0.01
- time lag a: 3.00
- feedback a: -1.7
- modulation sources
  - time a: crow, midi, or lfo
  - feedback a: same as time a

## 3. electric wolves

[video]

comb filters can act like a strange resonant body around a musical input signal, with a multitude of clippy, resonant [wolf tones](https://en.wikipedia.org/wiki/Wolf_tone) throughout the chromatic scale. any noise present at the input contributes to a buzzy drone, whose pitch is controlled by **time**.

**input:** noisy filtered chords with a little bit of attack.

**key settings**
- i/o: coupled
- range a: comb
- time a: 0. adjust to other octaves based on the range of the input chords.
- time a quant: oct
- time b: 0.01
- feedback a: 4.8. sets decay time of resonant tones.
- fine: set to the same key as the input chords.

## 4. stringed

eels can extend most subtractive synthesizers, turning it into a plucked string synth. sent your synthesizer to output short bursts of filtered noise (no oscillators). then, connect the midi output of your synthesizer to norns & set the **time** modulation source to midi. now, in comb filter mode, eels will transform the input noise bursts into plucked tones, with pitch controlled by the synth's keyboard.

**input:** filtered noise bursts.

**key settings**
- i/o: coupled
- range a: comb
- time a: 0. adjust to set octave.
- time a quant: oct
- time b: 0.01
- feedback a: 4.8. sets decay time of string tone. negative values result in a square-wave-like tone.
- modulation sources
  - time a: midi or crow sequence

## 5. filterghost

the send/return **i/o mode** allows you to route any mono audio effect into the feedback loop of the delay. a modulated, resonant filter is a spooky choice.

**input:** synth

**key settings**
- i/o: send/return
- range a: delay
- time a: 3
- feedback a: 4.5
- modulation sources
  - time a: crow or lfo

## 6. thin ice skating

it's fun to abuse the midi modulation in delay mode. sending the modulation source of time to the same midi signal of a synth on the input sounds a lot like this cool video of [thin ice skating](https://www.youtube.com/watch?v=v3O9vNi-dkA&list=WL&index=20).

**input:** plucked synth with a bit of filtered noise

**key settings**
- i/o: coupled
- range a: delay
- time a: 0.
- time b: 0.01
- feedback a: 2.5
- lag a: 4. might need to fine tune to get the right laser souned
- modulation sources
  - time a: midi or crow sequence, same pitch as the input voice

