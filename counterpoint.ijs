notes=: }:i:12
scale=: (,~ -&12) 0 2 4 5 7 9 11
minor=:(#~ 3&+ e. ]) scale
major=:(#~ 4&+ e. ]) scale
allowed=: (i:8)-._8 _6 6
ending=: +&1 0^:(4 = -/)"1 ]0 2 {"1 ]3 ]\ _13,scale,12

   melody=:4 :0
mel=., last=.y
length=.x
end=.ending{~ scale i. y
while. x> #mel do.
  c=.choices _2 {. mel

  if. 2=x-$mel do. c=. (#~ e.&end) c end.
  if. 1=x-$mel do. c=. (#~ =&y) c end.
  w=.(% +/) ([: -~/ 1 18 % 1 12+*:)"0 c-last
  if. #c do. mel=.mel, last=.c {~ (+/\ I. ?@0:) w
  else. last=.{: mel=.}:mel end.
end.
)

   choices=:3 :0
last=.{:y
mel=.y

a=.last+allowed
choices=.(#~ e.&a *. e.&scale) (i:12)
if. 4 < |s=.-/ mel do.
  choices=. {. (/: |@-&last) (#~ s =&* -&last) choices
  (#~ e.&scale) choices , last + ((5=|s) # (-*s) * 3 4 7) , ((7=|s) # (-*s)*5)
  return. end.
if. s=0 do. choices=.choices-.last end.
if. _7 5 e.~ last do. choices=./:~ choices, _2, (5=last)#10 end.

choices
)

   n=.3 :0
s=.$y
short=.0 1
long=.2 3 5
pos=.short, (long #~ -. 2 |#y)
prob=.(% +/) % 1+pos
l=. pos{~ (+/\ I. ?@0:) prob
y , 1, 0 #~ l
)

   melody=:4 :0
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