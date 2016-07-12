require '~user/Sound/wav.ijs math/fftw ~user/Sound/filter.ijs'

NB. Assume 16-bit, 44.1 kHz audio
'min max' =: _32768 32767
F =: 44100
Fv =: ".bind'F'

NB. ---------------------------------------------------------
NB. General manipulation
NB. Each verb works on multi-channel signals.

NB. Add two signals x and y or a list of (boxed) signals y
NB. Extend to the length of the longest signal.
add =: +&.>/(>@:)@:({."1&.>~ [:>./{:@$@>)@:(] : ;)
NB. Like add, but concatenate instead.
concat =: ([: |: [: ; |:&.>) : (,"1)
NB. Like (|.), but the end of the signal does not wrap around.
shift =: }."1 ` ((0$~-@[),"1]) @. (0>[)
NB. x is (location,length). Obtain that part of the signal.
slice =: ((+(**i.))/@[ { ])"1
NB. u is a verb. Apply u to the slice of y given by x.
onslice =: 1 : 0
:
i =. (+(**i.))/ x
(u i {"1 y) i}"1 y
)
NB. Repeat signal y x times.
rep =: ((*#) $ ])"1

NB. Clip signal y to the maximum possible range.
clip =: max <. min >. ]
NB. x is an integer giving "sharpness". Perform a soft clip.
softclip =: 3&$: : (4 :'(% [:%:^:x [:>: ^&(2<.@^x))&.:(%&(>:max)) y')
NB. Convert a real signal to integers without introducing artifacts.
MIN =. <:- MAX =. 33 b.~ _1
forceint =. (((MAX*-.@]) + [: <. MIN>.*) <:&MAX)
dither =: forceint@:(+ 0.5 + 0 -/@:(?@$)~ (2,$)) f.

NB. Utilities to play a signal (using Linux)
play0=: [: empty [: 2!:1 'aplay 1.wav' [ writewav&'1.wav'
play =: [: play0 ,"1&(3e4#0)


NB. =========================================================
NB. Synthesis

NB. ---------------------------------------------------------
NB. Music theory utilities
NB. Transpose a frequency y by x semitones.
trans=: (* 2 ^ %&12)~
NB. Get the frequency of note y.
note =: 220 trans~ (1 _1 0{~'#b'i.{.@}.) + 'a bc d ef g' i. {.

NB. ---------------------------------------------------------
NB. Signal generators
NB. Each generator takes a list of frequencies and generates a signal
NB. of the same length.
NB. Utilities...
ce =: <:@:+:
hz =: <.@%~ Fv
th =: +/\@:% Fv
rand  =: [: ce ?@$&0

NB. Sawtooth wave //////
saw =: [: ce (-<.)@:th
NB. Triangle wave /\/\/\
triangle =: ce@|@:saw
NB. Exponential wave (complex output)
exp =: [: ^ 0j2p1 * th
NB. Sine wave
sine=: 1 o. 2p1 * th
NB. Pulse wave with duty cycle x
pulse =: ce@:< (-<.)@:th
NB. Square wave
square=: 0.5&pulse
NB. White noise
white =: rand@:#
NB. Brown noise
brown =: +/\@:white
NB. Pink noise
NB. pink  =: ({. (2 -~ %&4 %~ [: (+2&#)&:>/ [: ?@$&0&.> 2^i.@-)@:(>:@>.@(2&^.)))@:#
pink  =: [: (% >./@:|) ({. (rand@:(2&^) + [: +/\ [: ,@,.&:>/ [: (>.&2 {. 2 -~/\ rand)&.> 2^i.@-)@:(>:@>.@(2&^.)))@:#

NB. ---------------------------------------------------------
NB. Envelopes
NB. "Normalized" version of i.
I =: |%~i.
NB. Attack-decay-sustain-release envelope
ADSR =: I@{. , (2&{ + (0 3 4-~/@:{]) {. 2&{ (-.@[ * I@:-@]) 1&{) , (2&{ * [:I@:- 3&{)


NB. =========================================================
NB. More sound manipulation

NB. ---------------------------------------------------------
NB. Convolution with the Fourier transform
conv =: 9 o. (#@]{.[) *&.fftw ]
NB. Fast convolution with the overlap-save method.
NB. x should be shorter than y.
conv1 =: 4 : 0"1
  'N L' =. ((],-~) [: >.&.(2&^.) 4&*) <:#x
  y1 =. ({.~ N + <.&.(%&L)@:#) (0#~<:#x),y
  (#y) {. , (L,:N) ((-L) {. 9 o. (fftw N{.x)&*&.fftw);._3 y1
)
NB. Using the overlap-add method
conv2 =: 4 : 0"1
  'N L' =. ((],-~) [: >.&.(2&^.) 3&*) <:#x
  (#y) {. ; +&.>//. (-L) ((-L) <@(L&{.)\ 9 o. [: (fftw N{.x)&*&.fftw N&{.)\ y
)
NB. x is a reverb IR.
NB. Lengthens y by x to avoid cutting off the final reverb, then convolves.
reverb =: ([ conv1 (,0"0)~)"1^:(*@#@[)

NB. ---------------------------------------------------------
NB. x is between 0 and 1. Pan with shift.
pan =: (_25<.@*(,-.)@[) shift"_1 ((=i.2)-(**/0&>.)@:(,-)@<:@+:@[) +/ .* ]

NB. ---------------------------------------------------------
NB. Fading
NB. x is a coefficient list.
NB. fadefront multiplies the first ({:$x) elements of y by these coefficients.
NB. fadeback does the same for the end of y.
fade =. 2 :'((}.~u) v ]*({.~u))"1~'
fadefront=:   # fade (,~)
fadeback =: -@# fade ,

NB. u is the overlap amount. Fade x into y, linearly.
crossfade =: (2 :0 ({.;}.))("1)
((-u)v[) (2 1 ;@:C. ,&{: (,<) ((,:~-.)I u)+/@:*,:&>&{.) (u v])
)
