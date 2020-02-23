waardeadc var word
voltage var float
druk var float
vorigedruk var float

waardeadc2 var word
voltage2 var float
temperatuur var float
 


loop1:
adin P0,waardeadc
voltage = (tofloat waardeadc) / 1023.0 * 5.0
druk = voltage * 22.222 + 10.556
adin P1,waardeadc2
voltage2 = (tofloat waardeadc2) / 1023.0 * 5.0
temperatuur = voltage2 * 50.0 + 4.5

debug ["Air pressure: ", real druk,13]
debug ["Temperature: ", real temperatuur,13]

pause 1000

goto loop1


end

