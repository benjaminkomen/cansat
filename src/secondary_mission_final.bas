' ------------------------------------------------------------
' Name :  Secundaire Missie met druk, uiteindelijke versie
' Doel :  de secundaire missie uitvoeren met druk
' Geschiedenis:
' 17-04-2008  BK  Aangemaakt
' ------------------------------------------------------------
waardeadc var word	' De waarde ADC voor de druk
voltage var float	' Het voltage afgeleid van waardeadc
druk var float		' De druk berekend met voltage
mindruk var float	' Druk op toppunt van parabool
maxdruk var float	' Druk op grond
a var float			' Hulpvariabele

waardeadc2 var word	' Waarde ADC voor temperatuur
voltage2 var float	' Voltage voor de temperatuur
temperatuur var float ' Temperatuur in graden Celsiuss
bOntKoppel var byte ' Boolean om aan te geven of we al kunnen ontkoppelen
flag var word       ' Hulpvariabele voor extra controle toppunt

OMSLAG con 40	     ; Percentage voorbij omslagpunt om los te gaan koppelen
 
' -------------------------------------------------------------
' Doel : Opstarten: bepaal de frequentie alvorens versturen
' -------------------------------------------------------------
loop1:
serout P15,i1200, ["F8D78D",13] 'frequentie is 434,600
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
mindruk = voltage * 22.222 + 10.556
' Stel initieel maxdruk in op mindruk
maxdruk = mindruk
' Stel in dat we nog niet kunnen ontkoppelen
' Lees huidige druk af in waardeadc en converteer naar KPa
bOntKoppel = 0

	
' -------------------------------------------------------------
' Doel : secundaire missie uitvoeren
' -------------------------------------------------------------
loop4:
' stel flag op 0 in
flag = 0
do
	' Voer metingen uit
	gosub loop2
	' Lees huidige druk af in waardeadc
	adin P0,waardeadc
	' Converteer druk naar voltage
	voltage = (tofloat waardeadc) / 1023.0 * 5.0
	' Converteer naar KPa en assign aan variabele a
	a = voltage * 22.222 + 10.556
	' Zorg dat mindruk steeds de minst gemeten druk aangeeft
	if a < mindruk then 
		mindruk = a
	endif
	' Kijk of we voorbij het omslagpunt van de parabool komen
	'  (dan is de huidige druk GROTER dan de minimale druk
	if a > mindruk then
		' eerst controleren of dit wel echt de juiste plek is
		' er moet 3 keer achter elkaar a groter dan mindruk worden gemeten
		flag = flag + 1
	    ' zorg ervoor dat de flag niet groter wordt hdan 10
		if flag > 10 then
			flag = 10
		endif
	' als a niet groter is dan mindruk moet de mindruk weer gelijk gesteld worden 
	' aan de lagere a en de flag weer terug op 0
	else
		if a < mindruk then
			mindruk = a and flag = 0
		endif
	endif
	' als er 3 keer de juiste meting wordt gedaan 
	' en de druk is lager dan 100 om te voorkomen dat hij op de grond
	' al gaat, dan zijn we voorbij het omslagpunt
	if flag > 3 and a < 100.0 then 
		' We zijn voorbij het omslagpunt
		' Zoek uit of we het juiste percentage voorbij omslagpunt zijn
		gosub reken
		' reageer op het resultaat van de REKEN subroutine
		if bOntKoppel = 1 then
			' Zorg dat het X ontkoppeld wordt door servo rond te laten draaien
			'start het servo commanda om te draaien
			SERVO P2, 2400, 20
		endif
	endif
'herhaal deze loop oneindig
while 1


end

' ------------------------------------------------------------
' Name :  reken
' Doel :  Bepaal of het ontkoppelpunt is bereikt
' Geschiedenis:
' 01-04-2008  BK  Aangemaakt
' ------------------------------------------------------------
reken:
	if ((a - mindruk) / (maxdruk - mindruk) * 100) > OMSLAG then 
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
serout P15,i1200, ["S",real druk, "  ",real temperatuur,13]
' Wacht ivm beter zenden
pause 1000
return