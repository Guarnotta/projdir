Sets
i
ij   (i,i)      lines
CCs  (i,i)      constant current sources
CCl  (i,i)      constant current loads

;

Alias
(i,j)
;

* -----------------------------------------------------------------------------
* DATA IMPORT FROM EXCEL FILE *


Sets
$include Indices_OPF.inc
;

table Rmap(i,j,*)
$include Resistive_Network_OPF.inc
;

table CCsourcesmap(i,j,*)
$include CCsources_OPF.inc
;

table CCloadsmap(i,j,*)
$include CCloads_OPF.inc
;

* -----------------------------------------------------------------------------
* PARAMETER DEFINITION

Parameters

R          (i,j)
CCSref     (i,j)
CCScost    (i,j)
CCSmax     (i,j)
CCSmin     (i,j)
CCLoads    (i,j)
Sources
;

R        (i,j)  =  Rmap(i,j,'Rline')           ;
CCSref   (i,j)  =  CCsourcesmap(i,j,'CCSmap')  ;
CCScost  (i,j)  =  CCsourcesmap(i,j,'CCScost') ;
CCSmax   (i,j)  =  CCsourcesmap(i,j,'CCSmax')  ;
CCSmin   (i,j)  =  CCsourcesmap(i,j,'CCSmin')  ;
CCLoads  (i,j)  =  CCloadsmap(i,j,'CCLmap')    ;



Scalar
Vnom       /47.5/
;

* -----------------------------------------------------------------------------
* DYNAMIC SET OF INDICES

ij    (i,j)    $[R(i,j)]            = yes;
CCs   (i,j)    $[CCSref(i,j)]       = yes;
CCl   (i,j)    $[CCLoads(i,j)]      = yes;

Sources  = sum[(i,j), CCSref(i,j)];
* -----------------------------------------------------------------------------
* VARIABLE DEFINITION

Variables
Ibr       (i,j)         'Branch Current'
In        (i)           'Nodal Current'
V         (i)           'Nodal Voltage'
CCSources (i,j)         'Constant Current Source'
cost


* -----------------------------------------------------------------------------
* POWER FLOW EQUATIONS

Equations

AllCurrentSources (i)     'Sum of currents of all sources at node i'
BranchCurrent     (i,j)   'Current in branch ij'
NodalCurrent      (i)     'Nodal current equation'

Equality
Costfunction              'Cost function to be minimized'
;

* -----------------------------------------------------------------------------
* Set Voltage limits and fixed nodal voltages
V.lo(i)     =   -200;
V.up(i)     =    200;
V.fx('n1')  =    0;

*CCSources.lo (i,j) = CCSmin;
*CCSources.up (i,j) = CCSmax;

CCSources.lo (i,j) = -9;
CCSources.up (i,j) = 9;



* -----------------------------------------------------------------------------
* Circuit Equation

BranchCurrent     (ij(i,j)) .. Ibr(i,j) =e=  (R(i,j)*(V(i)-V(j)));
NodalCurrent      (i)       .. In(i)    =e=  sum[j $ij(i,j)   ,Ibr(i,j)] - sum[j $ij(j,i), Ibr(j,i)];
AllCurrentSources (i)       .. In(i)    =e=  sum[j $CCs(i,j)  ,CCSources(i,j)] + sum[j $CCl(i,j)  ,CCLoads(i,j)];



* -----------------------------------------------------------------------------
* OPTIMAL POWER FLOW EQUATIONS

Equality                    ..  sum[(i,j) $CCs(i,j), CCSources(i,j)] =e= sum[(i,j) $CCl(i,j), CCLoads(i,j)];
Costfunction                ..  cost    =e=  sum[(i,j) $CCs(i,j), CCSources(i,j)*CCScost(i,j)];

model OPF /all/;

solve OPF minimizing cost using lp;

Display
R,
V.l,
ij,
CCs,
CCl,
In.l,
Ibr.l,
CCSources.l,
cost.l
;







