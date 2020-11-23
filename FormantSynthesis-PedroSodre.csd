<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1


turnon 100

instr 100

//Get Channel That Changes Mood
;gkMood chnget "gkMood" 
gkMood = 2

ktrig metro 1
ktrig dust 1, 0.8

//Mood 0, Moaning State
if gkMood < 1 then
//Note generator
//YVariable
gkY = 0
//randomOffSet1
krandoff1[] fillarray 0.1, 1
krandoff2[] fillarray 0.1, 1
//PortTime Value
gkporttime = 0.2

//Mood 1, Uh uhn state (negation)
elseif gkMood  >= 1 && gkMood  < 2 then
//Note generator
//ktrig dust 1, 0.4
//Yvariable 
gkY = 1
krandoff1[] fillarray 0.05, 1
krandoff2[] fillarray 0, 1
//PortTime Value
gkporttime = 0

//Mood 2, Yey state (Happy)
elseif gkMood  >=  2 && gkMood  < 3 then
//Note generator
//YVariable
gkY = 0
krandoff1[] fillarray 0.2, 1
krandoff2[] fillarray 0.1, 1
//PortTime Value
gkporttime = 0.2
elseif gkMood  >= 3 && gkMood  < 4 then
//Note generator
//YVariable
gkY = 0
krandoff1[] fillarray 0.2, 1
krandoff2[] fillarray 0.1, 1
//PortTime Value
gkporttime = 0.2
//Negation
elseif gkMood  >= 4 && gkMood  < 5 then
//Note generator
//YVariable
gkY = 0
krandoff1[] fillarray 0.1, 1
krandoff2[] fillarray 0.1, 1
//PortTime Value
gkporttime = 0.2
//Happy
elseif gkMood  >= 5 && gkMood  < 6 then
//Note generator
//YVariable
gkY = 0
krandoff1[] fillarray 0.1, 1
krandoff2[] fillarray 0.1, 1
//PortTime Value
gkporttime = 0.2
endif

//randomOffSet1
krandstroffset randh krandoff1[0], krandoff1[1]
//randomOffSet2
krandendoffset  randh krandoff2[0], krandoff2[1]


//Note Sched 
schedkwhen ktrig , 0, 1, 10, 0, 2-(randh:k(0.35, 0.8)+0.35) , krandstroffset, krandendoffset

endin



instr 10
//Envelope for Moaning
if gkMood < 1 then
//Gain Evenlope :p3 =2
gkGain  linseg 0, 0.2, 1, p3-0.8, 1, 0.3, 0
//Pitch Envelope p3 =2
;gkenv2  linseg   1+p4,    p3*0.2    , 0.6+p5,    p3*0.8    ,0.6+p5
gkenv2  linseg   1+(p4-0.1),    p3*0.5    , 0.75+p5,    p3*0.8    ,0.75+p5
//
gkDist = 3

//Envelope for No
elseif gkMood  >= 1 && gkMood  < 2  then
//Gain Evenlope : p3 =2 
                          //FIrst Event                                   //Second Event
gkGain  linseg 0,    0.1   ,1,     0.4   , 1,     0.05   , 0,     0.04   , 0.4,      0.1    ,0.4,      0.2      ,  0
//Gain Evenlope : p3 =2
                          //FIrst Event                                   //Second Event
                          
iNegpitchOffset = 0.3
gkenv2  linseg 0.55+p4,    0.5   , 0.6+p4,    0.05    , 0.4+p5,    0.08   , 0.4+p5
gkDist = 3

//Envelope for Yey(happy)
elseif gkMood  >= 2 && gkMood  < 3  then
//Gain Evenlope :p3 =2
gkGain  linseg 0, 0.1, 1, 0.2, 1, 0.1, 0
//Pitch Envelope p3 =2
gkenv2  linseg   0.5+p4,    0.4   , 0.9+p5
//
gkDist = 3

elseif gkMood  >= 3 && gkMood  < 4  then
//Gain Evenlope :p3 =2
gkGain  linseg 0, 0.1, 1, 1.5 , 1, 0.2, 0
//Pitch Envelope p3 =2
gkenv2  linseg   0.2+p4,    0.4   , 0.5+p5, 0.3, 0.5, 2, 0.45+p5
//
gkDist = 3

//Negation
elseif gkMood  >= 4 && gkMood  < 5  then
//Gain Evenlope :p3 =2
gkGain  linseg 0, 0.2, 1, p3-1.5, 1, 0.3, 0
//Pitch Envelope p3 =2
gkenv2  linseg   0.3+(p4+0.1),    p3*0.5    , 0.2+p5,    p3*0.8    ,0.2+p5
//
gkDist = 3
//Happy
elseif gkMood  >= 5 && gkMood  < 6  then
//Gain Evenlope :p3 =2
gkGain  linseg 0, 0.2, 1, p3-0.5, 1, 0.3, 0
//Pitch Envelope p3 =2
gkenv2  linseg   1+(p4+0.1),    p3*0.3,  1+(p4+0.1)   ,p3*0.1,  0.95+p5 , p3*0.2,   1+(p4+0.1)
//
gkDist = 3

endif 


//Bug if gkenv2 > 1 noise 
endin

turnon 1

