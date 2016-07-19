NB. Based on JUpdate:
NB. https://github.com/mlochbaum/JScripts/blob/master/Misc/jupdate.ijs
require '~user/Scripts/Misc/jupdate.ijs'

require '~user/Sound/synth.ijs'

declaredo 'do'
declareread 'readwav'
declarewrite 'writewav'

NB. cur_script fails if called by jupdate, since it is not called from
NB. a script. In this case, (4!:3$0) returns _1. Use FILE.
cur_script =: 3 :'(4!:3$0) {::~`([:>".bind''FILE'')@.(_1=]) 4!:4<''y'''
