NB. Functions to read to and write from wave files.
NB. Does not work on many kinds of wave files, such as compressed data.

default =. ".@:(, '=:',":) ^: (0~:4!:0@<@[)
'FMT' default 1 16
'F'   default 44100

NB. The output from readwav (input to writewav) is either:
NB. - A list containing three boxes:
NB.     The sample rate (in Hz)
NB.     The audio format (see below)
NB.     PCM data, which has shape (n,l) for n-channels with l samples.
NB. - The last of these three, unboxed.
NB.
NB. For the latter case, the sample rate and audio format default to
NB. the constant values F and FMT (in the base locale).
NB. For a read, the second case is used whenever both of these values
NB. match their corresponding constants.

NB. The audio format consists of the type of audio and the bit depth.
NB. The type is one of:
NB.   1  unsigned integer
NB.   3  floating point
NB. Other audio formats may be supported in the future.

cocurrent 'pwav'

NB. ---------------------------------------------------------
NB. Columns are:
NB.   LEN:  Length of field (in bytes)
NB.   TYP:  Whether to leave as chars (c) or convert to an integer (i)
NB.   ERR:  Behavior on invalid value: fail (e), warn (w), or ignore (.)
NB.         (Fields with * depend on context)
NB.   NAME: Field name
NB.   DEF:  Expected field value, or blank
WAVE_HEADER =: ((;:@{. , >:@[<@}.])~ i.&'|');._2 ] 0 : 0
4 c e ChunkID        |'RIFF'
4 i w ChunkSize      |20 + Subchunk1Size + Subchunk2Size
4 c e Format         |'WAVE'
4 c e Subchunk1ID    |'fmt '
4 i * Subchunk1Size  |16
2 i . AudioFormat    |
2 i . NumChannels    |
4 i . SampleRate     |
4 i w ByteRate       |SampleRate * NumChannels * BitsPerSample%8
2 i w BlockAlign     |NumChannels * BitsPerSample%8
2 i . BitsPerSample  |
4 c * Subchunk2ID    |'data'
4 i . Subchunk2Size  |
)

'LEN TYP ERR NAME DEF' =: <"_1|: WAVE_HEADER
LEN =: ".@> LEN
TYP =: ; TYP
ERR =: ; ERR

NB. Topological order for field definitions
tsort =. (] , 1 i.~ ] (0"0@[)`[`]} (*./@:e.&> <))^:(>&#)^:_ & ($0)
ORDER =: tsort (+./@:E.)&>~&NAME(I.@:)(<@)"0 DEF
NB. Fill blank definitions with their own names.
DEF =: =&a:`(,:&NAME)} DEF

NB. Get integer from little-endian unsigned byte representation.
toint =: 256 #. a.i.|.

NB. ---------------------------------------------------------
NB. u is (AudioFormat,BitsPerSample).
NB. Return an invertible verb to convert bitstream to PCM data.
audioconvert =: 1 : 0
'AudioFormat BitsPerSample' =. u
if. 1 = AudioFormat do.
  b =. BitsPerSample%8
  'Bits per sample cannot exceed 64' assert b <: 8
  pp =. 2^ p =. 2 >.@^. b
  if. b=pp do.
    (-p) 3!:4 ]
  else.
    cp =. (-pp){.b#1
    (8*b-pp) 34 b. (-p) 3!:4 (#!.(0{a.)^:_1~ cp$~(pp%b)*$) :. (#~ cp$~$)
  end.
elseif. 3 = AudioFormat do.
  'Floating point only supports 32-bit' assert 32 = BitsPerSample
  _1&(3!:5)
elseif. do.
  0 assert~ 'Unsupported audio format: ',":AudioFormat
end.
)

NB. ---------------------------------------------------------
NB. x is (AudioFormat,BitsPerSample).
NB. Force y to fit in format x, emitting approprate warnings.
WARN_DITHER =: 0  NB. Whether to warn on non-integer signal
WARN_CLIP =: 1    NB. Whether to warn on out-of-bounds signal
forceformat =: 4 : 0
'f x' =. x
if. f ~: 1 do. y return. end.
y =. (-~2) + y  NB. Force integer or float
if. (4 ~: 3!:0 y) do.
  y1 =. <.y
  if. y&-:`0:@.(4 ~: 3!:0) y1 do.
    y =. y1
  else.
    smoutput^:WARN_DITHER 'Signal is non-integral; dithering...'
    y =. dither_base_ y
  end.
end.
if. x = 64 do. y return. end.
'max min' =. (<:,-) 2<.@^<:x
if. (>&max +.&:(+./@,) <&min) y do.
  smoutput^:WARN_CLIP 'Signal out of bounds; clipping...'
  y =. max <. min >. y
end.
y
)

