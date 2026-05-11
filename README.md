# isochord

An isomorphic scale layout for the [monome grid](https://monome.org/docs/grid/), inspired by the Ableton Push. Play any scale in any key with consistent fingering patterns across the entire grid, with built-in chord voicing - running locally via iii.

Built on [iii](https://monome.org/docs/iii/)

---

## Requirements

- monome grid **16x8**
- [diii](https://diii.monome.org) (browser-based grid scripting environment)
- A DAW or MIDI device connected to the the grid

---

## Grid Layout

```
+---+---+---+---+---+--+---+---+---+---+---+---+---+---+---+---+
| Scale selector    |                                            |
|    (2x5)          |              Play area                     |
+---+---+---+---+---+              (11 x 8)                      |
|   (unused row)    |                                            |
+---+---+---+---+---+                                            |
| Root selector     |                                            |
|    (2x5)          |                                            |
+---+---+---+---+---+                                            |
| Chord spread(1x5) |                                            |
+---+---+---+---+---+                                            |
| Octave (2x5)      |                                            |
+---+---+---+---+---+--+---+---+---+---+---+---+---+---+---+---+
```

| Zone | Grid position | Function |
|---|---|---|
| Scale selector | x 1-5, y 1-2 | Choose from 10 scales |
| Root selector | x 1-5, y 4-5 | Choose root note (10 options) |
| Chord spread | x 1-5, y 6 | Number of simultaneous notes per press |
| Octave | x 1-5, y 7-8 | Shift octave range (C1 - C5) |
| Play area | x 6-16, y 1-8 | Isomorphic note grid |

---

## Controls

### Play area

The right 11x8 portion is the instrument. Each button triggers a note in the selected scale and root. The layout is isomorphic — any chord or melody shape works identically regardless of root or scale.

- Moving **right** steps up by 1 scale degree
- Moving **up** steps up by 3 scale degrees
- This creates a consistent quartal topology: the same shape always produces the same interval relationship

Held buttons light at **full brightness** (15). Any other grid position that resolves to the exact same MIDI note lights at **half brightness** (8). Root notes across the grid glow **dim** (4).

### Scale selector (y 1-2)

A 2x5 matrix selecting from 10 common scales. A smooth 2D gliding light tracks the current selection. When a new scale is pressed, its abbreviation fades in across the top-right of the grid.

| Position | Scale |
|---|---|
| y=1, x=1-5 | Mixolydian, Pentatonic, Harmonic Minor, Melodic Minor, Phrygian Dom. |
| y=2, x=1-5 | Major, Minor, Dorian, Phrygian, Lydian |

### Root selector (y 4-5)

A 2x5 matrix selecting the root note. The gliding light moves diagonally across the matrix when switching roots. The note name fades in on the grid when selected.

| Position | Notes |
|---|---|
| y=5, x=1-5 | A, Bb, B, C, D |
| y=4, x=1-5 | Eb, E, F, G, Ab |

A, Bb, and B automatically play one octave lower than the other roots so they sit below C in the same octave setting. Any notes that still fall outside MIDI range at extreme octave settings are silently suppressed — they won't light up or trigger.

### Chord spread (y 6)

A horizontal fill bar. Pressing further right stacks additional diatonic thirds on top of each note press, voiced within the current scale.

- x=1: single note
- x=2: dyad (root + third)
- x=3: triad
- x=4: seventh chord
- x=5: ninth chord

The bar fills from the left to visually reflect the current chord size.

### Octave selector (y 7-8)

A 2x5 Gaussian glow pad. The center of brightness shows the current octave. Press left for lower, right for higher. Notes outside MIDI range simply won't light up or sound.

| x | Octave |
|---|---|
| 1 | C1 |
| 2 | C2 |
| 3 | C3 (default) |
| 4 | C4 |
| 5 | C5 |


---

## MIDI

- Outputs on **channel 1** (`ch = 1` — change in source to reroute)
- Velocity is fixed at 127 (`vel = 1` selects the first entry in the velocity table)
- Note-off is sent immediately on button release
- Polyphonic — multiple buttons can be held simultaneously

---

## Installation

1. Open [diii](https://diii.monome.org) in your browser
2. Connect your grid
3. Upload `isochord.lua`

---

## Scale Reference

| Abbrev | Scale | Degrees |
|---|---|---|
| Mj | Major | 0 2 4 5 7 9 11 |
| Mi | Minor (Natural) | 0 2 3 5 7 8 10 |
| Do | Dorian | 0 2 3 5 7 9 10 |
| Ph | Phrygian | 0 1 3 5 7 8 10 |
| Ly | Lydian | 0 2 4 6 7 9 11 |
| Mx | Mixolydian | 0 2 4 5 7 9 10 |
| Pt | Pentatonic | 0 2 4 7 9 |
| Hm | Harmonic Minor | 0 2 3 5 7 8 11 |
| Mm | Melodic Minor | 0 2 3 5 7 9 11 |
| Pd | Phrygian Dom. | 0 1 4 5 7 8 10 |
