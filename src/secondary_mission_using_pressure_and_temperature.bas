' ------------------------------------------------------------
' Name :  Secundaire Missie met druk en temp
' Doel :  de secundaire missie uitvoeren met druk en temperatuur
' Geschiedenis:
' 17-04-2008  BK  Aangemaakt
' ------------------------------------------------------------
waardeadc var word	' De waarde ADC voor de druk
voltage var float	' Het voltage afgeleid van waardeadc
druk var float		' De druk berekend met voltage
mindruk var float	' Druk op toppunt van parabool
maxdruk var float	' Druk op grond
mintemp var float	' Temperatuur op toppunt van parabool
maxtemp var float	' Temperatuur op grond
a var float			' Hulpvariabele voor druk
c var float         ' Hulpvariabele voor temp

waardeadc2 var word	' Waarde ADC voor temperatuur
voltage2 var float	' Voltage voor de temperatuur
temperatuur var float ' Temperatuur in graden Celsiuss
bOntKoppel var byte ' Boolean om aan te geven of we al kunnen ontkoppelen

OMSLAG con 40	     ; Percentage voorbij omslagpunt om los te gaan koppelen
 
' -------------------------------------------------------------
' Doel : Opstarten: bepaal de frequentie alvorens versturen
' -------------------------------------------------------------
loop1:
serout P15,i1200, ["F8D5B9",13] 'frequentie is 434,250
' Wacht in verband met mogelijk vastlopen
pause 1000
' Geef de naam van onze Cansat door aan grondstation
serout P15,i1200, ["C Cancrash",13]
' Wacht in verband met mogelijk vastlopen
pause 1000

' -------------------------------------------------------------
' Doel : Opstarten van de secundaire missie
' -------------------------------------------------------------
loop3:
' Lees huidige druk af in waardeadc en converteer naar KPa
adin P0,waardeadc
voltage = (tofloat waardeadc) / 1023.0 * 5.0
' Converteer voltage naar Kilo Pascal
mindruk = voltage * 22.222 + 10.556
' Stel initieel maxdruk in op mindruk
maxdruk = mindruk
' Lees huidige druk af in waardeadc2 en converteer naar KPa
adin P1,waardeadc2
voltage2 = (tofloat waardeadc2) / 1023.0 * 5.0
' Converteer voltage naar temperatuur (Celsius)
mintemp = voltage2 * 50.0 + 4.5
' Stel initieel maxdruk in op mindruk
maxtemp = mintemp
' Stel in dat we nog niet kunnen ontkoppelen
bOntKoppel = 0

	
' -------------------------------------------------------------
' Doel : secundaire missie uitvoeren
' -------------------------------------------------------------
loop4:
do
	' Voer metingen van de primaire missie uit
	gosub loop2
	' Lees huidige druk af in waardeadc
	adin P0,waardeadc
	' Converteer druk naar voltage
	voltage = (tofloat waardeadc) / 1023.0 * 5.0
	' Converteer naar KPa en assign aan variabele a
	a = voltage * 22.222 + 10.556
	' nu ook de druk aflezen in waardeadc2
	adin P1,waardeadc2
	' Converteer temperatuur naar voltage
	voltage2 = (tofloat waardeadc2) / 1023.0 * 5.0
	' Converteer naar graden Celcius en assign aan variabele a
	c = voltage2 * 50.0 + 4.5
	' Zorg dat mindruk steeds de minst gemeten druk aangeeft
	if a < mindruk then 
		mindruk = a
	endif
	' Zorg dat mintemp steeds de minst gemeten temperatuur aangeeft
	if c < mintemp then 
		mintemp = c
	endif
	' Kijk of we voorbij het omslagpunt van de parabool komen
	'  (dan is de huidige druk GROTER dan de minimale druk
	if a > mindruk and c > mintemp then
		' We zijn voorbij het omslagpunt
		' Zoek uit of we het juiste percentage voorbij omslagpunt zijn
		gosub reken
		' reageer op het resultaat van de REKEN subroutine
		if bOntKoppel = 1 then
			' Zorg dat het X ontkoppeld wordt
			high P2
		endif
	endif
while 1


end

' ------------------------------------------------------------
' Name :  reken (met druk en temp)
' Doel :  Bepaal of het ontkoppelpunt is bereikt
' Geschiedenis:
' 17-04-2008  BK  Aangemaakt
' ------------------------------------------------------------
reken:
	if (100 * abs(a - mindruk) / (abs(maxdruk - mindruk))) and (100 * abs(c - mintemp) / (abs(maxtemp - mintemp))) > OMSLAG then 
		bOntKoppel = 1
	endif
return

' -------------------------------------------------------------
' Doel : meten van de druk en de temperatuur
' -------------------------------------------------------------
loop2:
' Lees de waarde van de druk af in waardeADC
adin P0,waardeadc
' Werk 0-1023 range om naar voltage tussen 0-5 volt
voltage = (tofloat waardeadc) / 1023.0 * 5.0
' Reken voltage om naar druk in KPa
druk = voltage * 22.222 + 10.556
' Lees de waarde (0-1023) van temperatuur af
adin P1,waardeadc2
' Werk om naar voltage (0-5)
voltage2 = (tofloat waardeadc2) / 1023.0 * 5.0
' Converteer voltage naar temperatuur (Celsius)
temperatuur = voltage2 * 50.0 + 4.5

' Pause voor het zenden begint
pause 200
' Zend de druk en temperatuur naar grondstation
serout P15,i1200, ["S","Druk:",real druk, "  ","Temperatuur:",real temperatuur,13]
' Wacht ivm beter zenden
pause 1000
return