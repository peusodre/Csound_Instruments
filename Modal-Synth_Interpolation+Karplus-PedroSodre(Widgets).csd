<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

opcode	 MODESYNTH , a, akkkkkkkkkkkkkkkkkkkkkkk
 ain,kamp, kbasfrq, kmode1, kgain1, kq1,  kmode2, kgain2,kq2, kmode3,kgain3, kq3, kgain4, kmode4,  kq4, kmode5,kgain5,  kq5, kmode6, kgain6,kq6,  kmode7,kgain7,kq7 	xin
	amix	init	0
	
#define	MODE_PARTIAL(FRQ'KQ'KG)
	#
	kgain = ampdb($KG*0.6)
	kfrq	=	kbasfrq*$FRQ
	if sr/kfrq>=$M_PI then
	 asig	mode	ain*kgain, kfrq, $KQ
	 amix	=	amix + asig
	 amix = amix*kamp
	endif
	#
	
	$MODE_PARTIAL(kmode1'kq1'kgain1)
	$MODE_PARTIAL(kmode2'kq2'kgain2)
	$MODE_PARTIAL(kmode3'kq3'kgain3)
	$MODE_PARTIAL(kmode4'kq4'kgain4)
	$MODE_PARTIAL(kmode5'kq5'kgain5)
	$MODE_PARTIAL(kmode6'kq6'kgain6)
	$MODE_PARTIAL(kmode7'kq7'kgain7)
		xout	amix/7
		clear	amix
endop

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
  ioverlap  = ifftsize *0.25
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

instr Trigger
 gaimpulse mpulse 1,  80
 outvalue  "Freq", cpsmidinn(p4)

endin



instr 100

kDensity chnget "Density"
kBaseFreq chnget "Freq"
kModeInterp chnget "Automatic"
kObj1 chnget "Object1"
kObj2 chnget "Object2"

kvalues = kDensity+kBaseFreq+kModeInterp + kObj1+kObj2

if changed:k(kvalues) = 1 then 

else 
outvalue  "Automatic", 1
outvalue  "AutoDyn", 1
outvalue  "Density", 3
outvalue  "Freq", 185
outvalue "Control", 0
outvalue "Object1", 3
outvalue "Object2", 1
outvalue "Dynamics", 0.5
;outvalue "HighDens", 0
;outvalue "Periodic", 0
outvalue "CongaRes",0
		outvalue "exctType", 0
		outvalue "stringExctDur", 0.014
		outvalue  "StringFreq" , 440
		outvalue "stringGain"	, 0.5
		outvalue  "StringWet", 0.2
		outvalue "StringBowed", 0

endif

endin





// Event Generator
instr 10
	kchangBoth changed2 chnget:k("BothOff")
		if (kchangBoth= 1 && chnget:k("BothOff")= 0) then
		outvalue "HighDens", chnget:k("BothOff")*-1
		outvalue "Periodic", chnget:k("BothOff")*-1
	else 
	endif
	
		kchangBoth changed2 chnget:k("BothOn")
		if (kchangBoth= 1 && chnget:k("BothOn")= 1) then
		kmoveup linseg 0, 0.1, 10
		chnset 	  kmoveup,"HighDens"
		chnset 	 kmoveup,"Periodic"
		outvalue "HighDens", chnget:k("BothOn")
		outvalue "Periodic", chnget:k("BothOn")


	else 
	endif
	


	
	kFreqBase chnget "Freq" 
	if (kFreqBase < 30) then
	kFreqBase = 30
	else 
	kFreqBase = kFreqBase
	endif
	
	if (kFreqBase < 100) then
	kFrqProportion = (kFreqBase-30) *0,014285714285714
	else 
	kFrqProportion = 1
	endif

	if (chnget:k("HighDens") = 1) then
	kHighDens = 200 
	kHighDensMin = -4
	kFreqRef ntrpol 20, 5,  kFrqProportion
	krandFix randh 1, 0.1
	kHighDensDur ntrpol kFreqRef-(kFreqRef*0.25) , kFreqRef-(kFreqRef*(0.80-krandFix )), chnget:k("HighDens")*0.2
	
	kHighDensMetro = 2.5
	else 
	kHighDens = 0
	kHighDensMin = 0
	kHighDensDur = 0
	kHighDensMetro= 1
	endif

	if (chnget:k("Automatic" ) = 1) then
	kJitInterp jitter 1.2, 1, 1.5
	;kJitInterp randh 1.2, 1
	kJitInterp port kJitInterp, 0.02
	kModeInterp = kJitInterp  //  A - ModeInterp Jitter Curve 		 
	else
	kModeInterp chnget "Control"  //  B - ModeInterp With Widgets 
	endif
	
	kModeInterp limit kModeInterp, 0, 1 //The instrument clicks if kModeInterp  = 0 
	outvalue	"Control", kModeInterp
	
		if (chnget:k("Periodic" ) = 1) then
	kres metro chnget:k("Density") *kHighDensMetro
	else
	kres dust 2, chnget:k("Density")*(kHighDensMetro*0.5)
	endif

	
		// Atributes Random Value to The Exatation Source Filter
	if (chnget:k("AutoDyn" ) = 1) then
	kJitDynami jitter 0.5, 0.1, 0.15
	kJitDynamic = kJitDynami+0.5
	outvalue	"Dynamics", kJitDynamic
	else
	kJitDynamic chnget "Dynamics"
	endif

	
	
	
	kObject1 chnget "Object1"
	kObject2 chnget "Object2"
	

	

	
	kVerbSend chnget "VerbSend" 
	
	kProportionDur ntrpol 20, 5,  kFrqProportion
	kProportionMinTim ntrpol 0.4, 0.1,  kFrqProportion
	kProportionDurConga ntrpol 0, 10, chnget:k("CongaRes") 
	gkShimerRatio chnget "VerbRatio"
	kExct chnget "exctType"
	kStringExtDur chnget "stringExctDur"
	kStringFreq chnget "StringFreq" 
	kstringGain chnget "stringGain"
	kStringWet chnget "StringWet"
	kStringBowed chnget "StringBowed"
	schedkwhen kres, kProportionMinTim+kHighDensMin , 20+kProportionDurConga+kHighDens , 1, 0, kProportionDur-kHighDensDur , kJitDynamic, kModeInterp, kObject1, kObject2, kFreqBase, kVerbSend, kExct, kStringExtDur, kStringFreq,kstringGain,kStringWet, kStringBowed

