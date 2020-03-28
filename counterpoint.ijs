NB. Functions to generate melodies according to counterpoint rules.
NB. Example:
NB.    9 melody _3
NB. _3 0 4 9 7 5 2 _1 _3
NB. A 9-note melody starting 3 semitones below a major key's root
NB. (the relative minor).

NB. Notes are encoded as semitone offsets from the center 0.
NB. To convert to frequencies, use trans from synth.ijs.
NB. Here we use 0 as the root of a major scale. Choosing a different
NB. root note gives a different mode, or kind of scale.

NB. Melody generators take a length on the left and a root note on the
NB. right. Since the melody will begin and end on the root, the length
NB. should be one more than a multiple of the number of notes per
NB. measure if each note has the same duration. This places both the
NB. starting and ending notes at the beginning of a measure. The root
NB. note is for determining the mode. If you want to transpose without
NB. changing the mode, just add to or subtract from the output.

NB. Possible modes are:
NB.   _12   0  Ionian (major)
NB.   _10   2  Dorian
NB.    _8   4  Phrygian
NB.    _7   5  Lydian
NB.    _5   7  Mixolydian
NB.    _3   9  Aeolian (minor)
NB.    _1  11  Locrian
NB. Of these, Ionian and Aeolian are by far the most common today.
NB. Roots near or slightly below the middle work best for this script.

NB. The allowed notes go from _12 to 11: just short of two octaves.
notes=: }:i:12
NB. A major scale starting at 0.
scale=: (,~ -&12) 0 2 4 5 7 9 11
NB. A root note defines a minor scale if the note a minor third (three
NB. semitones) above it is in the scale, and a major scale if the note
NB. a major third above it (four semitones) is in the scale.
minor=:(#~ 3&+ e. ]) scale
major=:(#~ 4&+ e. ]) scale
NB. Allowed intervals by counterpoint rules. Tritones (six semitones)
NB. and large intervals cannot be used.
allowed=: (i:8)-._8 _6 6
NB. Allowed second-to-last notes by root note: must be one note away.
NB. For scales which start and end with a whole note, approaching from
NB. below should use a note out of the scale which is only one semitone
NB. away from the root. But this code uses -/ instead of -~/, so this
NB. correction is not actually performed here (but the generators
NB. wouldn't handle it anyway).
ending=: +&1 0^:(4 = -/)"1 ]0 2 {"1 ]3 ]\ _13,scale,12

NB. Given the previous two notes, return a list of allowed next notes.
choices =: 3 : 0
  last=.{:y
  NB. Must be in the scale and an allowed interval away from last note
  choices=.scale ([#~e.) last+allowed
  if. 4 < |s=.-/ y do.
    NB. Last interval was large. Must go back one step or outline an octave.
    choices=. {. (/: |@-&last) (#~ s =&* -&last) choices
    (#~ e.&scale) choices , last + ((5=|s) # (-*s) * 3 4 7) , ((7=|s) # (-*s)*5)
    return.
  end.
  NB. Can't repeat a note three times
  if. s=0 do. choices=.choices-.last end.
  NB. Can go out of the scale to avoid the F->B tritone
  if. _7 5 e.~ last do. choices=./:~ choices, _2, (5=last)#10 end.

  choices
)

NB. ---------------------------------------------------------
NB. A simple generator, which mostly just follows the rules.
simple_melody =: 4 : 0
  mel=., last=.y
  length=.x
  end=.ending{~ scale i. y
  NB. Possibly add a new note each time until we have enough
  while. x> #mel do.
    c=.choices _2 {. mel

    if. 2=x-$mel do. c=. (#~ e.&end) c end.
    if. 1=x-$mel do. c=. (#~ =&y) c end.
    NB. Weights chosen to make single steps most likely
    w=.(% +/) ([: -~/ 1 18 % 1 12+*:)"0 c-last
    NB. Pick a random note, or backtrack if no notes are possible
    if. #c do. mel=.mel, last=.c {~ (+/\ I. ?@0:) w
    else. last=.{: mel=.}:mel end.
  end.
)

NB. ---------------------------------------------------------
NB. A more complicated generator.
melody =: 4 : 0
  assert. y e. scale
  if. y e. major do.
    startchord=.major
    chord=.4 3
  else. startchord=.minor
    chord=.3 4 end.

  mel=., last=.y
  length=.x
  end=.ending{~ scale i. y
  while. x> #mel do.
    c=.choices _2 {. mel

    if. 2=x-$mel do. c=. (#~ e.&end) c end.
    if. 1=x-$mel do. c=. (#~ =&y) c end.
    w=.(% +/) ([: -~/ 1 18 % 1 12+*:)"0 c-last

    beat=.4|#mel
    if. (0=beat)*. *./ (startchord e. c) do. w=.(% +/) (c e. startchord) + w end.
    if. (1=beat)*. (r=.last+{.chord) e.c do. w=.(% +/) 5 (c i.r)} w end.
    if. (2=beat)*. (({. chord) = -~/_2{.mel) *. (r=.last+{:chord) e.c do. w=.r=c end.

    if. #c do. mel=.mel, last=.c {~ (+/\ I. ?@0:) w
    else. last=.{: mel=.(->:?3) }. mel end.
  end.
)

NB. ---------------------------------------------------------
n =. 3 : 0
  s=.$y
  short=.0 1
  long=.2 3 5
  pos=.short, (long #~ -. 2 |#y)
  prob=.(% +/) % 1+pos
  l=. pos{~ (+/\ I. ?@0:) prob
  y , 1, 0 #~ l
)
