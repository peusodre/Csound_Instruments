<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 10

ktrig chnget "trig" 

schedkwhen ktrig, 0.5, 1, 100, 0, 25

endin

instr 100

asig oscil 1, 440
outs asig, asig 

endin


instr 2

inote cpsmidi

kco chnget "cutoff" 
kdw chnget "drywet" 
kverbsend chnget "verbsend" 
kgeneralg chnget "generalg"
gasigL, gasigR ins


astr streson gasigL/10, inote, 0.9
afilt moogvcf astr, kco, 0.3

asig1 clip afilt, 0, 1
asig2 = gasigL/10

asig = asig1*kdw +asig2*(1-kdw)



kenv linsegr 0, 0.5, 1, 1000, 1, 5, 0
outs ((asig*kenv)/2)*kgeneralg, ((asig*kenv)/2)*kgeneralg
gastr= asig*kenv

gaverb1 = (((asig*kenv)/2)*kgeneralg)* kverbsend

endin

instr 3000
gkbowlgain chnget "bowlgain"
ktrigger chnget "trigger"
kbowlnote chnget "bowlnote" 
;ktrigger = 0; metro 1
schedkwhen ktrigger, 0.1, 60, 300, 0, 10, kbowlnote-61

endin 

instr 300; 2 modes excitator
;gktouch5 chnget "amp"

 kSig     downsamp        gastr*5 ; create k-rate version of audio signal
 kSq      =     kSig ^ 2        ; square it (negatives become positive)
 kRoot    =     kSq ^ 0.5       ; square root it (restore absolute values)
gkenvelope port kRoot, 0.02
gktouch5 = 1 
 
;kmanual = 1
kmanual = 1;chnget "manual"
gkmanual = kmanual

isize = p4
;ksize = 1;chnget "size"




kspeed =  15000;(kspeedo/50)*19000
kspeeda = (kspeed/60)



kjitp4  jitter 10, 5, 6
ijitp4  random 0, 10

;kjit2 = kjitu +10
kjitp5 jitter 2, 1, 5
;ijitp5   random-2, 1.5
;ijitp5  = p4

kjitp6 jitter 10, 2, 3
ijitp6  random 0, 10

kjitp7  jitter 10, 5, 6
ijitp7 random 0, 10

itransp random 1, 12

;icps cpsmidi
;inote1 notnum
;inote random 1, 12


ifreq11 init 1000
ifreq12 init 720
iamp    init ampdb(70)





irandomlenght random 0.3, 1

kamp   linseg    0, 1,0.1 , 0.1, 0.3, irandomlenght, 0
klfc   linseg    0, 6, 2000, .002, 0

irand random 1, 4
irandum1 random -400, 400
irandum2 random -400, 400

if irandum1> irandum2 then
irandum = irandum1
elseif irandum2>irandum1 then
irandum = irandum2
endif

ashocki  pinker
kampp port kamp, 1
;ashocki noise 1, -0.9999
ashock =  (ashocki*(kampp))*kspeeda

aexci = ashock
;aexc butterlp aexci*3, kspeed+irandum
aexc butterlp ((aexci)*0.005), kspeed;+irandum



aexc1  mode ashock,ifreq11,10000
aexc1 = aexc1*iamp
aexc2  mode ashock,ifreq12,10000
aexc2 = aexc2*iamp
aexc3  mode ashock,142.5,1000
aexc3 = (aexc3*iamp)*0.2



aexc limit aexc,0,3*iamp 

; mode resonators

kjit jitter 0.3, 2, 3
klfoA oscil 0.01,0.3+kjit
klfoB oscil 0.2,1.5+kjit

ktranspose = semitone(isize)
;gktranspose = 1.059463094359^ksize

