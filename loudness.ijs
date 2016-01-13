NB. Conversions between sound pressure level (SPL, in decibels) and
NB. perceptual loudness (in phon) at a given frequency.

NB. At frequency f Hz, if a tone at s dB has a loudness of l phon, then:
NB. s -: f SPL l
NB. l -: f loudness s

NB. Calculations are taken from the current definition of the phon
NB. (ISO 226:2003).

'NAMES CHART' =: (;:@>@{. ,&< [:|:".@>@}.) a:-.~ <;._2 ]0 : 0
f       a_f     L_U     T_f
20      0.532   31.6    78.5
25      0.506   27.2    68.7
31.5    0.480   23.0    59.5

40      0.455   19.1    51.1
50      0.432   15.9    44.0
63      0.409   13.0    37.5

80      0.387   10.3    31.5
100     0.367   8.1     26.5
125     0.349   6.2     22.1

160     0.330   4.5     17.9
200     0.315   3.1     14.4
250     0.301   2.0     11.4

315     0.288   1.1     8.6
400     0.276   0.4     6.2
500     0.267   0.0     4.4

630     0.259   0.3     3.0
800     0.253   0.5     2.2
1000    0.250   0.0     2.4

1250    0.246   2.7     3.5
1600    0.244   4.1     1.7
2000    0.243   1.0     1.3

2500    0.243   1.7     4.2
3150    0.243   2.5     6.0
4000    0.242   1.2     5.4

5000    0.242   2.1     1.5
6300    0.245   7.1     6.0
8000    0.254   11.2    12.6

10000   0.271   10.7    13.9
12500   0.301   3.1     12.3
)
getv =: (CHART {~ NAMES i. boxopen@[)  {~  ({.CHART) (<:@#@[ <. I.) ]

NB. Find the sound pressure level (in dB) of a tone with
NB. loudness x (phon) and frequency y (Hz)
A_f =: (4.47e_3 * 1.14-~10^0.025*[) + ('a_f'&getv^~0.4*10^9-~10%~'T_f'&getv+'L_U'&getv)@]
SPL =: 94 + ('L_U'getv]) -~ (10%'a_f'getv]) * 10^.A_f

NB. Find the loudness (in phon) of a tone with
NB. sound pressure level x (dB) and frequency y (Hz)
B_f =: 0.005076 + ('a_f'getv]) -/@:^~ 0.4*10^9-~10%~('L_U'getv])+(,'T_f'&getv)
loudness =: 94 + 40 * 10^.B_f"0