NB. =========================================================
NB. readwav, writewav

NB. ---------------------------------------------------------
NB. y is the path to a wave file.
NB. readwav returns the PCM data from that file.
NB. The output has shape (n,l) for n-channel sound.
readwav =: 3 : 0
y =. 1!:1 boxopen y
'hdr y' =. (+/LEN) ({. ; }.) y

NB. Assign field values to field names.
(NAME) =. hdr =. ('i'=TYP) toint&.>@]^:["0 hdr (</.~ I.) LEN
NB. Handle extensible format
'Subchunk1Size is invalid' assert (0 2 24 e.~ se=.Subchunk1Size-16)
if. se>0 do.
  assert. se = 2 + toint 2{.Subchunk2ID
  'ext y' =. se ({. ; }.) y
  if. se>2 do.
    if. (AudioFormat = 65534) do. AudioFormat =. toint 4{.ext end.
    NB. hacky handling of fact chunk
    if. 'fact' -: 4{._8{.ext do. y =. (8+toint _4{.ext)}.y end.
  end.
end.
NB. Ignore remaining subchunks
s =. Subchunk2Size
while. -.'data'-:Subchunk2ID do.
  'Subchunk2ID s y' =. (4&{. ; toint@:((4+i.4)&{) ; 8&}.) s }. y
  Subchunk2Size =. Subchunk2Size + s+8
end.
NB. Check that fields match their definitions
e =. hdr ~: ".&.> DEF
msg =. 'Values for fields ' , ' are incorrect' ,~ ;:^:_1
alert =. ((msg@:#&NAME)`)(`(+./))(`:6) (@:(e *. ERR&e.))
(assert -.) alert 'e',(se<0)#'*'
smoutput@:('Warning: ',[)^:] alert 'w'

fmt =. AudioFormat,BitsPerSample
SampleRate;fmt; |: (-NumChannels) ]\ fmt audioconvert y
)

NB. ---------------------------------------------------------
NB. x is PCM data as output by readwav, and y is the file to write to.
writewav =: 4 : 0
'SampleRate fmt x' =. x
assert. 2 >: #$x
NumChannels =. #x =. ,:^:(2 - #@$) x
Subchunk2Size =. #x =. fmt audioconvert^:_1 fmt forceformat ,|:x
'AudioFormat BitsPerSample' =. fmt

for_i. ORDER do. (i{::NAME) =. ". i{::DEF end.

hdr =. ; LEN {.!.({.a.)&.> ('i'=TYP) toint^:_1&.>@]^:["0 ".&.> NAME
(hdr, x) 1!:2 boxopen y
)

NB. =========================================================
cocurrent 'base'
readwav  =: 3 : '_1&{::^:((F;FMT) -: 2&{.) readwav_pwav_ y'
writewav =: 4 : '((F;FMT;])^:(0=L.) x) writewav_pwav_ y'

NB. Read, setting F and FMT as a side effect.
readwav_set =: 3 : '(_1{::t) [ ''F FMT'' =: }:t =. readwav_pwav_ y'

NB. Read, resampling to fit current frequency
NB. Depends on a resample verb, such as that found in soxresample.ijs.
readwav_coerce =: 3 : '((F,~0&{::) resample _1&{::) readwav_pwav_ y'

NB. ---------------------------------------------------------
NB. Because sound scripts frequently need to access materials in the same
NB. directory, it is useful to have a verb giving the path of the current
NB. script. This functionality is annoyingly absent elsewhere, so it is
NB. provided here.
cur_script =: 3 :'(4!:3$0) {::~ 4!:4<''y'''
cur_dir =: ({.~ 1+i:&'/')@:cur_script
