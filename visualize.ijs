require '~user/Sound/synth.ijs plot viewmat'

NB. Given a frequency, show the nearest (12-note chromatic) note to it.
NOTES =: (((,#&'#')&.> -.@:~:) 'AABCCDDEFFGG')
shownote =: 12 ((4+<.@%)~ (,":)&.>~ NOTES {~ |) 0.5 <.@+ 12 * 2 ^. %&440

NB. ---------------------------------------------------------
NB. FFT visualizations
FFT_OPTS =: 'xrange 20 20000; xlog 1; ylog 1'

NB. Convert the fft into a plottable form
fftplotarg =: [: (;&:(}."1)~ -:@Fv*I@{:@$) ([:,~^:_1|@:fftw)"1
NB. Plot the Fourier transform or transforms of y on a log-log scale.
showfft =: FFT_OPTS plot fftplotarg
NB. The same, but average by u 
showfft_avg =: 1 : 0
FFT_OPTS plot (-u) (+/%#)\"1&.> fftplotarg
)

NB. Show the transfer function of filter u
showfilter =: 1 : 'showfft u F{.1'

NB. ---------------------------------------------------------
NB. With viewmat
stft =: 512&$: : ((2 |@:(,~^:_1)@fftw@,\ -@[ ]\ ])"0 1)
stftview =: [: (,~|.)~/@:(0 2 1&|:)^:(2<#@$) stft
showstft =: viewmat@:stftview
showlogstft =: viewmat@:(0>.^.)@:stftview
