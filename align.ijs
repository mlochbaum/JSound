0 : 0
Utilities for aligning a wave file to a point which is visible in its
waveform.

The file should initially be stored as PATH/name_.wav, where PATH and
name are arbitrary but there must be an _ before the extension.
To align, use

load '~user/Sound/align.ijs'
'PATH' align 'name'  NB. A plot of the first three seconds will be shown
zoom 6       NB. Each call reduces the range by a factor of 2-20,
...          NB. ending on a power of 10.
zoom 3       NB. Then it plots with the new range.
awrite 15    NB. Write the aligned waveform

In later runs with the same PATH, or if the variable PATH is defined
already, the left argument can be omitted.

For calls to zoom, the argument should be the first digit (or two if the
range is between 10^k and 2*10^k) of the alignment point according to the
plot. So initially if the point you want to align to falls between 60000
and 70000, use 6, and if it falls between 120000 and 130000, use 12.

The argument to the final call to awrite is an exact position, regardless
of the range. If you need only approximate alignment, make up digits.
You can also add numbers to this argument to offset the written file. For
instance, if the alignment point should be half a second into the aligned
file, subtract (0.5*F) from the argument.
)

require '~user/Sound/synth.ijs plot'

NB. y is the file's name or (name ; starting range),
NB.   with range as in the left argument of slice.
NB. The unaligned file should be stored with an _ before its extension;
NB.   awrite will write to the same file without an _.
NB. Optional x supplies the path of the file's directory.
align =: 3 : 0
  'PATH must exist (or be passed as x)' assert 0 = 4!:0 <'PATH'
  'name range' =. (2 {. ,&a:) boxopen y
  RANGES =: 0 2$0
  RANGE =: (0 3*F) (({.~ 2-#) , ]) range
  name =. ,&'.wav'^:('.' -.@e. ]) name
  WAVEFORM =: readwav_set ('.';'_.') rplc~ FILE=:PATH,name
  ashow ''
:
  PATH =: (,'/'-.{:) x
  align y
)

NB. Internal utility to update the range. Use setrange.
updaterange =: 3 : 'RANGE =: y [ RANGES =: RANGES , RANGE'

NB. (factor) zoom (location)
NB. Reduces the range by factor.
NB. If factor is omitted, the largest value up to 20 which leaves the
NB.   range as a power of ten is used.
NB. Location is the new start of the range, in units of the new range
NB.   length and beginning at the old start of the range.
zoom =: 3 : 0
  y zoom~ (% <.&.(10&^.)@:-:) {:RANGE
:
  setrange ((0,~[) + (y,1)*x<.@%~])/ RANGE
)
NB. Move right by y range units (1 if y is empty).
NB. Use negative y to move left.
shiftright =: 3 : 0
  ashow RANGE =: (+ ({.y,1)&*)/\. RANGE
)
NB. Reset the range entirely.
setrange =: ashow@:updaterange

NB. Undo the last zoom.
unzoom =: 3 : 0
  ashow 'RANGES RANGE' =: (}: ; {:) RANGES
)

NB. y is a number.
NB. Write the waveform, starting at the beginning of the range plus y.
awrite =: 3 : 0
  'file exists' assert -.fexist FILE
  (WAVEFORM shift~ y+{.RANGE) writewav FILE
)

NB. Show the range on the current waveform.
NB. Since align and zoom call ashow, you should not need to call it
NB. directly in normal use.
ashow =: 3 : 0
  plot RANGE slice WAVEFORM
)