gifn	ftgen	0,0, 257, 9, .5,1,270

instr 1
//For Unity: Getting head orientation
kX = chnget:k("X")/360
kX port kX, 0.05
kY = chnget:k("Y") /360
kY port kY, 0.05
kZ = chnget:k("Z") /360
kZ port kZ, 0.05

//Getting Jitter modulation
kjit1 = 0.5 + jitter:k( 0.5, 0.4, 0.5)
kjit2 = 0.5 + jitter:k( 0.5, 0.4, 0.5)
kjit3 = 0.5 + jitter:k( 0.5, 0.4, 0.5)
kjit10 =  1+ jitter:k( 1, 0.4, 0.5)

//Pitch Value To be Modulated by Pitch Envelope
kpitch = 690;*gkenv2


//**Add or not add port to the pitch 

//Mood 0 Moaning
if  gkMood < 1  then 
;kpitch port kpitch, 0.2
//Mood 1 No
elseif  gkMood >= 1 && gkMood  < 2 then
kpitch port kpitch, 0
elseif gkMood >= 2 && gkMood  < 3 then
elseif gkMood >= 3 && gkMood  < 4 then
elseif gkMood >= 4 && gkMood  < 5 then
elseif gkMood >= 5 && gkMood  < 6 then
endif


//Generating Exatation Source 1
asig1 vco2 0.3*0.1, kpitch*gkenv2      ;*kX
//Generating Exatation Source 2
asig2 vco2 0.3*0.1, (kpitch*0.9)     ;*kX

//Filtering signal 1
asig1 zdf_1pole asig1, 19000 * (kpitch/ 600)

//How to handle with oscilators in both Moods

if  gkMood < 1  then 
asig = asig1
elseif  gkMood >= 1 && gkMood  < 2 then
asig = asig1
elseif gkMood >= 2 && gkMood  < 3 then
asig = asig1
elseif gkMood >= 3 && gkMood  < 4 then
asig = asig1
elseif gkMood >= 4 && gkMood  < 5 then
asig = asig1
elseif gkMood >= 5 && gkMood  < 6 then
asig = asig1
endif


asig = asig *gkGain


kRes[] fillarray 60, 60, 30, 15

kBase1[] fillarray 600, 1000, 2520, 3340
kBase2[] fillarray 360, 1540, 2340, 3400
kBasea[] fillarray 360, 1540, 2340, 3400

	#define	KMODESPORT1(ARRN1)
	#
kBasea[$ARRN1] ntrpol  kBase2[$ARRN1], kBase1[$ARRN1], (1*kjit1)*gkY
	#
// Generate
	$KMODESPORT1(0)
	$KMODESPORT1(1)
	$KMODESPORT1(2)
	$KMODESPORT1(3)
	
kBase3[] fillarray 290, 680, 2320, 3150
kBase4[] fillarray 360, 2240, 2880, 3460

kBaseb[] fillarray 360, 1540, 2340, 3400

	#define	KMODESPORT2(ARRN2)
	#
kBaseb[$ARRN2] ntrpol  kBase3[$ARRN2], kBase4[$ARRN2], 1*gkY
	#
// Generate
	$KMODESPORT2(0)
	$KMODESPORT2(1)
	$KMODESPORT2(2)
	$KMODESPORT2(3)
	
kBase[] fillarray 360, 1540, 2340, 3400
	
		#define	KMODESPORT3(ARRN3)
	#
kBase[$ARRN3] ntrpol  kBasea[$ARRN3], kBaseb[$ARRN3], 1;*kZ
	#
// Generate
	$KMODESPORT3(0)
	$KMODESPORT3(1)
	$KMODESPORT3(2)
	$KMODESPORT3(3)
	
	
	

asug0 mode asig, kBase[0], kRes[0]
asug1 mode asig*0.5, kBase[1], kRes[1]
asug2 mode 0.2*asig, kBase[2], kRes[2]
asug3 mode 0.2*asig, kBase[3], kRes[3]

asug = (asug0 + asug1 + asug2 + asug3)/70

asug clip asug,0 , 0.8
outs asug*2.5, asug *2.5


gaverb = butterlp:a( asug*0.2, 13000)

endin 



</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>329</x>
 <y>257</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Y</objectName>
  <x>154</x>
  <y>73</y>
  <width>20</width>
  <height>100</height>
  <uuid>{4fbe1c9d-17dc-4264-a342-22a9c0b88c66}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>360.00000000</maximum>
  <value>64.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>X</objectName>
  <x>86</x>
  <y>84</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3453515a-2eba-406b-b9ea-9d3f52dff7c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>360.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Z</objectName>
  <x>207</x>
  <y>95</y>
  <width>20</width>
  <height>100</height>
  <uuid>{5381849f-419f-4b9d-b2cf-fff128e70976}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>360.00000000</maximum>
  <value>118.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>gkMood</objectName>
  <x>267</x>
  <y>93</y>
  <width>20</width>
  <height>100</height>
  <uuid>{c932c3f7-76dc-4a9b-aa98-1fe1cf2e35f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>3.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>261</x>
  <y>53</y>
  <width>80</width>
  <height>25</height>
  <uuid>{dd080788-290c-4a80-8b01-da0b69e38673}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Moods
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
