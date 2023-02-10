# patch notes

watch the full video: [link]

## 1. DK Mountain

[video]

set the modulation source of **time** to **clock** to sync a delay with norns' global clock at whole number intervals. setting **time a quant** or **time b quant** to **oct** locks **time** into whole-number multiples & divisions of the clock. play with time to add scattered, pitch-shifted fills.

**input:** plucked synthesizer sequence, synced to global clock

**key settings**
- clock tempo: 48bpm
- i/o: coupled
- range a: delay
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

[video]

eels can extend most subtractive synthesizers, turning it into a plucked string synth. sent your synthesizer to output short bursts of filtered noise (no oscillators). then, connect the midi output of your synthesizer to norns & set the **time** modulation source to midi. now, in comb filter mode, eels will transform the input noise bursts into plucked tones, with pitch controlled by the synth's keyboard.

**input:** filtered noise bursts.

**key settings**
- i/o: coupled
- range a: comb
- time a: 0. adjust to set octave.
- time a quant: oct
- time b: 0.01
- feedback a: 4.8. sets decay time of string tone. negative values result in a square-wave-like tone.
- time lag a: 0
- modulation sources
  - time a: midi or crow sequence

## 5. filterghost

[video]

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

[video]

it's fun to abuse midi modulation in delay mode. sending the modulation source of time to the same midi signal of a synth on the input sounds a lot like this cool video of [thin ice skating](https://www.youtube.com/watch?v=v3O9vNi-dkA&list=WL&index=20).

**input:** plucked synth with a bit of filtered noise

**key settings**
- i/o: coupled
- range a: delay
- time a: 0.
- time b: 0.01
- feedback a: 2.5
- lag a: 1. might need to fine tune to get the right laser sound
- modulation sources
  - time a: midi or crow sequence, same pitch as the input voice

## 7. a CD skipping in the wind

[video]

a variation on [thin ice skating](#6-thin-ice-skating), this time removing the time lag, which means that there will be a click every time time is modulated by the input midi. turn that recently frozen nordic lake into a broken discman blowing through a meadow!

**input:** plucked synth with a bit of filtered noise

**key settings**
- i/o: coupled
- range a: delay
- time a: 0.
- time b: 0.01
- feedback a: 2.5
- time lag a: 0
- modulation sources
  - time a: midi or crow sequence, same pitch as the input voice

## 8. eel talk

[video]

the series **i/o mode** sends the output of eel `A` into the input of eel `B`. this lets us take the [stringed](#4-stringed) patch & add a modulated delay, for echoed plucks.

**input:** filtered noise bursts.

**key settings**
- i/o: series
- range a: comb
- time a: 0. adjust to set octave.
- time a quant: oct
- feedback a: 4.8. sets decay time of string tone. negative values result in a square-wave-like tone.
- time lag a: 3
- range b: delay
- time b: 2
- feedback b: 2.5
- time lag b: 3
- modulation sources
  - time a: midi or crow sequence
  - time b: lfo or crow

## 9. double dash

[video]

a variation on [DK Mountain](#1-DK-Mountain), this time using the dual **i/o mode** to get two separate delays with independent clock multiples.

**input:** plucked synthesizer sequence, synced to global clock

**key settings**
- clock tempo: 48bpm
- i/o: dual
- range a: delay
- time a: 1. sets left clock multiple/division
- time a quant: oct
- feedback a: 2.5
- time lag a: 3.00
- range b: delay
- time b: 2. sets left clock multiple/division
- time b quant: oct
- feedback b: 2.5
- time lag b: 3.00
- modulation sources
  - time a: clock
  - time b: clock
