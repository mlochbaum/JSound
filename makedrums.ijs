require '~user/Sound/synth.ijs'

NB. Drum sequencer

NB. Global variables
NB. getdrum: x is drum name and y is list of characters for hits. Return
NB. a list of hits, with each boxed.
NB.
NB. BEAT: starting samples/beat (optional if pattern starts with :BEAT:)
NB. SWING: modifier for length of each beat
NB. END: Number of additional beats at the end
NB.
NB. SPEED: 1 if fast but inaccurate processing should be used

p =. [: ;"_1@:|: [: ];._2 <;._2@:,&LF
parsepattern =: p f.  :  ((':'(,,[)":@[) ,"1`]@.(0=#@]) $:@])

NB. Control characters that aren't treated as hits (. is nothing)
C =: '.><][-+'
getshift =: (%8 _8 3 _3 _) {~ '><]['&i.
getvol =: (1.2^_1 1 0) {~ '-+'&i.

NB. output is (list of lengths);(list of symbols);(average lengths)
getbeaty =: 3 : 0
y =. (':'([,,~)":BEAT)&,^:(':'~:{.) y -. ' '
<@;"1 |: _2 (#@] $&.> ".@[ ([;];(+/%#)@[) ])&>/\ }:^:(2|#) ':'cut y
)
getlength =: ([:<.[:+/0{::getbeaty@:{.)`0:@.(0=#)
b =. (+/%#)@:".@:(}.~1+i:&':')@:({.~i:&':')@]`[@.(':'-.@e.]) {:
getlastbeat =: (".bind'BEAT' $: ]) : (b f.)

NB. pink noise with no normalization
pink1 =: ({. (rand@:(2&^) + [: +/\ [: ,@,.&:>/ [: (>.&2 {. 2 -~/\ rand)&.> 2^i.@-)@:(>:@:>.@:(2&^.)))@:#
gettrack =: 4 : 0
'b y a' =. getbeaty y
b =. b + (* 1 -~ ($&SWING + (0.1*PINK) * 2-~/\pink1@:$&0@:>:)@:#) a
m =. y -.@e. C
len =. (m,0) +/;.1 b,END*{:b
len =. 0.5<.@:+ (+/b{.~m i. 1) , len + (-_1&|.) m +/;._1 b * getshift y
vol =. }: m */;._1&(1&,) getvol y
d =. (<2 0$0) , vol *&.> x getdrum m#y
if. (-.SPEED) *. is_overlap x do.
  f =. 1000
  len ((overlap  f bwhp2^:2&.>) add [: concat  f bwlp2^:2@:({."1)&.>) d
else.
  concat len {."1&.> d
end.
)

overlap =: 4 : 0
out =. ''
tail =. 2 0$0
for_i. i.#y do.
  'ix iy' =. x ;&(i&{) y
  out =. out , <tail +&:(ix&{."1) iy
  tail =. ix }."1 tail
  if. ({:$iy)>ix do. tail =. tail add ix }."1 iy end.
end.
concat out
)

APPLY_REVERB =: reverb
NB. To mix channels for reverb tail
APPLY_REVERB_MIX =: 4 : 0
  if. #x do.
    'ir1 ir2' =. (I 100) (fadefront ; (-.@[*#@[{.])"1) x
    (ir2&reverb add ir1 reverb -:@:+/) y
  else.
    y
  end.
)

maketrack =: 4 : 0
'drums IRs' =. 2 {. a: ,~ boxopen x
track =. 2 0 $ 0
for_is. (</. i.@#) IRs do.
  is =. >is
  temp =. 2 0 $ 0
  for_i. is do.
    temp =. temp add drums gettrack&(i&{) y
  end.
  if. (*#x) *. -.SPEED do.
    temp =. (({.is){::IRs) APPLY_REVERB temp
  end.
  track =. track add temp
end.
track
)
