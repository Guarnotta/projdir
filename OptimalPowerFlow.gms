* Version 10.3_All_loads_Excel_Input
* --------------------------------------------------------
* 6-node system description:
* n1 as grouding point
* CV load at n5.n6
* --------------------------------------------------------

sets
i
ij    (i,i)   lines
is    (i,i)   current sources
idccs (i,i)   droop controlled sources
icv   (i,i)   constant voltage
icp   (i,i)   constant power
;

Alias(i,j,k,l);

*-----------------------------------
parameters
G(i,j)
CCS   (i,j)
DCCS  (i,j)
CV    (i,j)
CP    (i,j)
Vref  (i,j)
Gdroop(i,j)
;

*-- Import from .inc & Excel--------
sets
$include  indices.inc
;

table Gmap(i,j,*)
$include Resistive_Network.inc
;

table CSmap(i,j,*)
$include CSources.inc
;

table CPmap(i,j,*)
$include CPload.inc
;

table CVmap(i,j,*)
$include CVref.inc
;

table DCVmap(i,j,*)
$include DCVref.inc
;

table DCGmap(i,j,*)
$include G_Droop.inc
;

G     (i,j) = Gmap   (i,j,'Gline' ) ;
CCS   (i,j) = CSmap  (i,j,'L'     ) ;
DCCS  (i,j) = DCVmap (i,j,'DCVref') ;
CV    (i,j) = CVmap  (i,j,'CVref' ) ;
CP    (i,j) = CPmap  (i,j,'CPload') ;
Vref  (i,j) = DCVmap (i,j,'DCVref') ;
Gdroop(i,j) = DCGmap (i,j,'Gdroop') ;

*--------------------------------
* Nominal Voltage for CP loads
scalar Vnom      /47.5/
*--------------------------------
* Definition of Variables
Variables
* Resistive Network Side
*--------------------------------
Ibranch(i,j)      'Branch Current'
V(i)              'Nodal Voltage'
In(i)             'Nodal Current'
Incv (i)
CS(i,j)           'Current source'


*--------------------------------

*--------------------------------
* Solver
dummy            'dummy variable'
*--------------------------------
;

Equations
AllCurrentSources (i)    'Current input by Sources'
BranchCurrent     (i,j)  'Current Flowing through ij branch'
* Nodal current calculated as the difference between the total input and
* total output of currents flowing through connected branches
NodalCurrent       (i)    'Nodal Current equation'

NodalCurrentCV     (i,j)
ConstantVoltage    (i,j)
*-------------------------------
edummy
;

*-------------------------------
* Set Voltage limits and fixed nodal voltages
V.lo(i)     =   -200;
V.up(i)     =    200;
V.fx('n1')  =    0;


*dynamic set of indices
ij(i,j)    $[G(i,j)]     = yes;
is(i,j)    $[CCS(i,j)]   = yes;
idccs(i,j) $[DCCS(i,j)]  = yes;
icv(i,j)   $[CV(i,j)]    = yes;
icp(i,j)   $[CP(i,j)]    = yes;

* Equations from the resistive part of the network
BranchCurrent    (ij(i,j)) .. Ibranch(i,j) =e= (G(i,j)*(V(i)-V(j)));
NodalCurrent     (i)       .. In(i) =e= sum[j $ij(i,j)   ,Ibranch(i,j)]-sum[j $ij(j,i), Ibranch(j,i)];

* Current Sources and loads (CC, DCCS, CV)
AllCurrentSources (i)         .. In(i)     =e=   sum[j $is(i,j)   ,CCS(i,j)] + sum[j $icp(i,j), CP(i,j)/Vnom*[1-1/Vnom*(V(i)-V(j)-Vnom)]] + sum[j $icv(i,j), Incv(j)] + sum[j $idccs(i,j),(Vref(i,j) - [V(i)-V(j)])*Gdroop(i,j)];

*-------------------------------
ConstantVoltage   (icv(i,j))  .. V(i)-V(j) =e=  CV(i,j);
NodalCurrentCV    (icv(i,k))  .. Incv(i)   =e=  sum[j $ij(j,i), Ibranch(j,i)];

edummy.. dummy =e= 0;
*-------------------------------

Model PowerFlow /all/ ;
Solve PowerFlow minimizing dummy using lp;
display
                  G,
                V.l,
                 ij,
                 is,
              idccs,
                icv,
               in.l,
                icp,
          Ibranch.l;


*- sum[j $icp(j,i), CP(i,j)/Vnom*[1-1/Vnom*(V(j)-V(i)-Vnom)]]
* - sum[j $is(j,i)   ,CCS(j,i)];
