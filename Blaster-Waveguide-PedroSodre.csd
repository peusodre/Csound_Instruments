<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
kr = 44100
nchnls = 2
0dbfs = 1


//Single Shot
instr 1000
if p4= 0 then
ktrig metro 0.2
schedkwhen ktrig, 0, 10, 100, 0, 0.5, 0
elseif p4 = 1 then

ktrig metro 0.2
schedkwhen ktrig, 0, 10, 100, 0, 0.3, 1
schedkwhen ktrig, 0, 10, 100, 0.2, 0.3, 1
schedkwhen ktrig, 0, 10, 100, 0.4, 0.5, 1

endif
endin

//Single Shot Envelopes
instr 100
//Single Shot
if p4= 0 then
idur chnget "dur"

print idur
gkenvnoise expseg 0.5, 2.3,  0.001
gkenvnoise = gkenvnoise-0.001

gkenv linseg 0, 0.015, 1, 0.01, 0
gkenv2 expseg 1, idur+(0.3)+rnd31:i(0.05,0) , 0.1
gkenv3 expseg 1, idur+(0.3)+rnd31:i(0.05,0) , 0.1
gkenv4 linseg 1, idur+(0.4)+rnd31:i(0.05,0),1,0.05 , 0

//Row Shots
elseif p4 = 1 then
ienv2 = i(gkenv2)
print ienv2
ienv3 = i(gkenv3)
print ienv3

gkenvnoise expseg 0.5, 2.3, 0.001
gkenvnoise = gkenvnoise-0.001
gkenv linseg 0, 0.03, 0.7, 0.01, 0
ires active 100
print ires
if ires > 1 then

gkenv2 expseg ienv2, 0.01,1,idur+ 0.3, 0.1
gkenv3 expseg ienv3, 0.01,1, idur+0.3, 0.1
gkenv4 linseg 1, (0.4)+rnd31:i(0.05,0),1,0.05 , 0

elseif ires = 1 then

gkenv2 expseg 1, idur+0.3, 0.1
gkenv3 expseg 1, idur+0.3, 0.1
gkenv4 linseg 1, (0.4)+rnd31:i(0.05,0),1,0.05 , 0
endif 

endif

endin


instr 2
//Sets values
outvalue "size", 0.8
outvalue "fb", 0.06
outvalue "filter", 20000
outvalue "dur" ,0
outvalue "explosion", 0.3

//Generates pink noise
asig pinker 
asig dcblock2 asig
//Distorst PinkNoise
;asig distort1 asig, 10*chnget:k("dist"), 1,0,0
asig clip asig+ asig*10*chnget:k("dist"), 0, 1
//Filters Pink Noise
asig zdf_1pole asig, chnget:k("filter")
//Envelopes Pink noise
asig = (asig*0.0003)*gkenv


ksize  chnget "size" 
kfb chnget"fb"

;printk 0.0005, gkenv2

//wguide1
asig dcblock2 asig
ares wguide1 asig, (1000*ksize)*gkenv2, 20000, 0.90+kfb*0.5
//wguide2
ares dcblock2 ares
ares1 wguide1 ares, (800*ksize)*gkenv3, 20000, 0.90+kfb*0.6
//wguide3
ares1 dcblock2 ares1
ares2 wguide1 ares1, (600*ksize)*gkenv3, 20000, 0.90+kfb*0.7
//wguide4
ares2 dcblock2 ares2
ares3 wguide1 ares2, (500*ksize)*gkenv3, 20000, 0.905+kfb
ares3 dcblock2 ares3

;outs ares4*200, ares4*200
//Adding individual waveguides
aresA = (ares+ares1+ares2+ares3)/4
aresA dcblock2 aresA
//Combining added Individuals and last one
aout =  (aresA+ares3)*0.5
aout clip aout*200, 0, 3
//Blaster Output
outs (aout*gkenv4),  (aout*gkenv4)



// Explosion
anoise noise 0.0006*(1.6-chnget:k("size")), -0.99
//Enveloping 
anoise =anoise*gkenvnoise
;anoise distort1 anoise, 1000, 0.1,0,0
//Distorting
anoise clip anoise*100, 0, 1
//Low Passing
anoise zdf_1pole anoise*gkenvnoise*1*chnget:k("explosion"), 500
//Explosion output
;outs anoise, anoise





