<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
instr 1

apulse oscil 1, 440
gkpulse = k(abs(apulse))

endin

//event creator
instr 1000

//to give density contour
;kdensity linseg 0, 120, 2, 30, 0.5
kdensity chnget "density" 

kdust dust 1, kdensity


///trying to get a kdust && metro trigger rythm generator going
/*
if kdust >1 && ktrig > 1 then
ktrigger = 1
else 
ktrigger = 0
endif
*/ 


//notes
kran randomh 0, 6, 1
//duration
kran2 randomh 2, 5, 1
//if >1.5 then there is a bend
kran3 randomh 0, 2, 1
//amplitude
kran4 randomh 0.5, 1, 1

//Subdivision random rythimic generator
ktrig metro 8
kran5 randomh 0, 2, 8
if kran5 > 1.6 then
kon = 1
else 
kon = 0
endif

kgroove = ktrig *kon
karray chnget "array"
//notes array
;printk  0, karray

knotematerial chnget "notematerial"

knote12[] fillarray -24, 22, -24, -14, -12, 2, 3, 12, 24, 12, 24, 32

/* 
knotes1 randomh -24, -14, 0.1
knotes2 randomh -12, 0, 0.1
knotes3 randomh -8, 2, 0.1
knotes4 randomh 3, 12, 0.1
knotes5 randomh 24, 12, 0.1
knotes6 randomh 24, 32, 0.1
*/

knotes1[] fillarray -17, -20, -24, -12, -17, -14
knotes2[] fillarray -5, -8, -12, 0, -5, -2
knotes3[] fillarray -1, -5, -8, 4, -1, 2
knotes4[] fillarray 12, 7, 3, 7, 7, 7
;knotes5[] fillarray 24, 12, 16, 19, 22, 7
knotes5[] fillarray 24, 24, 24, 24, 22, 24
knotes6[] fillarray 32, 32, 32, 32, 30, 32

if knotematerial<=0.5 then
	if karray <2 then
	knotes randomh knote12[0], knote12[1], 10
	elseif karray >2 && karray <4  then
	knotes randomh knote12[2], knote12[3], 10
	elseif karray >4 && karray <6 then
	knotes randomh knote12[4], knote12[5], 10
	elseif karray >6 && karray <8 then
	knotes randomh knote12[6], knote12[7], 10
	elseif karray >8 && karray <10 then
	knotes randomh knote12[8], knote12[9], 10
;	elseif karray >7.8 then
;	knotes randomh knote12[10], knote12[11],  10

endif
kdust1 = kdust 
kdust2 = 0

elseif knotematerial>0.5 then
	if karray <2 then
	knotesa[] = knotes1
	elseif karray >2 && karray <4 then
	knotesa[] = knotes2
	elseif karray >4 && karray <6 then
	knotesa[] = knotes3
	elseif karray >6 && karray <8 then
	knotesa[] = knotes4
	elseif karray >8 then
	knotesa[] = knotes5
;	elseif karray >7.8 then
;	knotesa[] = knotes6


endif
	kdust1 = 0
	kdust2 = kdust
endif

;printk 0.1, knotes
schedkwhen kdust1, 0.1, 30, 100, 0, 3, knotes, kran2, kran3, kran4
schedkwhen kdust2, 0.1, 30, 100, 0, 3, knotesa[kran], kran2, kran3, kran4

;event "i", 100, 20, 10, -24, 100, 0, 1

endin

instr 100

idur = p5
istep = p4
kvol = p7
print istep
if p6>1.5 then 
kbend = 1
else
kbend = 0
endif

kmode chnget "mode" 

//additive harmonic instance creator
schedule 2, 0, idur, 1689*semitone(istep), 0.9, -10, kbend, kvol,kmode
schedule 2, 0, idur, 1828*semitone(istep), 0.9, -47.9, kbend, kvol,kmode
schedule 2, 0, idur, 2061*semitone(istep), 0.9, -49, kbend, kvol,kmode
schedule  2, 0, idur, 3389*semitone(istep), 0.9, -44, kbend, kvol,kmode
schedule  2, 0, idur, 3857*semitone(istep), 0.9, -61.1, kbend, kvol,kmode
schedule  2, 0, idur, 5319*semitone(istep),0.9, -65.4, kbend, kvol,kmode
schedule  2, 0, idur, 7908*semitone(istep), 0.9, -65, kbend, kvol,kmode

