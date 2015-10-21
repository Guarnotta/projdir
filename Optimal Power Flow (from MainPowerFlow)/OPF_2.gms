* Based on Version 11.0
* --------------------------------------------------------
* n-node system:
* n1 as grouding point
* --------------------------------------------------------

* Choose the number of equations shown in .lst file
option limrow=15;

* Define indices represending nodes and connecting point for sources and loads
sets
i
ij     (i,i)   lines
CCs    (i,i)   constant current sources
CCl    (i,i)   constant current loads
idccs  (i,i)   droop controlled sources
icv    (i,i)   constant voltage
icp    (i,i)   constant power
;

Alias(i,j,k,l);

*-- Import from .inc & Excel--------
sets
$include  indices_OPF2.inc
;

table Gmap(i,j,*)
$include Resistive_Network_OPF2.inc
;

table CCSmap(i,j,*)
$include CCSources_OPF2.inc
;

table CCLmap(i,j,*)
$include CCloads_OPF2.inc
;

table CPmap(i,j,*)
$include CPload_OPF2.inc
;

table CVmap(i,j,*)
$include CVref_OPF2.inc
;

table DCVmap(i,j,*)
$include DCVref_OPF2.inc
;

table DCGmap(i,j,*)
$include G_Droop_OPF2.inc
;

*-----------------------------------
parameters
G          (i,j)
CCSref     (i,j)
CCScost    (i,j)
CCSmax     (i,j)
CCSmin     (i,j)
CCLoads    (i,j)
DCCS       (i,j)
CV         (i,j)
CP         (i,j)
Vref       (i,j)
Gdroop     (i,j)
;

G        (i,j)  =  Gmap        (i,j,'Gline' )  ;
CCSref   (i,j)  =  CCSmap      (i,j,'CCSmap')  ;
CCScost  (i,j)  =  CCSmap      (i,j,'CCScost') ;
CCSmax   (i,j)  =  CCSmap      (i,j,'CCSmax')  ;
CCSmin   (i,j)  =  CCSmap      (i,j,'CCSmin')  ;
CCLoads  (i,j)  =  CCLmap      (i,j,'CCLmap')  ;

DCCS     (i,j)  =  DCVmap      (i,j,'DCVref')  ;
CV       (i,j)  =  CVmap       (i,j,'CVref' )  ;
CP       (i,j)  =  CPmap       (i,j,'CPload')  ;
Vref     (i,j)  =  DCVmap      (i,j,'DCVref')  ;
Gdroop   (i,j)  =  DCGmap      (i,j,'Gdroop')  ;

*--------------------------------
* Nominal Voltage for CP loads
scalar Vnom      /47.5/;

*dynamic set of indices
ij   (i,j)    $[G(i,j)]        = yes;
CCs  (i,j)    $[CCSref(i,j)]   = yes;
CCl  (i,j)    $[CCLoads(i,j)]  = yes;

idccs(i,j)    $[DCCS(i,j)]     = yes;
icv  (i,j)    $[CV(i,j)]       = yes;
icp  (i,j)    $[CP(i,j)]       = yes;


*--------------------------------
* Definition of Variables
Variables
* Resistive Network Side
*--------------------------------
Ibr       (i,j)      'Branch Current'
In        (i)        'Nodal Current'
V         (i)        'Nodal Voltage'
CCSources (i,j)      'Constant Current Source'
Incv      (i,j)
cost

*--------------------------------
Solver
dummy            'dummy variable'
*--------------------------------
;

Equations
AllCurrentSources  (i)    'Current input by Sources'
BranchCurrent      (i,j)  'Current Flowing through ij branch'
NodalCurrent       (i)    'Nodal Current equation'
Costfunction              'Cost function to be minimized'


NodalCurrentCV     (i,j)
ConstantVoltage    (i,j)


edummy
;

*-------------------------------
* Set Voltage limits and fixed nodal voltages

V.lo(i)      =   -200;
V.up(i)      =    200;
V.fx('n1')   =    0;

CCSources.lo (i,j) = -5;
CCSources.up (i,j) =  5;

* Equations from the resistive part of the network
BranchCurrent      (ij(i,j)) .. Ibr(i,j)   =e= (G(i,j)*(V(i)-V(j)));
NodalCurrent       (i)       .. In(i)      =e= sum[j $ij(i,j)   ,Ibr(i,j)]-sum[j $ij(j,i), Ibr(j,i)];
AllCurrentSources  (i)       .. In(i)      =e=  - sum[j $icv(i,j), Incv(i,j)]  + sum[j $CCs(i,j)   ,CCSources(i,j)] + sum[j $CCl(i,j)  ,CCLoads(i,j)] + sum[j $icp(i,j), CP(i,j)/Vnom*[1-1/Vnom*(V(i)-V(j)-Vnom)]]  + sum[j $idccs(i,j),(Vref(i,j) - [V(i)-V(j)])*Gdroop(i,j)];
*AllCurrentSources  (i)       .. In(i)      =e=  sum[j $CCs(i,j)   ,CCSources(i,j)] + sum[j $CCl(i,j)  ,CCLoads(i,j)] ;

*-------------------------------
ConstantVoltage   (icv(i,j))  .. V(i)-V(j) =e=  CV(i,j);
NodalCurrentCV    (icv(i,k))  .. sum[j $icv(i,j), Incv(j,i) ]  + sum[l $ij(l,i), Ibr(l,i)] =e= 0;

*-------------------------------
*Costfunction                ..  cost      =e=  sum[CCs(i,j), CCSources(i,j)*CCScost(i,j)];

edummy..             dummy =e= 0;

model OPF /all/;
solve OPF minimizing dummy using lp;
*solve OPF minimizing cost using lp;

display
                  G,
                V.l,
                 ij,
                CCs,
              idccs,
                icv,
               in.l,
                icp,
              Ibr.l,
         CCSources.l
;
