NB. Bindings for sox's resample library
NB. Used by readwav_coerce in wav.ijs

LIBRESAMPLE =: '/usr/lib/libsoxr.so'

NB. Generalized filtering with C
NB. y is pcm data
NB. x is (current frequency, new frequency)
NB. Resample y according to x. The returned data is floating point.
resample =: 4 : 0 "1
y =. (-~2.1) + y
assert. 8 = 3!:0 y  NB. Input must be floating point
if. =/x do. return. end.
'f0 f1' =. x
l1 =. >. (f1%f0) * l0 =. #y NB. Input and output lengths
lo =. ,0 NB. Pointer to actual output length
o =. l1 # -~2.1
NB. This cd call worked on the first try, which kind of scares me.
lib =. LIBRESAMPLE,' soxr_oneshot > n d d i *f x x *f x *x x x x'
assert 0 = lib cd f0;f1;1; y;l0;0; o;l1;lo; 0;0;0
o
)
