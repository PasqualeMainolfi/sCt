/*
un progetto di Paquale Mainolfi
©PasqualeMainolfi2020
*/

    opcode mask, i, iio //maschera di transizione
idurTransition, inumberWin, imode xin

ilen = (idurTransition * sr)
ilenWin = int(ilen/inumberWin)
print(ilen, ilenWin)

imask = ftgen(0, 0, ilen, 2, 0)

ioverlap = 0
ir = 1
inn = inumberWin
while (inn > 0) do
    ilimit = int((inn/inumberWin) * ilenWin)
    im = 0
    while (im < ilenWin) do
        if(im < ilimit) then
            ival = 0.5 * (1 - cos((2 * $M_PI * im)/ilimit)) //hann win
            else
                ival = 0
            endif

            if(imode != 0) then
                ir = (inn - 1)/inumberWin //fade out
                else
                    ir = 1
                endif
            //prints("[%d] = %d\n", im + ioverlap, ival)
            //prints("%.3f\n", ir)
            tablew(ival * ir, im + ioverlap, imask)
            im += 1
        od
        ioverlap += ilenWin
        inn -= 1
    od

xout(imask)
    endop

    opcode envClip, i, i //genera transiente di attacco per la clip target a fine maschera
isize xin
ienv = ftgen(0, 0, isize, 2, 0)
isampleTime = int(.005 * sr)

ii = 0
while (ii < isize) do
    if(ii <= isampleTime/2) then
        //ival = (1/isampleTime) * ii
    ival = 0.5 * (1 - cos(2 * $M_PI * ii/isampleTime)) //inviluppo da applicare al fine maschera di transizione ----> la prima metà di una finestra hann
        else
            ival = 1
        endif
        tablew(ival, ii, ienv)
        ii += 1
    od

xout(ienv)
    endop


    opcode shockCross, a, SiSiii
Sample1, iread1, Sample2, iread2, ipt, imask xin

/*
Sample1, Sample2 = stringa clip1, 2
iread1, 2 = read mode -1 ---> reverse 1 ---> normal
ipt = punto di applicazione transizione
imask = maschera di transizione
*/

setksmps(1)

ilenSample1 = filelen(Sample1)
isrSample1 = filesr(Sample1)
isizeSource = (ilenSample1 * isrSample1)

ilenSample2 = filelen(Sample2)
isrSample2 = filesr(Sample2)
isizeTarget = (ilenSample2 * isrSample2)

iclip1 = ftgen(0, 0, isizeSource, 1, Sample1, 0, 0, 0)
iclip2 = ftgen(0, 0, isizeTarget, 1, Sample2, 0, 0, 0)

ilenMask = ftlen(imask)
ipoint = int(ipt * sr) //punto di applicazione transizione
iout = ipoint + ilenMask //punto d'uscita transizione
itotSample = iout + (ftlen(iclip2) - ilenMask) //numero limite contatore ---> fino alla fine clip2

ienv = envClip(itotSample - iout) //applicazione inviluppo seconda clip

ki init 0
if(ki < itotSample) then
    kndx1 = ki - ipoint
    kndx2 = ki - iout //indice maschera inviluppo clip 2 in uscita

    if(iread1 = -1) then
        kread1 = isizeSource - ki
        else
            kread1 = ki
        endif

    if(iread2 = -1) then
        kread2 = isizeTarget - kndx1
        else
            kread2 = kndx1
        endif

    if(ki < ipoint) then
    a1 = tablei(kread1, iclip1)
    elseif(ki >= ipoint && ki < iout) then
        //printf("%d\n", 1, kndx) ;skip index
        ai = tablei(kread1, iclip1) * tablei(kndx1, imask)
        aj = tablei(kread2, iclip2) * tablei(ilenMask - kndx1, imask) //in modo da puntare a indice 0
        a1 = ai + aj
        elseif(ki >= iout) then
            //printf("%d\n", 1, kndx2) ;skip index
            a1 = tablei(kread2, iclip2) * tablei(kndx2, ienv)
        endif
        asource = a1
        ki += a(1)
    endif

xout(asource)
    endop
