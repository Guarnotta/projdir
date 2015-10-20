* Import data --------------------------------------------


file ExternalFile / ExternalFile.txt /
$onecho  > ExternalFile.txt
 i="Input_Data.xls"
 r0=Indices
 o0=Indices.inc
 r1=Resistive_Network
 o1=Resistive_Network.inc
 r2=CSources
 o2=CSources.inc
 r3=CPload
 o3=CPload.inc
 r4=CVref
 o4=CVref.inc
 r5=DCVref
 o5=DCVref.inc
 r6=G_Droop
 o6=G_Droop.inc



$offecho
$call xls2gms @"ExternalFile.txt"
* End of import data -------------------------------------
