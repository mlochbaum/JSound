NB. C and J implementations of (mostly) IIR filters.

NB. Assumes 44.1 kHz.
F =: 44100

NB. ---------------------------------------------------------
NB. C filter binding
pointer_to_name =: 1 { [: memr (0 4,JINT) ,~ symget@boxopen@,
vptrn =: (+ [: memr ,&0 1 4)@:pointer_to_name
LIBFILTER =: jpath '~user/Sound/libsynth.so'

NB. Generalized filtering with C
NB. y is the signal to filter
NB. x is (x coefficients ; y coefficients).
filter =: 4 : 0 "1
y =. (-~2.1) + y
assert. 8 = 3!:0 y  NB. Input must be floating point
'xc yc' =. x
(LIBFILTER, ' filter > n',6 rep' x') cd ,(#@".,vptrn)@> ;:'y xc yc'
y
)

NB. Compute the frequency response from coefficients
response =: (; 1,-)&|.&>/@[  p.&>(|@:%/@:)"_ 0  (j.2p1)^@:*(%Fv)@]

NB. ---------------------------------------------------------
NB. Coefficients for specific filters

makefilter =: 1 :'u 2 :''(u n)&filter'''

lpcutoff =: [: (*Fv) :. (%Fv) 2p1%~<:&.%
hpcutoff =: [: (*Fv) :. (%Fv) 2p1%~<:@%

NB. two-pole low-pass filter coefficient generator
NB. y is the corrected cutoff frequency
NB. x is the p,g list
getlpcoeffs2 =: 3 ({. ;&|. }.) [: (,1-+/)@:((1 2 1 , 2*1-~%@{:) * ({: % 1++/)) (* (,*:)@:(3 o.o.))

NB. m is (filter type);(number of passes);(0 if lowpass, 1 if highpass)
NB. filter type is one of 'bw', 'cd', or 'bessel'.
getcoeffs =: 1 : 0
't n ifhp' =. m
assert. 3 > t =. ('bw';'cd';'bessel') i. <t
C  =.  (4%:<:) ` (%:@<:@%:) ` (3 %:@* 0.5 -~ %:@-&0.75) @. t   n%:2
X  =.  t {:: (%:2 1) , 2 1 ,: 3 3
if. ifhp do.
  (1 _1 1; 1 _1) *&.> X getlpcoeffs2 0.5 - (C%Fv)*]
else.
  X getlpcoeffs2 (% C*Fv)
end.
)

(".@:({.,'=:(',}.,') makefilter'"_)~ i.&' ');._2 ]0 : 0
lowpass    [: (;-.) lpcutoff^:_1
highpass   [: (;~ (,~-)) hpcutoff^:_1
bwlp2      ('bw';1;0) getcoeffs
bwhp2      ('bw';1;1) getcoeffs
cdlp2      ('cd';1;0) getcoeffs
cdhp2      ('cd';1;1) getcoeffs
bslp2  ('bessel';1;0) getcoeffs
bshp2  ('bessel';1;1) getcoeffs
)

NB. Doesn't work...
NB. getcoeffs =: [: (;&|. }.)/@:(% (<1 0)&{) (2*F) p.~ (] , (2 0 _2*|.) ,: 1 _1 1&*)"1

NB. ---------------------------------------------------------
NB. Peaking filter
NB. y is (gain in dB, frequency, Q)
peakf =: (3 : 0) makefilter
'g f Q' =. y
k =. 3 o. 1p1*f%F
ab =. 1 0 2 3 0 4 { k p.~ _2 0 2 , (1,,&1)"0 ,(,.-) Q %~ 10^0>.(,~-)20%~g
2 (}. ;&|. -@:{.) ({. %~ }.) ab
)

NB. ---------------------------------------------------------
NB. Second-order shelving filter
NB. y is (type, gain in dB, frequency, Q)
NB. where type is 1 for bass and _1 for treble shelf
shelf =: (3 : 0) makefilter
't g f Q' =. ,&(%:2)^:(3=#) y
k =. 3 o. 1p1*f%F
v1 =. 10 ^ t * 0>.(,~-)40%~g
ab =. ,/ 1 0 2&{"_1 (*:1<.v1) %~ (k*v1) p.~/ _2 0 2 , (1,.,.&1) (,-) Q
2 (}. ;&|. -@:{.) ({. %~ }.) ab
)
NB. Shortcuts for low- and high-shelf
lshelf =: (1 :' 1,u') shelf
hshelf =: (1 :'_1,u') shelf

NB. ---------------------------------------------------------
NB. Notch filter
NB. y is (frequency, width) in Hz.
NB. Filter with no gain outside of the notch due to A.G. Constantinides
NB. The width is for 3dB attenuation.
notch =: (3 : 0) makefilter
'w0 dw' =. 2p1 * y%F
c =. _2*2 o. w0
1 (+ %~&.> (1,c,1) (;-) c,~-) 3 o. -:dw
)

NB. ---------------------------------------------------------
NB. all-pass filter
NB. y is a complex number, which should have magnitude less than 1.
allpass =: (;-@|.@}.)@:(1:,-@+:@(9&o.),*:@|) makefilter

NB. ---------------------------------------------------------
NB. Butterworth filters with resonance
NB. Argument is (frequency, Q)
NB. Identical to bwlp2 and bwhp2 when Q=%%:2
resfilt =. (1 : 0)~/ makefilter
((+:@[%~1 o.]) (>:@[ %&.>~ u ; <:@[,2*]) 2 o. ]) 2p1*]%Fv
)
lpq_f =: (2  1 2 %~ 1-]) resfilt
hpq_f =: (2 _1 2 %~ 1+]) resfilt
bpq_f =: (1 0 _1*[)      resfilt

NB. ---------------------------------------------------------
NB. high-pass filter with variable frequency
highpass_f =: 4 : 0"1
y =. (-~2.1) + y
x =. (-~2.1) + x
assert. x *.&(8 = 3!:0) y
assert. x (= <:)&# y
x =. hpcutoff^:_1 x
(LIBFILTER, ' highpass_f > n',3 rep' x') cd (#y), ,vptrn@> ;:'y x'
y
)
