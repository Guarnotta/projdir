* Import data --------------------------------------------


file ExternalFile / ExternalFileOPF.txt /
$onecho  > ExternalFileOPF.txt
 i="Input_Data_OPF.xls"
 r0=Indices
 o0=Indices_OPF.inc
 r1=Resistive_Network
 o1=Resistive_Network_OPF.inc
 r2=CCsources
 o2=CCsources_OPF.inc
 r3=CCloads
 o3=CCloads_OPF.inc



$offecho
$call xls2gms @"ExternalFileOPF.txt"
* End of import data -------------------------------------