gaverb init 0
kverbsend chnget "verbsend"
gaverb =  gaverb+(anoise+ aout*gkenv4)*kverbsend

endin

instr verb
denorm gaverb

;aoutL, aoutR freeverb gaverb, gaverb, 0.8, 0.9
aoutL, aoutR reverbsc gaverb, gaverb, 0.85, 10000
;aout nreverb gaverb, 1, 0.3

clear gaverb
outs aoutR, aoutL
endin

</CsInstruments>
<CsScore>
i 2 0 1000
i "verb" 0 1000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>663</x>
 <y>398</y>
 <width>382</width>
 <height>318</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>Single</objectName>
  <x>30</x>
  <y>71</y>
  <width>100</width>
  <height>70</height>
  <uuid>{ff776a95-43a6-48ac-aafe-89292ddc4c8c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>pictevent</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Single</text>
  <image>/</image>
  <eventLine>i1000 0 1 0</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>130</x>
  <y>70</y>
  <width>100</width>
  <height>70</height>
  <uuid>{e8cc8009-ad03-45d5-9e1c-d2b41720dd7c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>pictevent</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Row</text>
  <image>/</image>
  <eventLine>i1000 0 1 1</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>size</objectName>
  <x>50</x>
  <y>164</y>
  <width>20</width>
  <height>100</height>
  <uuid>{c59f8ac6-3cc1-494e-b1b7-5ed41f3709a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.50000000</minimum>
  <maximum>1.50000000</maximum>
  <value>0.75000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>40</x>
  <y>144</y>
  <width>80</width>
  <height>25</height>
  <uuid>{a57b6415-1b8a-4014-9b71-0fc78d19c395}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>size</label>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>fb</objectName>
  <x>100</x>
  <y>164</y>
  <width>20</width>
  <height>100</height>
  <uuid>{4a695a37-9ae5-48b8-826b-af2602bc4a36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.08500000</maximum>
  <value>0.08415000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>dur</objectName>
  <x>0</x>
  <y>164</y>
  <width>20</width>
  <height>100</height>
  <uuid>{34aa9a49-a1a2-4e6a-9e08-ec99cdfc1ee6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-0.10000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.05800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>filter</objectName>
  <x>150</x>
  <y>164</y>
  <width>20</width>
  <height>100</height>
  <uuid>{55dced03-fce2-4fff-ba87-8bb9ec77585d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20000.00000000</maximum>
  <value>20000.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>dist</objectName>
  <x>200</x>
  <y>164</y>
  <width>20</width>
  <height>100</height>
  <uuid>{0072c3e1-6fa3-4bfc-8576-ab942c2b39cb}</uuid>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>90</x>
  <y>144</y>
  <width>80</width>
  <height>25</height>
  <uuid>{612b053f-d70b-4142-bb25-e2ede16080a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>decay T</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>140</x>
  <y>144</y>
  <width>80</width>
  <height>25</height>
  <uuid>{acfe662e-d1f2-49aa-9ffe-1b058e61276d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>intensity</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>190</x>
  <y>144</y>
  <width>80</width>
  <height>25</height>
  <uuid>{1f658677-2e50-425c-bb74-767b62dcf757}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>dist</label>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>verbsend</objectName>
  <x>243</x>
  <y>168</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3342497a-aacd-49bd-8fd5-acdcd897a613}</uuid>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>220</x>
  <y>144</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8b964d1f-31be-45b5-ae38-a482fff94d41}</uuid>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>0</x>
  <y>144</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c4cfef5e-b30a-41c8-8bbe-2c9aa05b4388}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>dur</label>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>explosion</objectName>
  <x>290</x>
  <y>173</y>
  <width>20</width>
  <height>100</height>
  <uuid>{5c1fe86b-2d4b-4ea9-810c-9b6b32aa15e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>0.30000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>270</x>
  <y>144</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b16e951e-c706-442a-9503-6515a0cf9edb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Explosion</label>
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
</bsbPresets>
