debug ["This is a test",13]

adval1 var word
adval2 var word

t1 var float
t2 var float
pressure var float
temperature var float

pause 3000


serout P15,i1200,["C KD4HBO",13]
pause 500
serout P15,i1200,["D APRS2",13]

pause 500
loop1:
	adin P0,adval1
	pause 100
	adin P1,adval2
	pause 100
	t2 = (tofloat adval1) / 1023.0 * 5.0
	pressure = t2 * 22.222 + 10.56
	t1 = tofloat adval2 / 1023.0 * 5.0
	temperature = t1 * 50.0 + 4.5
	debug ["T1 ",real pressure," ",real temperature,13]
	serout P15,i1200,["S", real pressure," ",real temperature,13]
	pause 3000
	toggle P14
	goto loop1
	end
	
	