endin 

// Sound Generator
instr 1

kStringWet = p14
kControl = p5

kObject1 = p6
kObject2 = p7
//Excitation Source


kenv linseg 1, 0.04, 0
kenv2 linseg 1, 0.014, 0
are pinker
areBal =  (are*0.01)*kenv2

//chose Excitation Type
if p10 = 0 then // Noise
ares1 = (are*0.005)*kenv
ares2 = (are*0.005)*kenv //(are*0.03+((p4-0.5)/70))*kenv
ares ntrpol ares2, ares1, 1-kControl
ares zdf_1pole ares, p4*20000, 0

elseif p10 = 1 then // String

adel init 0
asig pinker
asig = asig*0.0005*(1-(p11*6))

if(p15 =1) then  // Bowed
kenv linseg 0,p11*6, 1, p11,0.3,p11*6, 0
else// plucked
kenv linseg 1, p11, 0
endif
aexc = asig*kenv
aexc init 0

aexc zdf_1pole aexc, p4*20000
adel delay  aexc+adel*0.99, 1/p12
adel zdf_1pole adel, p4*13000

afinal = aexc*0.00+ adel

ares clip (afinal*10)*p13, 0, 0.5
endif 


	//## MODES FREQUENCIES ##//
	
	//Singing Bowl
		kModesSB[] fillarray 285/285, 327.6/285 , 820.9/285, 1307/ 285, 1890/285, 2518/285, 3198/285
	//Glass
		kModesG[] fillarray 826/826, 1847/826, 2785/826,3395/826, 4127/826, 5292/826, 8406/826
		//Conga
		kModesC[] fillarray 198/198, 269/198, 332.2/198, 459/198, 500/198, 588/198, 719/198
				
					
	//Whistle
		//kModes2[] fillarray 1689/1689, 1828/1689, 2061/1689, 3389/1689, 3857/1689, 5319/1689, 7908/1689
	

		
	// PlaceHolder	
		kModes[] fillarray 1, 1,  1, 1, 1, 1, 1
		
		//## MODES RE ##//
		
		//Singin Bowl
		kRESSB[]  fillarray  500, 500, 500, 500, 500, 500, 500
				//Glass
		kRESG[]  fillarray  500, 500, 500, 500, 500, 500, 500
		//Conga
		kRESC[]  fillarray 50, 47, 50, 50, 50, 50, 45
		
		kRESC[] = kRESC + chnget:k("CongaRes")
			//Other Options
			//kRESC[]  fillarray  100,  60, 50, 38, 30, 28, 30
			//kRESC[]  fillarray  80,  40, 50, 25, 15, 15, 15
			
				//Whistle
		//kRESW[]  fillarray  500,  200, 200, 200, 60, 60, 60
		
		
		// PlaceHolder
		kRES[] fillarray  70, 100, 100, 100, 100, 100, 100
		
		
			//## MODES GAIN##//
	
	//Singing Bowl
		kGainsSB[] fillarray  - 61, - 26.7, -28.9 ,-28.9  , -36.1, -38.8 ,-31.7
	//Glass
		kGainsG[] fillarray -44.1, -35.3 ,-52 ,-38.1, -34.4 ,-35.4, -48.3
		//Conga
		kGainsC[] fillarray -15, -25, -12 ,-40 ,-46, -46 ,-46
					
	//Whistle
		//kModesW[] fillarray 1689/1689, 1828/1689, 2061/1689, 3389/1689, 3857/1689, 5319/1689, 7908/1689
	

		
	// PlaceHolder	
		kGains[] fillarray 1, 1,  1, 1, 1, 1, 1
		
		
		
