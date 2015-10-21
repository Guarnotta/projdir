* Import data --------------------------------------------


file ExternalFile / ExternalFile.txt /
$onecho  > ExternalFileOPF-2.txt
 i="Input_Data_OPF2.xls"
 r0=Indices
 o0=Indices_OPF2.inc
 r1=Resistive_Network
 o1=Resistive_Network_OPF2.inc
 r2=CCSources
 o2=CCSources_OPF2.inc
 r3=CPload
 o3=CPload_OPF2.inc
 r4=CVref
 o4=CVref_OPF2.inc
 r5=DCVref
 o5=DCVref_OPF2.inc
 r6=G_Droop
 o6=G_Droop_OPF2.inc
 r8=CCloads
 o8=CCloads_OPF2.inc



$offecho
$call xls2gms @"ExternalFileOPF-2.txt"
* End of import data -------------------------------------
