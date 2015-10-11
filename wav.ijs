NB. Functions to read and write from wave files.

WAVE_HEADER =: ;:;._2 ] 0 : 0
4 c ChunkID
4 i ChunkSize
4 c Format
4 c Subchunk1ID
4 i Subchunk1Size
2 i AudioFormat
2 i NumChannels
4 i SampleRate
4 i ByteRate
2 i BlockAlign
2 i BitsPerSample
4 c Subchunk2ID
4 i Subchunk2Size
)

NB. y is the path to a wave file.
NB. readwav returns the PCM data (which is just a list of numbers)
NB. from that file. The output has shape (n,l) for n-channel sound.
readwav =: 3 : 0
toint =. 256 #. a.i.|.

y =. 1!:1 boxopen y
typ=.{.@>typ [ len=.".@>len [ 'len typ name' =. <"_1|: WAVE_HEADER
(name) =. hdr =. ('i'=typ) toint&.>@]^:["0 (y{.~+/len) (</.~ I.) len
y =. (+/len) }. y

assert. 'RIFFWAVEfmt data' -: ; 0 2 3 11{hdr
assert. 1 3 e.~ AudioFormat  NB. Cannot handle compressed formats
assert. 16 = Subchunk1Size
NB. assert. 1=#~. (ChunkSize-Subchunk1Size+20) , #y  NB. Subchunk2Size
assert. ByteRate = SampleRate * NumChannels * BitsPerSample%8
assert. BlockAlign = NumChannels * BitsPerSample%8

NB. |: (-NumChannels) ]\ (-BitsPerSample%8) toint\ y
if. 1 = AudioFormat do.
  y =. _1 (3!:4) , (-BitsPerSample%8) (_2&({.!.({.a.)))\ y NB. Subchunk2Size {. y
elseif. 3 = AudioFormat do.
  assert. 32 = BitsPerSample
  y =. _1 (3!:5) y
end.
|: (-NumChannels) ]\ y
)

NB. x is PCM data as output by readwav, and y is the file to write to.
NB. Perform the write.
NB. Note that writewav parallels the structure of readwav, but backwards.
NB. This is more easily seen in some places (1!:1 versus 1!:2 ; the
NB. calls to toint) than others.
writewav =: 4 : 0
fromint =. (256 #. a.i.|.)^:_1

NumChannels =. #x
x =. 1 (3!:4) ,|: clip x

'ChunkID Format Subchunk1ID Subchunk2ID' =. _4 ]\ 'RIFFWAVEfmt data'
AudioFormat =. 1
ChunkSize =. 20 + (Subchunk1Size=.16) + Subchunk2Size =. #x
BitsPerSample =. 16
SampleRate =. 44100
ByteRate =. SampleRate * NumChannels * BitsPerSample%8
BlockAlign =. NumChannels * BitsPerSample%8

typ=.{.@>typ [ len=.".@>len [ 'len typ name' =. <"_1|: WAVE_HEADER
hdr =. ; len {.!.({.a.)&.> ('i'=typ) fromint&.>@]^:["0 ".&.> name

(hdr, x) 1!:2 boxopen y
)