endin 
instr 2
kverbsend chnget "verbsend" 

kbendon init 0
if p7>0 then
kbendon linseg 0, 2, 0, 0.1, 1, 5, 1
else 
kbendon = kbendon
endif

knote = p4
if kbendon > 0 then
knote linseg p4, 1, p4/p5
else
knote = knote
endif 

kjit1modrate chnget "jit1modrate" 
kwhistattack chnget "whistattack"
//Random pitch modulation
kwhistlep jitter 0.05, 7+kjit1modrate, 9+kjit1modrate
kwhistleenv linseg 0, i(kwhistattack), 1, p3-2, 1, 1.5, 0


//Random amplitude modulation
ipoint1 random 1, 1.2
ipoint2 random 0.7, 1

kbirdp1 linseg ipoint1, 0.1, ipoint2,0.1,ipoint1*0.9, 0.1,1, p3-0.2, ipoint1
kbirdp2 linseg ipoint1,  0.1, ipoint2

ibirdtype random 0, 2

if ibirdtype > 1 then
kbirdp = kbirdp1
elseif ibirdtype < 1 then
kbirdp = kbirdp2
endif
kbirdenv linseg 0, 0.05, 1,0.4, 1, 0.1, 0


//Whistle/Bird mode selector
;kmode =p9
kmode chnget "mode" 
;kmode port kmode, 0.2
kjit ntrpol kwhistlep+1, kbirdp*(kwhistlep+1), kmode
kenv ntrpol kwhistleenv, kbirdenv, kmode
klowpassg ntrpol 0.01, 0.005, kmode

;printk 0, kjit 
/*
if kmode <1 then
kjit  linseg kbirdp, 1, kwhistlep, 1000, kwhistlep
kenv linseg kbirdenv, 1, kwhistlenv, 1000, kwhistlenv
elseif kmode >= 1 then
kjit = kbirdp
kenv linseg kwhistlenv, 1, kbirdenv, 1000, kbirdenv
kenv linseg kwhistlep, 1, kbirdp, 1000, kbirdp
endif
*/


//Random amplitude modulation
kjit2 jitter 0.05, 7.5, 9


//####OSCILATORS#####//

//Additive oscilator
asig oscil ampdb(p6)*(kjit2+1), knote*(kjit)
//Noise 
anoise pinker 
//Noise w/ bandpass
anoisef butterbp  anoise, knote*(kjit), 50
//Noise w/ lowpass
anoiself butterlp anoise, 5000

kfilterednoiseg chnget "filterednoise" 

//Mixing signals
aout =  asig*0.08+((anoisef*0.09)*(kjit2+1))+((anoiself*klowpassg)*kfilterednoiseg)*(kjit2+1)
ipan random 0, 1
aoutL, aoutR pan2  aout, ipan
outs (aoutL*kenv)*p8, (aoutR*kenv)*p8
gaout init 0
iverbdin limit p8, 0, 0.7
gaout = ((aout*kenv+gaout)*iverbdin)*kverbsend

endin

instr reverb
kroomsize chnget "roomsize"
kcutoff chnget "verbcutoff"
kcutoff init 6630
averbL, averbR reverbsc gaout, gaout, kroomsize, kcutoff
outs averbL*1.4, averbR*1.4
clear gaout 
 endin
 
</CsInstruments>
<CsScore>
;i 1 2 5 
;i 100 0 10 0
;i 100 0.5 10 5
i 1000 0 1000
i "reverb" 0 1000
;i100 60 10 -24 15 0 1
;i100 100 10 -24 15 0 1
e



