<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

/*
...un progetto di Pasquale Mainolfi
©PasqualeMainolfi2020
*/

sr = 96000
ksmps = 8
nchnls = 2
0dbfs = 1

#include "shockCross.udo"


  instr 1
Sample1 = "Cane.wav"
Sample2 = "Rob.wav"
Sample3 = "Stru.wav"

ipoint = 0 //punto di applicazione transizione
itotDur = .9 //durata dell'intera transizione
inumWin = 7 //numero totale di finestre di transizione
iread1 = 1 //verso lettura
iread2 = -1 //verso lettura

imaschera = mask(itotDur, inumWin) //maschera di transizione
asound1 = shockCross(Sample1, iread1, Sample2, iread1, ipoint, imaschera)
asound2 = shockCross(Sample2, iread2, Sample3, iread1, ipoint, imaschera)

aout = (asound1 + asound2)/2

 outs(aout, aout)

  endin



</CsInstruments>
<CsScore>

i 1 0 10

</CsScore>
</CsoundSynthesizer>
