* Import data --------------------------------------------


file ExternalFile / ExternalFile.txt /
$onecho  > ExternalFileOPF.txt
 i="Input_Data_OPF.xls"
 r0=Indices
 o0=Indices_OPF.inc
 r1=Resistive_Network
 o1=Resistive_Network_OPF.inc
 r2=CCSources
 o2=CCSources_OPF.inc
 r3=CPload
 o3=CPload_OPF.inc
 r4=CVref
 o4=CVref_OPF.inc
 r5=DCVref
 o5=DCVref_OPF.inc
 r6=G_Droop
 o6=G_Droop_OPF.inc
 r8=CCloads
 o8=CCloads_OPF.inc



$offecho
$call xls2gms @"ExternalFileOPF.txt"
* End of import data -------------------------------------