</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>468</x>
 <y>226</y>
 <width>853</width>
 <height>525</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>array</objectName>
  <x>140</x>
  <y>132</y>
  <width>20</width>
  <height>100</height>
  <uuid>{af2010a5-c331-4a9e-827e-3d1e9684cee7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>4.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>130</x>
  <y>274</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e93dcd11-0eb3-471f-bee2-6ccbf9f0ad37}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Array</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>density</objectName>
  <x>210</x>
  <y>132</y>
  <width>20</width>
  <height>100</height>
  <uuid>{b174d799-3441-4ccf-bf37-39c613de38d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>6.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>200</x>
  <y>274</y>
  <width>80</width>
  <height>25</height>
  <uuid>{75f85184-0303-47cc-958f-c7bd6a02c39f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Density
</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>array</objectName>
  <x>109</x>
  <y>240</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ecde2f1c-5d84-4671-9834-c034978e9e24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4.800</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>density</objectName>
  <x>200</x>
  <y>240</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ef968d33-c891-4545-a4eb-0cc57c4f4a12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4.640</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>roomsize</objectName>
  <x>325</x>
  <y>132</y>
  <width>20</width>
  <height>100</height>
  <uuid>{1462b037-ff7a-4f60-9e28-f13c86b44968}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.90000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>roomsize</objectName>
  <x>300</x>
  <y>240</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ea7879b1-7a41-4969-972b-f442624da013}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.900</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>mode</objectName>
  <x>220</x>
  <y>310</y>
  <width>20</width>
  <height>100</height>
  <uuid>{50eb0d42-c25a-49f0-b864-9857c9f576a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>340</x>
  <y>270</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e95f7aca-d31d-4cc6-9145-14ec3f2ae9c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>roomsize</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>verbsend</objectName>
  <x>460</x>
  <y>132</y>
  <width>20</width>
  <height>100</height>
  <uuid>{35318d56-7d80-4d8f-a7a8-2eaf65769e60}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>verbsend</objectName>
  <x>440</x>
  <y>240</y>
  <width>80</width>
  <height>25</height>
  <uuid>{9abb927f-240e-49fd-995c-34e22edc0ee1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.040</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>475</x>
  <y>270</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b7d8791a-6c99-457f-a754-14fc2dd701b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>verbsend</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>jit1modrate</objectName>
  <x>140</x>
  <y>310</y>
  <width>20</width>
  <height>99</height>
  <uuid>{4c01919d-02d0-440d-b9b7-6808f31bc949}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-5.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider14</objectName>
  <x>143</x>
  <y>800</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3748f8dc-1733-4d0b-8223-ad75f50eb085}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jit1modrate</objectName>
  <x>100</x>
  <y>457</y>
  <width>80</width>
  <height>25</height>
  <uuid>{dbeba765-96ab-4fcb-9e40-6cbfba3ad088}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.152</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>120</x>
  <y>410</y>
  <width>80</width>
  <height>25</height>
  <uuid>{9d14f2c7-6ac5-437b-9e83-c6da0382b0dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>kpitchmodrate offset</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>220</x>
  <y>410</y>
  <width>80</width>
  <height>25</height>
  <uuid>{12993284-31a5-42ee-94d1-e62ebb6cbabf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>mode</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>mode</objectName>
  <x>218</x>
  <y>430</y>
  <width>80</width>
  <height>25</height>
  <uuid>{730ab1d3-28ac-4f34-8865-4ee0c65b8525}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1.000</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>verbcutoff</objectName>
  <x>340</x>
  <y>310</y>
  <width>20</width>
  <height>100</height>
  <uuid>{70e86f5b-ade7-4aa1-b713-f6447e38a555}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>13000.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>verbcutoff</objectName>
  <x>320</x>
  <y>430</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c126d235-dfe4-442c-848c-a5b5bafece95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>13000.000</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>339</x>
  <y>402</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2ecdaf02-3989-4832-ac29-4e4424ec64e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>verbdamp</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>filterednoise</objectName>
  <x>445</x>
  <y>300</y>
  <width>20</width>
  <height>100</height>
  <uuid>{2f312d4b-36b7-4a94-a51b-531ed182637c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>441</x>
  <y>416</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8ef013d8-f4b2-46b2-b3a2-6eab680fdcb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>filterednoise
</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>filterednoise</objectName>
  <x>451</x>
  <y>447</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5496af8d-c164-4d3e-a77d-ba86619083a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1.000</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>notematerial</objectName>
  <x>553</x>
  <y>300</y>
  <width>20</width>
  <height>100</height>
  <uuid>{11b121a3-f1a0-4f8a-8ef3-2db0519874cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>notematerial</objectName>
  <x>552</x>
  <y>800</y>
  <width>20</width>
  <height>100</height>
  <uuid>{052397a4-511c-414b-a892-4c23b266b9e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>552</x>
  <y>414</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5cb5af01-8949-4456-8985-a2d305fe6177}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>notematerial
</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>notematerial</objectName>
  <x>579</x>
  <y>455</y>
  <width>80</width>
  <height>25</height>
  <uuid>{985689ee-962d-43ee-98ba-562c82c448fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1.000</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kwhistattack</objectName>
  <x>582</x>
  <y>213</y>
  <width>2</width>
  <height>2</height>
  <uuid>{6659eb4c-0049-49cb-9bfd-19b093ce941f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>whistattack</objectName>
  <x>567</x>
  <y>148</y>
  <width>20</width>
  <height>100</height>
  <uuid>{0574d657-92a8-49d8-a497-4c6c30a6bf43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.05000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>whistattack</objectName>
  <x>567</x>
  <y>257</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2b3c9f28-37fa-487c-97b6-872af92142a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.050</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>whistattack</objectName>
  <x>590</x>
  <y>800</y>
  <width>20</width>
  <height>40</height>
  <uuid>{80c6ddb2-0148-4570-82f7-f22f4db4e1d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>592</x>
  <y>284</y>
  <width>80</width>
  <height>25</height>
  <uuid>{497c7d18-4fa2-4580-be1c-15fe04681ce2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>whistattack</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="nice" number="1" >
<value id="{af2010a5-c331-4a9e-827e-3d1e9684cee7}" mode="1" >0.00000000</value>
<value id="{b174d799-3441-4ccf-bf37-39c613de38d3}" mode="1" >1.36000001</value>
<value id="{ecde2f1c-5d84-4671-9834-c034978e9e24}" mode="1" >0.00000000</value>
<value id="{ecde2f1c-5d84-4671-9834-c034978e9e24}" mode="4" >0.000</value>
<value id="{ef968d33-c891-4545-a4eb-0cc57c4f4a12}" mode="1" >1.36000001</value>
<value id="{ef968d33-c891-4545-a4eb-0cc57c4f4a12}" mode="4" >1.360</value>
<value id="{1462b037-ff7a-4f60-9e28-f13c86b44968}" mode="1" >0.89999998</value>
<value id="{ea7879b1-7a41-4969-972b-f442624da013}" mode="1" >0.89999998</value>
<value id="{ea7879b1-7a41-4969-972b-f442624da013}" mode="4" >0.900</value>
<value id="{50eb0d42-c25a-49f0-b864-9857c9f576a3}" mode="1" >1.00000000</value>
<value id="{35318d56-7d80-4d8f-a7a8-2eaf65769e60}" mode="1" >1.00000000</value>
<value id="{9abb927f-240e-49fd-995c-34e22edc0ee1}" mode="1" >1.00000000</value>
<value id="{9abb927f-240e-49fd-995c-34e22edc0ee1}" mode="4" >1.000</value>
<value id="{4c01919d-02d0-440d-b9b7-6808f31bc949}" mode="1" >-0.25252524</value>
<value id="{3748f8dc-1733-4d0b-8223-ad75f50eb085}" mode="1" >0.58999997</value>
<value id="{dbeba765-96ab-4fcb-9e40-6cbfba3ad088}" mode="1" >-0.25299999</value>
<value id="{dbeba765-96ab-4fcb-9e40-6cbfba3ad088}" mode="4" >-0.253</value>
<value id="{730ab1d3-28ac-4f34-8865-4ee0c65b8525}" mode="1" >1.00000000</value>
<value id="{730ab1d3-28ac-4f34-8865-4ee0c65b8525}" mode="4" >1.000</value>
<value id="{70e86f5b-ade7-4aa1-b713-f6447e38a555}" mode="1" >6110.52978516</value>
<value id="{c126d235-dfe4-442c-848c-a5b5bafece95}" mode="1" >6110.52978516</value>
<value id="{c126d235-dfe4-442c-848c-a5b5bafece95}" mode="4" >6110.530</value>
<value id="{2f312d4b-36b7-4a94-a51b-531ed182637c}" mode="1" >1.00000000</value>
<value id="{5496af8d-c164-4d3e-a77d-ba86619083a4}" mode="1" >1.00000000</value>
<value id="{5496af8d-c164-4d3e-a77d-ba86619083a4}" mode="4" >1.000</value>
</preset>
</bsbPresets>