ares1  mode aexc,(142.5*ktranspose)*kmanual,3000
ares2  mode aexc,(327.6*ktranspose)*kmanual,3000
ares3  mode aexc,(820.9*ktranspose)*kmanual,3000
ares4  mode aexc,(1307*ktranspose)*kmanual,3000
ares5  mode aexc,(1890*ktranspose)*kmanual,3000
ares6  mode aexc,(2518*ktranspose)*kmanual,3000
ares7  mode aexc,(3198*ktranspose)*kmanual,2500
ares8  mode aexc,(4408*ktranspose)*kmanual,2500
ares9  mode aexc,(5413*ktranspose)*kmanual,2000
ares10  mode aexc,(6126*ktranspose)*kmanual,2000
ares11  mode aexc,(7443*ktranspose)*kmanual,2000
ares12  mode aexc,(71.25*ktranspose)*kmanual,1000
;ares12 clip ares12, 0, 0.8
;ares12  mode aexc,12615*ktranspose,2000



aresA = ((ares1)/20)*(1+klfoA)
aresB = ((ares2+ares3+ares4)*2)*(0.5+klfoB)
aresC = ((ares5*0.6+ares6*0.6+ares7*0.3+ares8*0.3)/4)*(0.5+klfoB)
aresD = ((ares9*0.2+ares10*0.2+ares11*0.2)/4)*(0.5+klfoB)
ares = aresA + aresB + aresC + aresD+ares12;*0.5

;display aexc+ares,p3

kbalenv linseg, 1,4, 1, 1, 0
abal oscil 3000, 440


asigu = (ares)*0.0005

asig clip asigu,1,10000

;outs  asig*20,asig*20
  gasrc = asig*20


asig oscil 0.5, 440
;outs asig, asig

kenvclip linseg 1, p3-3, 1, 3, 0

outs ((gasrc*gktouch5)*gkbowlgain)*kenvclip,( (gasrc*gktouch5)*gkbowlgain)*kenvclip

gaverb init 0
kverbsend chnget "verbsend" 
gaverb2 = ((gaverb+gasrc*gkbowlgain)*kverbsend)*kenvclip


endin

opcode shimmer_reverb, aa, aakkkkkk
	al, ar, kpredelay, krvbfblvl, krvbco, kfblvl, kfbdeltime, kratio  xin

  ; pre-delay
  al = vdelay3(al, kpredelay, 1000)
  ar = vdelay3(ar, kpredelay, 1000)
 
  afbl init 0
  afbr init 0

  al = al + (afbl * kfblvl)
  ar = ar + (afbr * kfblvl)

  ; important, or signal bias grows rapidly
  al = dcblock2(al)
  ar = dcblock2(ar)

	; tanh for limiting
  al = tanh(al)
  ar = tanh(ar)

  al, ar reverbsc al, ar, krvbfblvl, krvbco 

  ifftsize  = 2048 
  ioverlap  = ifftsize / 4 
  iwinsize  = ifftsize 
  iwinshape = 1; von-Hann window 

  fftin     pvsanal al, ifftsize, ioverlap, iwinsize, iwinshape 
  fftscale  pvscale fftin, kratio, 0, 1
  atransL   pvsynth fftscale

  fftin2    pvsanal ar, ifftsize, ioverlap, iwinsize, iwinshape 
  fftscale2 pvscale fftin2, kratio, 0, 1
  atransR   pvsynth fftscale2

  ;; delay the feedback to let it build up over time
  afbl = vdelay3(atransL, kfbdeltime, 4000)
  afbr = vdelay3(atransR, kfbdeltime, 4000)

  xout al, ar
endop

instr 5
/*
kroomsize chnget "roomsize"

averbL, averbR reverbsc gaverb, gaverb, kroomsize, 12000

outs averbL, averbR
*/ 
al  init 0 
ar init 0
gaverb = gaverb1 + gaverb2
	al, ar shimmer_reverb gaverb, gaverb, 100, .95, 16000, 0.45, 100, 2
	
  outs al, ar
endin

</CsInstruments>
<CsScore>
f0 3600
i 5 0 3600
;i 300 0 3600
i  3000 0 300
;i 2 0 3000

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