/// SELECT OBJECT 
				kmo oscil 0.3, 0.3
				kmoC oscil 0.3, 4
				kRES[] =(kRES*(p8*0.0054054054))*kmoC
			
		kmod = kmo +1
		if kObject1 >= 0 &&  kObject1 < 1 then
		kModes1[] =kModesSB
		kRES1[] =kRESSB*1+kmod
		kGains1[] =kGainsSB
		kAmp1 = 0.85
		elseif kObject1 >= 1 &&  kObject1 <=2 then
		kModes1[] =kModesG
		kRES1[] =kRESG
		kGains1[] =kGainsG
		kAmp1 = 0.85
		elseif kObject1 >= 2 &&  kObject1 <=3 then
		kModes1[] =kModesC
		kRES1[] =kRESC
		kGains1[] =kGainsC
		kAmp1 = 0.75
		endif
		
		if kObject2 >= 0 &&  kObject2 < 1 then
		kModes2[] =kModesSB
		kRES2[] =kRESSB
		kGains2[] =kGainsSB
		kAmp2 = 0.85
		elseif kObject2 >= 1 &&  kObject2 <2  then
		kModes2[] =kModesG
		kRES2[] =kRESG
		kGains2[] =kGainsG
		kAmp2 = 0.85
		elseif kObject2 >= 2 &&  kObject2 <=3 then
		kModes2[] =kModesC
		kRES2[] =kRESC
		kGains2[] =kGainsC
		kAmp2 = 0.75
		endif
	
	
	
	
	
	
	
	
// Using #define to make each individual element of the array interpolate to the other

// Define 	
	#define	KMODESPORT(ARRN)
	#
kModes[$ARRN] ntrpol  kModes2[$ARRN], kModes1[$ARRN], 1-kControl
;kModes[$ARRN] port kModes[$ARRN],  0.002

kSmallResMod oscil 0.2, 70

if (kControl > 0) &&( kControl < 1) then
kRES[$ARRN] ntrpol  (kRES2[$ARRN]*(kSmallResMod+1))*1.6, kRES1[$ARRN], 1-kControl
elseif (1-kControl == 0) then
kRES[$ARRN] = (kRES2[$ARRN]*(kSmallResMod+1))*1.6
elseif (1-kControl == 1) then
kRES[$ARRN] =  kRES1[$ARRN]
endif

;kRES[$ARRN] port kRES[$ARRN],  0.002 

kGains[$ARRN] ntrpol  kGains2[$ARRN], kGains1[$ARRN], 1-kControl

kAmp ntrpol  kAmp2, kAmp1, 1-kControl 

	#
	
// Generate
	$KMODESPORT(0)
	$KMODESPORT(1)
	$KMODESPORT(2)
	$KMODESPORT(3)
	$KMODESPORT(4)	
	$KMODESPORT(5)
	$KMODESPORT(6)




	
	kSmallMod jitter 0, 0.5, 0.7
	asig MODESYNTH, ares,kAmp,  p8*(1+kSmallMod),  kModes[0], kGains[0],    kRES[0] ,   kModes[1],kGains[1],   kRES[1] ,   kModes[2],kGains[2],   kRES[2] ,  kModes[3],kGains[3],   kRES[3] ,   kModes[4],kGains[4],   kRES[4] ,   kModes[5], kGains[5],  kRES[5] ,   kModes[6],kGains[6],   kRES[6] 
	
	
	
	
	kPitchScale =   limit:k((p8-30)* 0.1,0, 1)

	
	aclick1 mpulse 0.001, 40
	aclick1 zdf_1pole aclick1, (p4*20000), 0
	aclick2 = areBal*0.01
	aclick = aclick1*kPitchScale + aclick2*kPitchScale
	
	
kNoClic linseg 1, p3-0.5, 1, 0.5, 0
	
	aout= (asig*30)+aclick*(kAmp1*1.42857142857)
	
	if p10 = 0 then // Noise
	
	outs (aout*7)*kNoClic, (aout*7)*kNoClic
	gasigFinal = (asig*10)
	

	gaverb = ((asig*1.5)*kNoClic)*p9

elseif p10 = 1 then // string

