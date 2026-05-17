# isochord

An isomorphic scale instrument for the [monome grid](https://monome.org/docs/grid/), inspired by the Ableton Push layout. Play any scale in any key with consistent fingering patterns across the entire grid, with built-in chord voicing and real-time MIDI output.

Runs in [diii](https://diii.monome.org)

---

## Requirements

- monome grid **16x8**
- [diii](https://diii.monome.org) (browser-based grid scripting environment)
- A DAW or MIDI destination on your computer

---

## Grid Layout

```
+---+---+---+---+---+--+---+---+---+---+---+---+---+---+---+---+
| Scale selector    |                                            |
|    (2x5, y=1-2)   |              Play area                     |
+---+---+---+---+---+              (11 x 8)                      |
|   (gap row)       |                                            |
+---+---+---+---+---+                                            |
| Root selector |   |                                            |
|  (3x4, y=4-6) |   |                                            |
|  x=1-4        |   |                                            |
+---+---+---+---+---+                                            |
| Chord spread(1x5) |                                            |
+---+---+---+---+---+                                            |
| Octave    (1x5)   |                                            |
+---+---+---+---+---+--+---+---+---+---+---+---+---+---+---+---+
```

| Zone | Grid position | Function |
|---|---|---|
| Scale selector | x 1-5, y 1-2 | Choose from 10 scales |
| Root selector | x 1-4, y 4-6 | Choose root note (all 12 chromatic) |
| Chord spread | x 1-5, y 7 | Number of simultaneous notes per press |
| Octave | x 1-5, y 8 | Shift octave range |
| Play area | x 6-16, y 1-8 | Isomorphic note grid |

---

## Controls

### Play area

The right 11x8 portion is the instrument. Each button triggers a note in the selected scale and root. The layout is isomorphic — any chord or melody shape works identically regardless of root or scale.

- Moving **right** steps up by 1 scale degree
- Moving **up** steps up by 3 scale degrees
- This creates a consistent quartal topology: the same shape always produces the same interval relationship

| Brightness | Meaning |
|---|---|
| 15 | Button currently held |
| 8 | Same MIDI note held elsewhere on the grid |
| 6 | Note received via MIDI input (visual only) |
| 4 | Root note position |

### Scale selector (y 1-2)

A 2x5 matrix selecting from 10 common scales. A smooth 2D gliding light tracks the current selection — it glows bright while moving between buttons and dims once settled. Pressing a scale button briefly shows its abbreviation across the right side of the grid; releasing clears it immediately.

| Row | x=1 | x=2 | x=3 | x=4 | x=5 |
|---|---|---|---|---|---|
| y=1 | Mi | Do | Ph | Ly | Pd |
| y=2 | Mj | Pt | Hm | Mm | Mx |

### Root selector (y 4-6, x 1-4)

A 3x4 matrix covering all 12 chromatic notes, arranged in ascending order from C. A smooth 2D gliding light tracks the current selection. Pressing and holding shows the note name; releasing clears it.

```
y=4:  C   Db  D   Eb
y=5:  E   F   Gb  G
y=6:  Ab  A   Bb  B
```

Roots Ab through B automatically play one octave lower than C through G so all roots sit in the same relative octave range.

### Chord spread (y 7)

A horizontal fill bar. Pressing further right stacks additional diatonic thirds on top of each note press, voiced within the current scale. Unselected buttons are unlit.

| x | Voicing |
|---|---|
| 1 | Single note |
| 2 | Dyad |
| 3 | Triad |
| 4 | Seventh chord |
| 5 | Ninth chord |

### Octave selector (y 8)

A single-row Gaussian glow. The center of brightness shows the current octave. Press left for lower, right for higher.

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
- Incoming MIDI notes are visualized on the play area at brightness 6 (no note-on is re-sent, no loops)

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
