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
ij    (i,i)   lines
CCs   (i,i)  constant current sources
CCl   (i,i)   constant current loads
idccs (i,i)   droop controlled sources
icv   (i,i)   constant voltage
icp   (i,i)   constant power
;

Alias(i,j,k,l);

* -----------------------------------------------------------------------------
* DATA IMPORT FROM EXCEL FILE *

Sets
$include Indices_OPF.inc
;

Table Gmap(i,j,*)
$include Resistive_Network_OPF.inc
;

Table CCSmap(i,j,*)
$include CCsources_OPF.inc
;

Table CCLmap(i,j,*)
$include CCloads_OPF.inc
;

Table CPmap(i,j,*)
$include CPload_OPF.inc
;

Table CVmap(i,j,*)
$include CVref_OPF.inc
;

Table DCVmap(i,j,*)
$include DCVref_OPF.inc
;

Table DCGmap(i,j,*)
$include G_Droop_OPF.inc
;

* -----------------------------------------------------------------------------
* PARAMETER DEFINITION

Parameters
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


G        (i,j)  =  Gmap   (i,j,'Gline' )  ;
CCSref   (i,j)  =  CCSmap (i,j,'CCSmap')  ;
CCScost  (i,j)  =  CCSmap (i,j,'CCScost') ;
CCSmax   (i,j)  =  CCSmap (i,j,'CCSmax')  ;
CCSmin   (i,j)  =  CCSmap (i,j,'CCSmin')  ;
CCLoads  (i,j)  =  CCLmap (i,j,'CCLmap')  ;
DCCS     (i,j)  =  DCVmap (i,j,'DCVref')  ;
CV       (i,j)  =  CVmap  (i,j,'CVref' )  ;
CP       (i,j)  =  DCVmap (i,j,'DCVref')  ;
Vref     (i,j)   =  DCVmap(i,j,'DCVref')  ;
Gdroop   (i,j)  =  DCGmap (i,j,'Gdroop')  ;

Scalar
Vnom       /47.5/
;

* -----------------------------------------------------------------------------
* DYNAMIC SET OF INDICES

ij    (i,j)    $[G(i,j)]            = yes;
CCs   (i,j)    $[CCSref(i,j)]       = yes;
CCl   (i,j)    $[CCLoads(i,j)]      = yes;
idccs (i,j)    $[DCCS(i,j)]         = yes;
icv   (i,j)    $[CV(i,j)]           = yes;
icp   (i,j)    $[CP(i,j)]           = yes;

* -----------------------------------------------------------------------------
* VARIABLE DEFINITION

Variables
Ibranch   (i,j)         'Branch Current'
In        (i)           'Nodal Current'
V         (i)           'Nodal Voltage'
Incv      (i,j)         'In for constant voltage'
CCSources (i,j)         'Constant Current Source'
cost

Equations

AllCurrentSources  (i)     'Sum of currents of all sources at node i'
BranchCurrent      (i,j)   'Current in branch ij'
NodalCurrent       (i)     'Nodal current equation'
NodalCurrentCV     (i,j)
ConstantVoltage    (i,j)
Costfunction               'Cost function to be minimized'
*Equality           (i,j)
Equality2          (i,j)
;

* -----------------------------------------------------------------------------
* Set Voltage limits and fixed nodal voltages

*V.lo(i)           =   -200;
*V.up(i)           =    200;
*V.fx('n1')        =    0;

V.fx('n1')     =   0;

V.lo('n2')     =  50;
V.lo('n3')     =  50;
V.lo('n4')     =  50;
V.lo('n7')     =  50;

V.lo('n6')     =  -10;
V.lo('n5')     =  -10;
*V.lo('n8')     =  -10;


V.up('n2')     =  500;
V.up('n3')     =  500;
V.up('n5')     =  500;
V.up('n4')     =  500;
V.up('n6')     =  500;
V.up('n7')     =  500;
*V.up('n8')     =  500;





*CCSources.lo (i,j) = CCSmin (i,j);
*CCSources.up (i,j) = CCSmax (i,j);

CCSources.lo ('n2','n1') = 0;
CCSources.up ('n2','n1') = 15;

CCSources.lo ('n4','n5') = 0;
CCSources.up ('n4','n5') = 15;



* -----------------------------------------------------------------------------
* Circuit Equation

BranchCurrent     (ij(i,j))   .. Ibranch(i,j) =e= (G(i,j)*(V(i)-V(j)));
*NodalCurrent      (i)         .. In(i)        =e= sum[j $ij(i,j)   ,Ibranch(i,j)]-sum[j $ij(j,i), Ibranch(j,i)];
NodalCurrent      (i)         .. In(i)        =e= sum[j $ij(i,j)   ,Ibranch(i,j)];
AllCurrentSources (i)         .. In(i)         =e=  - sum[j $icv(i,j), Incv(i,j)]  + sum[j $CCs(i,j)   ,CCSources(i,j)] + sum[j $CCl(i,j)   ,CCLoads(i,j)] + sum[j $icp(i,j), CP(i,j)/Vnom*[1-1/Vnom*(V(i)-V(j)-Vnom)]]  + sum[j $idccs(i,j),(Vref(i,j) - [V(i)-V(j)])*Gdroop(i,j)];
ConstantVoltage   (icv(i,j))  .. V(i)-V(j)    =e=  CV(i,j);
NodalCurrentCV    (icv(i,k))  .. 0            =e=  sum[j $icv(i,j), Incv(j,i) ]  + sum[l $ij(l,i), Ibranch(l,i)];

*Equality          (ij(i,j))   .. Ibranch(i,j)   =e= -Ibranch(j,i) ;
Equality2         (CCs(i,j))   .. CCSources(i,j) =e= -CCSources(j,i);

* -----------------------------------------------------------------------------
* OPTIMAL POWER FLOW EQUATIONS

Costfunction                  ..  cost         =e=  sum[CCs(i,j), CCSources(i,j)*CCScost(i,j)];

*-------------------------------

Model PowerFlow /all/ ;

Solve PowerFlow minimizing cost using lp;

display
                  G,
                 ij,
                CCs,
                CCl,
               In.l,
                V.l,
          Ibranch.l,
        CCSources.l,
             cost.l
;
