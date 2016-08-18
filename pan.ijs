require '~user/Sound/synth.ijs'

0 : 0
Stereo panning

The goal of stereo panning is to make sounds appear to come from
different directions. A well-panned sound for music will have the
following three features:

1. The high frequencies (and preferably only the high frequencies) are
   louder on the near side.
2. The low frequencies begin slightly earlier on the near side.
3. It still sounds good when the channels are combined.

Requirements 1 and 2 come from physics: these are properties acquired by
sounds as they travel around a human head, and they are the features the
brain uses to identify their source. Requirement 3 comes from the fact
that music is sometimes played in mono and should still have acceptable
quality when mixed this way.

Requirement 1 causes no problems and is simple to implement by moving part
of the far channel to the near side (that is, subtracting a fraction of
that channel, possibly with a high-pass filter, from the far side and
adding it to the near side). Requirements 2 and 3, however, are in direct
conflict. The obvious solution to 2 is to delay the far channel; however
doing so will cause comb filtering when channels are re-combined.

Typically the answer is to drop one of the requirements. Acceptable stereo
localization can still be obtained without any delays, thus dropping
requirement 2. And panning with a delay, or more generally applying a
head-related transfer function (HRTF), yields the best possible
localization at the expense of a weak mono mix.

However, it is possible to compromise, obtaining excellent (but not
perfect) stereo and good mono. The key is to realize that only the lower
frequencies must be delayed, a feat which can be performed with all-pass
filters. For delays under 1/2000 of a second we can combine a forwards
filter with a backwards filter to delay a wide range of frequencies and then
undelay those over 2000Hz, since those frequencies are not used to detect
delay. This leaves a signal largely without artifacts--the only issue is
a small amount of attenuation at frequencies near the cutoff when the two
channels are combined.
)

NB. Pan with all-pass filters. Arguments are the same as pan
NB. Delays the input by slightly more than 100 samples.
panap =: 4 : 0
ir =. 2#,:100=i.500
if. x ~: 0.5 do.
  far =. 0.5<x
  off =. | <:+:x
  ir =. (+ [: (,:-) off * [:5000 lowpass {:) ir
  'a b' =. get_panap_coeff (off*25),0.89 1000
  ir =. far |. (,:  [: b allpass&.|. a allpass)/ ir
end.
ir reverb y
)
NB. Empirically determined good coefficients for panap
NB. y is a single parameter giving the delay for low frequencies.
shift_coeff =: 3 : 0
  f =. 732 + 79000 % 1.6 ^~ 10 + y
  rs =. 1.097 _2.054 2.16 p. 1e4 %~ f
  y,rs,f
)

NB. Data for shift_coeff
0 : 0
Values of rs which make the third derivative of the phase transfer at
zero equal to zero. (rs * 1000) is given.
    frequency of max phase difference
      2000 1750 1500 1250 1100 1000
s  5   782  804  827  852  868  878
h 10   816  829  845  864  876  885
i 15   849  857  866  878  887  894
f 20   875  879  885  893  899  904
t 25   895  897  901  906  910  913

"Good" shift, frequency, and rs values.
Frequency is determined from the formula in shift_coeff.
In shift_coeff, rs is modelled as quadratic w.r.t frequency.
~0    2716  0.698
 0.1  2685  0.701
 1    2436  0.725
 2.5  2121  0.759
 5    1769  0.802
10    1387  0.853
15    1190  0.882
20    1074  0.900
25    1000  0.913
30     948  0.924
)

(0 : 0)
NB. Tools for working with all-pass filters
NB. Coefficients for an all-pass filter with complex parameter y
apc =: (; -@|.@}.)@:(1: , -@+:@(9&o.) , *:@|)
NB. Compute phase from filter coefficients
phase =: (; 1,-)&|.&>/@[  p.&>(%/@:)"_ 0  (-j.2p1)^@:*(%Fv)@]
)

NB. =========================================================
NB. Argument is (number of samples to shift),(magnitude),(stop frequency).
NB. Magnitude should be a real number strictly between 0 and 1,
NB. and controls how pointy the end result is in phase space.
NB. Returns two all-pass filter inputs matching the specifications.
NB.
NB. The polynomials here should probably be treated as black magic, but
NB. a derivation from the constraints is included below anyway.
get_panap_coeff =: 3 : 0
'n rr f' =. y
z2=.*: z =. ^j.2p1*f%F
r =. *:rr
pm =. +//.@:(*/)
pa =. +/@:,:

S =. (pm~  ;  (3{.(r-1)*(8%n)) pa pm&((3-r),2)) (1+r),_2

H1 =. z2 (+ ;&(,&(_2*z))~ 1+*) r
H2 =. S pa&.>/@:(pm&.>)"1 H1 ,.~ ((z2*r) - z*z+2)  ;&(,&(_2*z))  (r - 1+2*z)
H2 =. ({.~ 1 + 0&(~:i:1:))&.> H2

NB. Should be equal to H1*H2.
RHS =. (pa&.>/,{:) (,(z+1)*(1-r)) ; (r,1)-z

NB. Solve.
re =. (#~ (=+) *. rr>:|) _1{::p. -&>/ pm&.>/"1 H1 ,. H2 ,. |.RHS
('No solutions!') assert 1<:#re
re =. >./ 9 o. re
getz =. ] j. -&.*:
a =. rr getz re=.{.re

Sv =. S p.&>(%/@:) re
b =. (%: r + Sv*r-1) getz (re + Sv*re+1)

a,b
)


NB. ---------------------------------------------------------
(0 : 0) NB. Derivation
NB. Transfer function for an all-pass filter: argument is z,
NB. and rs and re are (*:@|) and (9&o.) of the complex parameter
H   = (1 + (rs**:) - 2*re&*) % (*: + rs - 2*re&*)
NB. Derivative with respect to z
Hp  = (2 * (re-~rs&*) - H*(1-re)) % (*:+rs-2*re&*)
    = (2 * (* rs-H) - re*1-~H) % (*:+rs-2*re&*)

NB. Definition of the phase transfer function T
(^j.T ω) = (H ^j.ω)
NB. Derivative in terms of H and its derivative Hp
j.(^j.T(ω))*Tp(ω) = Hp(^j.ω)*j.^j.ω
Tp(ω) = Hp(^j.ω) * ^j.ω-T(ω)
      = Hp(s) * s % H(s)
      = (2*s * (s*rs-H) - re*H-1) % (1 + (rs**:s) - 2*re*s)

NB. Simplified at 1 and _1 (0 and maximum frequency)
H(1)  = 1
T(0)  = 0
Tp(0) = (2*rs-1) % (1+rs-2*re)

H(_1) = 1
T(π)  = 0
Tp(π) = (2*rs-1) % (1+rs+2*re)


NB. For a delay
H(z) = z^-n
T(ω) = -n*ω
Tp(ω) = -n

NB. Constraints
NB. We refer to the forward and backwards filters with
NB. postfixes of 1 and 2.
Tp1(0)  =  Tp2(0) - n
Tp1(π)  ≃  Tp2(π)
Tp1(f)  =  Tp2(f)

NB. In a symmetric notation: [a,b] = (a1%b1) - (a2%b2)
NB. where an and bn are the values for the nth filter.
NB. z2 = *:z
(-n%2)= [rs-1 , 1+rs-2*re]
0    =  [rs-1 , 1+rs+2*re]
0    =  [((z*rs-H) - re*H-1) , (1 + (z2*rs) - (2*z*re))]

NB. Useful identity
NB. Define (reC = re2 - re1) and (rsC = rs2 - rs1)
rs1*re2 - rs2*re1  =  (rs1*re1 + rs1*reC) - (rs1*re1 + rsC*re1)
                   =  rs1*reC - rsC*re1

NB. Second constraint, where [12] indicates the value with 1 and 2 swapped
((rs1-1) * 1+rs2+2*re2) = [12]
(rs1*(1+2*re2) - (rs2+2*re2)) = [12]
((rs1*1+re2) + re1) = [12]
0  =  (rs2-rs1) + (re2-re1) + (re1*rs2 - re2*rs1)
   =  (rs2-rs1) + (re1*(rs2-1) - re2*(rs1-1))
   =  rsC + reC + (re1*rsC - reC*rs1)
   =  (rsC * 1+re1) + (reC * 1-rs1)
(reC % re1+1) = (rsC % rs1-1)

NB. Let S be defined by (reC =: S*re1+1) and (rsC =: S*rs1-1)
rs1*re2 - rs2*re1  =  rs1*reC - rsC*re1
                   =  S * (rs1*re1+1) - (re1*rs1-1)
                   =  S * rs1 + re1

NB. Cross-multiply first constraint and subtract second
(rs2-rs1) = (n%8)*(1+rs1-2*re1)*(1+rs2-2*re2)
(S*rs1-1) = (n%8)*(1+rs1-2*re1)*((1+rs1-2*re1) + S*(rs1-1)-2*(re1+1))
(S * (rs1-1)*(8%n)) = (*: 1+rs1-2*re1) - S*(1+rs1-2*re1)*(rs1-~3+2*re1)
S  =  (*: 1+rs1-2*re1) % (((rs1-1)*(8%n)) + (1+rs1-2*re1)*(rs1-~3+2*re1))


NB. Third constraint
NB. Value of Tp, dropping factor of 2*z
((z*rs1-H1) + re1*H1-1) * (1 + (z2*rs2) - (2*z*re2))  =  [12]
(re1 -~ z*rs1 + H1*re1-z) * (1 + (z2*rs2) - (2*z*re2))  =  [12]
((z*rs1) - (re1 + z2*rs1*re2)) + (H1*re1-z)*(1 + (z2*rs2) - (2*z*re2))  =  [12]
((z*rs1) - (re1 + z2*rs1*re2)) + (H1*H2*re1-z)*(rs2 + z2 - 2*z*re2)  =  [12]
((z*rs1) + (z2*rs2*re1) - re1) + H1*H2*((rs2*re1) + (z*rs1) - z2*re1)  =  [12]
((z*rsC) + (z2*(rs1*re2 - rs2*re1)) - reC) + H1*H2*((rs1*re2 - rs2*re1) + (z*rsC) - z2*reC)  =  0
NB. Divide by S
((z*rs1-1) + (z2*(rs1+re1)) - re1+1) + H1*H2*((rs1+re1) + (z*rs1-1) - z2*re1+1)  =  0
((rs1*z2+z) + (re1*z2-1) - z+1) + H1*H2*((rs1*z+1) + (re1*1-z2) - z2+z)  =  0
NB. Divide by z+1
((rs1*z) + (re1*z-1) - 1) + H1*H2*(rs1 + (re1*1-z) - z)  =  0
H1*H2  =  ((rs1*z) + (re1*z-1) - 1) % ((-rs1) + (re1*z-1) + z)
       =  1  +  (z+1)*(1-rs1) % (rs1 + (re1*1-z) - z)

NB. Value of H2 in terms of re1 and rs1
NB. With these and the previous definition, we obtain a 4th-order
NB. polynomial in re1 and rs1.
a = 2*z*re1,  r = rs1
H1 = ((1 + (z2*r) - a)                             )  %  ((z2 + r - a)                        )
H2 = ((1 + (z2*r) - a) + S*(((z2*r) - a) - (z*z+2)))  %  ((z2 + r - a) + S*((r - a) - (1+2*z)))
)