aclip clip ( (aout*7)*kNoClic)*(1-kStringWet) + (ares*kStringWet*kNoClic)*100, 0, 1.2

		outs  aclip, aclip
		
			gaverb = (((asig*1.5)*kNoClic)*(1-kStringWet) +  ares*kStringWet)*p9
	
endif 
	
	


endin

instr 5

	
	gal, gar shimmer_reverb gaverb, gaverb, 0.1, .95, 16000, 0.45, 100, gkShimerRatio
  outs gal, gar
endin



</CsInstruments>
<CsScore>
i10 0 3000
i5 0 3000
i100 0 3000
e

i "Trigger" 5 1 24
i "Trigger" 6 20 24
i "Trigger"  + 20 25
i "Trigger" + 20 25
i "Trigger" + 20 27
i "Trigger" + 20 28
i "Trigger" + 20 29
i "Trigger" + 20 30
i "Trigger" + 20 31
i "Trigger" + 20 32
i "Trigger" + 20 33
i "Trigger" + 20 34
i "Trigger" + 20 35


f 0 6000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>637</x>
 <y>99</y>
 <width>763</width>
 <height>581</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>220</r>
  <g>238</g>
  <b>224</b>
 </bgcolor>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Control</objectName>
  <x>44</x>
  <y>40</y>
  <width>20</width>
  <height>100</height>
  <uuid>{5d0ffe95-110d-420f-b2da-7857ee2d0826}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.66744321</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Object1</objectName>
  <x>123</x>
  <y>60</y>
  <width>20</width>
  <height>100</height>
  <uuid>{f8b66406-6731-4bc1-9241-6949653f57fe}</uuid>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Object2</objectName>
  <x>205</x>
  <y>60</y>
  <width>20</width>
  <height>100</height>
  <uuid>{c8b46439-5430-4519-9a4d-30648c3452b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>display3</objectName>
  <x>5</x>
  <y>150</y>
  <width>95</width>
  <height>25</height>
  <uuid>{1f02ca38-b5da-404e-9c89-18b01945bf10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Mode Interpolation</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>slider4</objectName>
  <x>125</x>
  <y>1000</y>
  <width>20</width>
  <height>100</height>
  <uuid>{7471a7bd-27db-4396-93a4-83c93e17f37a}</uuid>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>nene</objectName>
  <x>115</x>
  <y>170</y>
  <width>40</width>
  <height>25</height>
  <uuid>{1db37b80-f3fd-41fa-b51e-740a589de0a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Objt1</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>display6</objectName>
  <x>198</x>
  <y>170</y>
  <width>40</width>
  <height>25</height>
  <uuid>{c206bac6-8659-49be-b4f7-bc7f0d3fe673}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Objt2</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>display7</objectName>
  <x>153</x>
  <y>140</y>
  <width>50</width>
  <height>25</height>
  <uuid>{e325ae09-8759-4548-968f-90b97220d851}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>- Bowl -</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>slider8</objectName>
  <x>168</x>
  <y>1000</y>
  <width>20</width>
  <height>100</height>
  <uuid>{c476c1fc-293f-4d33-9821-cee20a85404f}</uuid>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>nana</objectName>
  <x>152</x>
  <y>106</y>
  <width>50</width>
  <height>25</height>
  <uuid>{eb5e07c1-5663-4a65-a1bd-ab4bd7f544af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>- Glass -</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Drum</objectName>
  <x>150</x>
  <y>68</y>
  <width>56</width>
  <height>25</height>
  <uuid>{2d1db7ce-474e-4081-ae2d-556042c9bb22}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>- Conga -</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>Automatic</objectName>
  <x>18</x>
  <y>75</y>
  <width>20</width>
  <height>20</height>
  <uuid>{9faba93f-c9a8-4ae6-bf2f-0fbe8672c498}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>ControlRand</objectName>
  <x>282</x>
  <y>1000</y>
  <width>80</width>
  <height>25</height>
  <uuid>{fdfadd25-dc71-4814-b39a-952eb3a45ea6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-1.888</label>
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
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>275</x>
  <y>1000</y>
  <width>350</width>
  <height>150</height>
  <uuid>{3888f3c3-29f2-4496-bfd0-8b01ca82be1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Freq</objectName>
  <x>112</x>
  <y>360</y>
  <width>80</width>
  <height>25</height>
  <uuid>{6c21ed9b-2d3c-44e5-a7a9-97ec317671fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>185.000</label>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Density</objectName>
  <x>60</x>
  <y>240</y>
  <width>20</width>
  <height>100</height>
  <uuid>{0693b590-fb8f-4783-b9d8-1f577030c001}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>3.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Freq</objectName>
  <x>141</x>
  <y>240</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a076c96f-6625-4a07-b259-ed6ef89cbdd2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>350.00000000</maximum>
  <value>185.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>122</x>
  <y>340</y>
  <width>350</width>
  <height>25</height>
  <uuid>{71f016d0-9fb3-4936-adcc-326fc0a889c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Base Freq
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>50</x>
  <y>348</y>
  <width>80</width>
  <height>25</height>
  <uuid>{bca93680-f1fc-4073-8bee-d2fbb9895720}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Density</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>14</x>
  <y>95</y>
  <width>30</width>
  <height>25</height>
  <uuid>{89a81fe1-f114-4a1a-9b42-f8d5b8182b6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>auto
</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>7</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>CongaRes</objectName>
  <x>305</x>
  <y>240</y>
  <width>20</width>
  <height>100</height>
  <uuid>{febb19eb-fe84-4869-9b6c-3c1003b323a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Dynamics</objectName>
  <x>228</x>
  <y>240</y>
  <width>20</width>
  <height>100</height>
  <uuid>{c22bc3fe-f328-4a5c-a438-9b2c87d0d2df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20420595</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>AutoDyn</objectName>
  <x>200</x>
  <y>280</y>
  <width>20</width>
  <height>20</height>
  <uuid>{8b0030e1-9f7f-4d6f-8386-e4856dc9f157}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>196</x>
  <y>300</y>
  <width>30</width>
  <height>25</height>
  <uuid>{cfbe54de-83c1-42d3-badd-ec0c600d30e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>auto
</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>7</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>212</x>
  <y>348</y>
  <width>80</width>
  <height>25</height>
  <uuid>{214782ab-d71e-452b-b79e-3bd80395cdce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Dynamics</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>284</x>
  <y>348</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7887c180-eb3e-4e2a-99b4-c760eb2403e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Congas Res</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>HighDens</objectName>
  <x>24</x>
  <y>256</y>
  <width>20</width>
  <height>20</height>
  <uuid>{05ca916f-0492-41bc-a941-75631de91a80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>Periodic</objectName>
  <x>24</x>
  <y>310</y>
  <width>20</width>
  <height>20</height>
  <uuid>{fd30f70f-c87e-4394-b8c5-0dc8fb7c0ae9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>6</x>
  <y>273</y>
  <width>50</width>
  <height>40</height>
  <uuid>{87f0cd7d-097d-47ae-ac6e-4cbd63c0ac77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>High
Density
(might overload)</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>5</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>13</x>
  <y>330</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2da2e237-0cf8-4c82-866a-9c13885b0a58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Periodic</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>7</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>BothOff</objectName>
  <x>0</x>
  <y>210</y>
  <width>100</width>
  <height>30</height>
  <uuid>{aeeee799-42f2-4dda-8b79-543fe1020eff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>BothOff</text>
  <image/>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>BothOff</objectName>
  <x>26</x>
  <y>1052</y>
  <width>20</width>
  <height>20</height>
  <uuid>{9dbf9c11-499a-4ae8-a869-8851b7f6c80c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>BothOn</objectName>
  <x>0</x>
  <y>190</y>
  <width>100</width>
  <height>30</height>
  <uuid>{a66261f8-0c58-4a22-abff-5cd2c472b296}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>BothOn</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>60</x>
  <y>120</y>
  <width>80</width>
  <height>25</height>
  <uuid>{af234f70-4bbc-4e85-a69a-3aac15ce8de8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>- Objt1</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>60</x>
  <y>38</y>
  <width>80</width>
  <height>25</height>
  <uuid>{785aa6b1-eaa0-4fab-9ed0-231b6b482c3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>- Objt2</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>VerbSend</objectName>
  <x>44</x>
  <y>408</y>
  <width>20</width>
  <height>100</height>
  <uuid>{09d36706-5ae7-4067-9cb6-f16c1cd13293}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>4.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>VerbSend</objectName>
  <x>14</x>
  <y>533</y>
  <width>80</width>
  <height>25</height>
  <uuid>{62ffee59-cfe2-4391-a353-f96d718f0788}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4.000</label>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>VerbRatio</objectName>
  <x>160</x>
  <y>408</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a1d6242b-1ed8-4aad-bf3e-b07bd57ce97c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>2.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>26</x>
  <y>510</y>
  <width>80</width>
  <height>25</height>
  <uuid>{351e37ec-29fd-498c-bcf1-5e5fcb23edbb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Verb Send</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>140</x>
  <y>522</y>
  <width>80</width>
  <height>50</height>
  <uuid>{af4deb1c-892f-4101-9475-31735f8c6af0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Shimmer Pitch Shift Ratio</label>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>exctType</objectName>
  <x>296</x>
  <y>68</y>
  <width>100</width>
  <height>30</height>
  <uuid>{3d6ae81b-7cb3-488a-a9c3-a81467772507}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>ExctType</text>
  <image>/</image>
  <eventLine>0</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>stringExctDur</objectName>
  <x>411</x>
  <y>64</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3e41d068-bb25-4304-a180-7a8accda86a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.15000000</maximum>
  <value>0.01400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>386</x>
  <y>181</y>
  <width>80</width>
  <height>25</height>
  <uuid>{774d0b4e-5bfc-4848-892d-de7480cf58ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>StringDur
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>StringFreq</objectName>
  <x>483</x>
  <y>66</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3fe25946-de3f-4313-b767-0d09e3a97eb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>880.00000000</maximum>
  <value>440.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>479</x>
  <y>186</y>
  <width>80</width>
  <height>25</height>
  <uuid>{1852910c-f5be-45e7-b4a6-8d8c1272520e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>String Freq</label>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>stringGain</objectName>
  <x>580</x>
  <y>74</y>
  <width>20</width>
  <height>100</height>
  <uuid>{6d4b7617-1b60-4b35-b3a0-3192bef25cea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>573</x>
  <y>192</y>
  <width>80</width>
  <height>25</height>
  <uuid>{21214240-21f8-432f-bfe4-f0abede95b78}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>String Gain
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>StringWet</objectName>
  <x>655</x>
  <y>74</y>
  <width>20</width>
  <height>100</height>
  <uuid>{391ab9fe-9f3c-46b8-ab26-e1226dd663b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>649</x>
  <y>185</y>
  <width>80</width>
  <height>25</height>
  <uuid>{af37935a-22a3-4e85-a220-f89a4c8b2e8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>String Wet/Dry
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
 <bsbObject type="BSBButton" version="2">
  <objectName>StringBowed</objectName>
  <x>296</x>
  <y>105</y>
  <width>100</width>
  <height>30</height>
  <uuid>{c2335d77-f185-4e9e-b47b-7af516d8c6d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Bowed</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>FlanDelay</objectName>
  <x>296</x>
  <y>800</y>
  <width>100</width>
  <height>30</height>
  <uuid>{83c630e6-b666-4fd5-b689-1fd52db7caa1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Flan</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>Freq</objectName>
  <x>124</x>
  <y>200</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7146fb0b-3dfb-424e-b40e-0b7512e429c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>185.00000000</value>
  <resolution>0.00100000</resolution>
  <minimum>10.00000000</minimum>
  <maximum>999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>Trigger</objectName>
  <x>304</x>
  <y>600</y>
  <width>100</width>
  <height>40</height>
  <uuid>{35da0c10-bb7a-487b-8f03-e2c79d04f413}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>pictvalue</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>button52</text>
  <image>/Users/Pedro/Pictures/1200px-Dharma_Wheel.png</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="TurtleTest3" number="0" >
<value id="{5d0ffe95-110d-420f-b2da-7857ee2d0826}" mode="1" >0.79000002</value>
<value id="{f8b66406-6731-4bc1-9241-6949653f57fe}" mode="1" >3.00000000</value>
<value id="{c8b46439-5430-4519-9a4d-30648c3452b8}" mode="1" >1.25999999</value>
<value id="{1f02ca38-b5da-404e-9c89-18b01945bf10}" mode="1" >0.00000000</value>
<value id="{1f02ca38-b5da-404e-9c89-18b01945bf10}" mode="4" >Mode Interpolation</value>
<value id="{7471a7bd-27db-4396-93a4-83c93e17f37a}" mode="1" >0.00000000</value>
<value id="{1db37b80-f3fd-41fa-b51e-740a589de0a4}" mode="1" >0.00000000</value>
<value id="{1db37b80-f3fd-41fa-b51e-740a589de0a4}" mode="4" >Objt1</value>
<value id="{c206bac6-8659-49be-b4f7-bc7f0d3fe673}" mode="1" >0.00000000</value>
<value id="{c206bac6-8659-49be-b4f7-bc7f0d3fe673}" mode="4" >Objt2</value>
<value id="{e325ae09-8759-4548-968f-90b97220d851}" mode="1" >0.00000000</value>
<value id="{e325ae09-8759-4548-968f-90b97220d851}" mode="4" >- Bowl -</value>
<value id="{c476c1fc-293f-4d33-9821-cee20a85404f}" mode="1" >0.00000000</value>
<value id="{eb5e07c1-5663-4a65-a1bd-ab4bd7f544af}" mode="1" >0.00000000</value>
<value id="{eb5e07c1-5663-4a65-a1bd-ab4bd7f544af}" mode="4" >- Glass -</value>
<value id="{2d1db7ce-474e-4081-ae2d-556042c9bb22}" mode="1" >0.00000000</value>
<value id="{2d1db7ce-474e-4081-ae2d-556042c9bb22}" mode="4" >- Conga -</value>
<value id="{9faba93f-c9a8-4ae6-bf2f-0fbe8672c498}" mode="1" >0.00000000</value>
<value id="{fdfadd25-dc71-4814-b39a-952eb3a45ea6}" mode="1" >-1.88800001</value>
<value id="{fdfadd25-dc71-4814-b39a-952eb3a45ea6}" mode="4" >-1.888</value>
<value id="{3888f3c3-29f2-4496-bfd0-8b01ca82be1f}" mode="1" >-255.00000000</value>
<value id="{6c21ed9b-2d3c-44e5-a7a9-97ec317671fc}" mode="1" >16.34900093</value>
<value id="{6c21ed9b-2d3c-44e5-a7a9-97ec317671fc}" mode="4" >16.349</value>
<value id="{0693b590-fb8f-4783-b9d8-1f577030c001}" mode="1" >0.00000000</value>
<value id="{a076c96f-6625-4a07-b259-ed6ef89cbdd2}" mode="1" >16.34900093</value>
<value id="{febb19eb-fe84-4869-9b6c-3c1003b323a4}" mode="1" >0.15000001</value>
<value id="{c22bc3fe-f328-4a5c-a438-9b2c87d0d2df}" mode="1" >0.03000000</value>
<value id="{8b0030e1-9f7f-4d6f-8386-e4856dc9f157}" mode="1" >0.00000000</value>
<value id="{05ca916f-0492-41bc-a941-75631de91a80}" mode="1" >0.00000000</value>
<value id="{fd30f70f-c87e-4394-b8c5-0dc8fb7c0ae9}" mode="1" >1.00000000</value>
<value id="{aeeee799-42f2-4dda-8b79-543fe1020eff}" mode="4" >0</value>
<value id="{9dbf9c11-499a-4ae8-a869-8851b7f6c80c}" mode="1" >0.00000000</value>
<value id="{a66261f8-0c58-4a22-abff-5cd2c472b296}" mode="4" >0</value>
<value id="{09d36706-5ae7-4067-9cb6-f16c1cd13293}" mode="1" >4.00000000</value>
<value id="{62ffee59-cfe2-4391-a353-f96d718f0788}" mode="1" >4.00000000</value>
<value id="{62ffee59-cfe2-4391-a353-f96d718f0788}" mode="4" >4.000</value>
<value id="{a1d6242b-1ed8-4aad-bf3e-b07bd57ce97c}" mode="1" >2.00000000</value>
<value id="{3d6ae81b-7cb3-488a-a9c3-a81467772507}" mode="1" >0.00000000</value>
<value id="{3d6ae81b-7cb3-488a-a9c3-a81467772507}" mode="4" >0</value>
<value id="{3e41d068-bb25-4304-a180-7a8accda86a1}" mode="1" >0.01400000</value>
<value id="{3fe25946-de3f-4313-b767-0d09e3a97eb7}" mode="1" >440.00000000</value>
<value id="{6d4b7617-1b60-4b35-b3a0-3192bef25cea}" mode="1" >0.50000000</value>
<value id="{391ab9fe-9f3c-46b8-ab26-e1226dd663b9}" mode="1" >0.20000000</value>
<value id="{c2335d77-f185-4e9e-b47b-7af516d8c6d6}" mode="1" >0.00000000</value>
<value id="{c2335d77-f185-4e9e-b47b-7af516d8c6d6}" mode="4" >0</value>
<value id="{83c630e6-b666-4fd5-b689-1fd52db7caa1}" mode="1" >0.00000000</value>
<value id="{83c630e6-b666-4fd5-b689-1fd52db7caa1}" mode="4" >0</value>
<value id="{7146fb0b-3dfb-424e-b40e-0b7512e429c3}" mode="1" >16.34900093</value>
</preset>
<preset name="TurtleTest2" number="1" >
<value id="{5d0ffe95-110d-420f-b2da-7857ee2d0826}" mode="1" >0.74000001</value>
<value id="{f8b66406-6731-4bc1-9241-6949653f57fe}" mode="1" >3.00000000</value>
<value id="{c8b46439-5430-4519-9a4d-30648c3452b8}" mode="1" >1.25999999</value>
<value id="{1f02ca38-b5da-404e-9c89-18b01945bf10}" mode="1" >0.00000000</value>
<value id="{1f02ca38-b5da-404e-9c89-18b01945bf10}" mode="4" >Mode Interpolation</value>
<value id="{7471a7bd-27db-4396-93a4-83c93e17f37a}" mode="1" >0.00000000</value>
<value id="{1db37b80-f3fd-41fa-b51e-740a589de0a4}" mode="1" >0.00000000</value>
<value id="{1db37b80-f3fd-41fa-b51e-740a589de0a4}" mode="4" >Objt1</value>
<value id="{c206bac6-8659-49be-b4f7-bc7f0d3fe673}" mode="1" >0.00000000</value>
<value id="{c206bac6-8659-49be-b4f7-bc7f0d3fe673}" mode="4" >Objt2</value>
<value id="{e325ae09-8759-4548-968f-90b97220d851}" mode="1" >0.00000000</value>
<value id="{e325ae09-8759-4548-968f-90b97220d851}" mode="4" >- Bowl -</value>
<value id="{c476c1fc-293f-4d33-9821-cee20a85404f}" mode="1" >0.00000000</value>
<value id="{eb5e07c1-5663-4a65-a1bd-ab4bd7f544af}" mode="1" >0.00000000</value>
<value id="{eb5e07c1-5663-4a65-a1bd-ab4bd7f544af}" mode="4" >- Glass -</value>
<value id="{2d1db7ce-474e-4081-ae2d-556042c9bb22}" mode="1" >0.00000000</value>
<value id="{2d1db7ce-474e-4081-ae2d-556042c9bb22}" mode="4" >- Conga -</value>
<value id="{9faba93f-c9a8-4ae6-bf2f-0fbe8672c498}" mode="1" >0.00000000</value>
<value id="{fdfadd25-dc71-4814-b39a-952eb3a45ea6}" mode="1" >-1.88800001</value>
<value id="{fdfadd25-dc71-4814-b39a-952eb3a45ea6}" mode="4" >-1.888</value>
<value id="{3888f3c3-29f2-4496-bfd0-8b01ca82be1f}" mode="1" >-255.00000000</value>
<value id="{6c21ed9b-2d3c-44e5-a7a9-97ec317671fc}" mode="1" >16.34900093</value>
<value id="{6c21ed9b-2d3c-44e5-a7a9-97ec317671fc}" mode="4" >16.349</value>
<value id="{0693b590-fb8f-4783-b9d8-1f577030c001}" mode="1" >1.10000002</value>
<value id="{a076c96f-6625-4a07-b259-ed6ef89cbdd2}" mode="1" >16.34900093</value>
<value id="{febb19eb-fe84-4869-9b6c-3c1003b323a4}" mode="1" >0.15000001</value>
<value id="{c22bc3fe-f328-4a5c-a438-9b2c87d0d2df}" mode="1" >0.85000002</value>
<value id="{8b0030e1-9f7f-4d6f-8386-e4856dc9f157}" mode="1" >0.00000000</value>
<value id="{05ca916f-0492-41bc-a941-75631de91a80}" mode="1" >0.00000000</value>
<value id="{fd30f70f-c87e-4394-b8c5-0dc8fb7c0ae9}" mode="1" >1.00000000</value>
<value id="{aeeee799-42f2-4dda-8b79-543fe1020eff}" mode="4" >0</value>
<value id="{9dbf9c11-499a-4ae8-a869-8851b7f6c80c}" mode="1" >0.00000000</value>
<value id="{a66261f8-0c58-4a22-abff-5cd2c472b296}" mode="4" >0</value>
<value id="{09d36706-5ae7-4067-9cb6-f16c1cd13293}" mode="1" >4.00000000</value>
<value id="{62ffee59-cfe2-4391-a353-f96d718f0788}" mode="1" >4.00000000</value>
<value id="{62ffee59-cfe2-4391-a353-f96d718f0788}" mode="4" >4.000</value>
<value id="{a1d6242b-1ed8-4aad-bf3e-b07bd57ce97c}" mode="1" >2.00000000</value>
<value id="{3d6ae81b-7cb3-488a-a9c3-a81467772507}" mode="1" >0.00000000</value>
<value id="{3d6ae81b-7cb3-488a-a9c3-a81467772507}" mode="4" >0</value>
<value id="{3e41d068-bb25-4304-a180-7a8accda86a1}" mode="1" >0.01400000</value>
<value id="{3fe25946-de3f-4313-b767-0d09e3a97eb7}" mode="1" >440.00000000</value>
<value id="{6d4b7617-1b60-4b35-b3a0-3192bef25cea}" mode="1" >0.50000000</value>
<value id="{391ab9fe-9f3c-46b8-ab26-e1226dd663b9}" mode="1" >0.20000000</value>
<value id="{c2335d77-f185-4e9e-b47b-7af516d8c6d6}" mode="1" >0.00000000</value>
<value id="{c2335d77-f185-4e9e-b47b-7af516d8c6d6}" mode="4" >0</value>
<value id="{83c630e6-b666-4fd5-b689-1fd52db7caa1}" mode="1" >0.00000000</value>
<value id="{83c630e6-b666-4fd5-b689-1fd52db7caa1}" mode="4" >0</value>
<value id="{7146fb0b-3dfb-424e-b40e-0b7512e429c3}" mode="1" >16.34900093</value>
</preset>
</bsbPresets>
