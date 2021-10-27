NB. u is a list of filters which have gain (in dB) as the first parameter.
NB. Turn into a verb that varies x according to three parameters y:
NB. (starting value, correlated variation, individual variation).
vardrums =: 1 : 0
GAIN =. ".@:({.~i.&' ')@> u NB. Initial gain values from table
rcoef =. {. + }. (+&>/@:(*&.>) ({.;}.)) ([:-/2&,?@$0:) bind (>:#u)
var =. [: 128!:2&.>/(>@:) (":@[,(}.~i.&' ')@])&.>&u@[ , <@]
(var~ GAIN * rcoef)~ f.
)

NB. progressive index: like i. but uses up entries on the left
progindex =: #@[ ({. i.&(,.(i.~(]-{)/:@/:)) }.) [ i. ,
mergelists =: 4 : 0
m =. (#y) = i =. y progindex x
/:&>/ (y;i.#y) (, m&#)&.> x;>./\m}i,:_1
)
