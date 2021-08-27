(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* ::Input::Initialization:: *)
(* A Mathematica package to do simple quantum information calculatin symbolically by A. F. Rotundo. *)


(* ::Input::Initialization:: *)
BeginPackage["Braket`"];


(* ::Input::Initialization:: *)
SetBasis::usage = "SetBasis[n] sets the number of states in the basis to n.";

CenterDot::usage = "Product of brakets.";
CircleTimes::usage = "Tensor product.";

BraketExpand::usage="Expands expressions involving CircleTimes and CenterDot.";
BraketJoin::usage = "Joins tensor products into single kets and bras.";
BraketSplit::usage = "Undo BraketJoin.";
Swap::usage = "Swap[exp, {a,b}] swaps tensor factors a and b in an expression.";
BraketToVect::usage = "Translate a state or operator from braket notation to vector notation.";
BraketFromVect::usage = "Undo BraketToVect.";

Id::usage = "Id[n_Integer] generates the identity for a system of n qudits.";
B00::usage="Bell state: \!\(\*TemplateBox[{\"00\"},\n\"Ket\"]\)+\!\(\*TemplateBox[{\"11\"},\n\"Ket\"]\).";
B01::usage="Bell state: \!\(\*TemplateBox[{\"01\"},\n\"Ket\"]\)+\!\(\*TemplateBox[{\"10\"},\n\"Ket\"]\).";
B10::usage="Bell state: \!\(\*TemplateBox[{\"00\"},\n\"Ket\"]\)-\!\(\*TemplateBox[{\"11\"},\n\"Ket\"]\).";
B11::usage="Bell state: \!\(\*TemplateBox[{\"01\"},\n\"Ket\"]\)-\!\(\*TemplateBox[{\"10\"},\n\"Ket\"]\).";
\[Sigma]::usage = "\[Sigma][n] is the nth Pauli matrix.";

StateNorm::usage = "StateNorm[\!\(\*TemplateBox[{\"\[Psi]\"},\n\"Ket\"]\)] computes the norm of \!\(\*TemplateBox[{\"\[Psi]\"},\n\"Ket\"]\).";
DensityNorm::usage = "DensityNorm[\[Rho]] computes the norm of \[Rho].";
(* seems redundant
TraceOp::usage = "TraceOp[Op] computes the trace of Op.";
*)
PartialTrace::usage = "PartialTrace[\[Rho], list] traces \[Rho] over the tensor factors in the list.";
EntropyVN::usage = "DensityNorm[\[Rho]] computes the von Neumann entropy of \[Rho].";
EntropyVN::usage = "DensityNorm[\[Rho]] computes the von Neumann entropy of the density matrix.";
Rewire::usage = "Rewire[O, perm, n] permute the wires accoding to perm (inputs and outputs treated indifferently) and then keep n as outputs (kets).";


(* ::Input::Initialization:: *)
Begin["`Private`"];


(* ::Input::Initialization:: *)
Clear[d,basisList];
d=2;
basisList ={0,1};
SetBasis[n_Integer]:=Module[{},
d=n;basisList = Table[i,{i,0,n-1}];]


(* ::Input::Initialization:: *)
ClearAll[Ket]
ClearAll[Bra]
Ket/:Conjugate[x_Ket]:=x/.Ket->Bra;
Bra/:Conjugate[x_Bra]:=x/.Bra->Ket;
Ket/:Ket[]:=1;
Bra/:Bra[]:=1;


(* ::Input::Initialization:: *)
Clear[countBraket];
countBraket[x_?NumericQ]:=True;
countBraket[x_]:=And@@(FreeQ[x,#]&/@{Ket,Bra,Pattern});
(* We include also Pattern because otherwise countBraket will modify some of the definitions. *)


(* ::Input::Initialization:: *)
ClearAll[CircleTimes]
(* Bring scalars in front *)
CircleTimes/:CircleTimes[x___,Times[y_?countBraket,z__],t___]:=Times[y,CircleTimes[x,z,t]]; 
(* Flatten nested CircleTimes *)
CircleTimes[x___,CircleTimes[y__],z___]:=CircleTimes[x,y,z];
(* Conjugate commute with tensor product*)
CircleTimes/:Conjugate[x_CircleTimes]:=Conjugate[#]&/@x;
(* If one of the tensor is a number, take it out (for example this happens after we calculate inner products *)
CircleTimes/:CircleTimes[x___,y_?countBraket,z___]:=Times[y,CircleTimes[x,z]];
CircleTimes/:CircleTimes[]:=1;
CircleTimes/:CircleTimes[x_]:=x/;MemberQ[{Ket,Bra},Head[x]];


(* ::Input::Initialization:: *)
ClearAll[CenterDot]
(* We assume that everything is written in terms of orthornormal basis *)
(* Inner product between vectors *)
CenterDot/:Bra[x_]\[CenterDot]Ket[y_]:=If[x==y,1,0]/;SubsetQ[basisList,{x,y}];
CenterDot/:CenterDot[CircleTimes[x__Bra],CircleTimes[y__Ket]]:=CircleTimes@@MapThread[CenterDot[#1,#2]&,{List[x],List[y]}];
(* Resolves inner product of exterior products *)
CenterDot[x_CenterDot,y_CenterDot]:=CenterDot[x[[2]],y[[1]]]CenterDot[x[[1]],y[[2]]];
CenterDot[x_CenterDot,y_]:=CenterDot[x[[2]],y]x[[1]]/;MemberQ[{CircleTimes,Ket},Head[y]];
CenterDot[x_,y_CenterDot]:=CenterDot[x,y[[1]]]y[[2]]/;MemberQ[{CircleTimes,Bra},Head[x]];
(* Product between operators *)
(*CenterDot/:CenterDot[CenterDot[x_Ket,y_Bra],CenterDot[z_Ket,t_Bra]]:=CenterDot[y,z]CenterDot[x,t];
CenterDot/:CenterDot[CenterDot[CircleTimes[x__Ket],CircleTimes[y__Bra]],CenterDot[CircleTimes[z__Ket],CircleTimes[t__Bra]]]:=CenterDot[CircleTimes[y],CircleTimes[z]] CenterDot[CircleTimes[x],CircleTimes[t]];
CenterDot/:CenterDot[CenterDot[x_Ket,CircleTimes[y__Bra]],CenterDot[CircleTimes[z__Ket],t_Bra]]:=CenterDot[CircleTimes[y],CircleTimes[z]] CenterDot[x,t];
CenterDot/:CenterDot[CenterDot[CircleTimes[x__Ket],y_Bra],CenterDot[z_Ket,CircleTimes[t__Bra]]]:=CenterDot[y,z]CenterDot[CircleTimes[x],CircleTimes[t]] ;
CenterDot/:CenterDot[CenterDot[CircleTimes[x__Ket],CircleTimes[y__Bra]],CircleTimes[z__Ket]]:=CenterDot[CircleTimes[y],CircleTimes[z]] CircleTimes[x];
CenterDot/:CenterDot[CircleTimes[x__Bra],CenterDot[CircleTimes[y__Ket],CircleTimes[z__Bra]]]:=CenterDot[CircleTimes[x],CircleTimes[y]] CircleTimes[z];*)
(* Bring scalars in front *)
CenterDot/:CenterDot[x___,Times[y_?countBraket,z__],t___]:=Times[y,CenterDot[x,z,t]]; 
CenterDot/:CenterDot[x___,y_?countBraket ,z___]:=Times[y,CenterDot[x,z]];
(* Conjugate on CenterDot *)
CenterDot/:Conjugate[x_CenterDot]:=CenterDot@@(Conjugate[#]&/@Permute[List@@x,Mod[Range[#]+#/2,#]/.{0->#}]&@Length[x]);
CenterDot[x_]:=x;


(* ::Input::Initialization:: *)
Clear[internalBraketExpand,BraketExpand];
internalBraketExpand[CircleTimes[x___,y_Plus,z___]]:=CircleTimes[x,#,z]&/@y;
internalBraketExpand[CenterDot[x___,y_Plus,z___]]:=CenterDot[x,#,z]&/@y;
internalBraketExpand[x_Plus]:=internalBraketExpand[#]&/@x;
internalBraketExpand[x_Times]:=internalBraketExpand[#]&/@x;
internalBraketExpand[x_CircleTimes]:=internalBraketExpand[#]&/@x;
internalBraketExpand[x_CenterDot]:=internalBraketExpand[#]&/@x;
internalBraketExpand[x_/;MemberQ[{Ket,Bra},Head[x]]]:=x;
internalBraketExpand[CircleTimes[x__CenterDot]]:=CenterDot@@CircleTimes@@@{#[[1]]&/@List@@@List[x],#[[2]]&/@List@@@List[x]};
(* Reorganize CircleTimes of CenterDot *)
internalBraketExpand[CircleTimes[z___,x_CenterDot,y__Ket,t___]]:=CircleTimes[z,CenterDot[CircleTimes[x[[1]],y],x[[2]]],t];
internalBraketExpand[CircleTimes[z___,x_CenterDot,y__Bra,t___]]:=CircleTimes[z,CenterDot[x[[1]],CircleTimes[x[[2]],y]],t];
internalBraketExpand[CircleTimes[y__Ket,x_CenterDot]]:=CenterDot[CircleTimes[y,x[[1]]],x[[2]]]
internalBraketExpand[CircleTimes[y__Bra,x_CenterDot]]:=CenterDot[x[[1]],CircleTimes[y,x[[2]]]]
(* the function internalBraketExpand is called until the output doesn't change anymore *)
internalBraketExpand[x_?countBraket]:=x;
BraketExpand[x_]:=
FixedPoint[internalBraketExpand,x];


(* ::Input::Initialization:: *)
Clear[BraketJoin];
BraketJoin[CircleTimes[Ket[x__],Ket[y__]]]:=Ket[x,y];
BraketJoin[CircleTimes[Ket[x__],Ket[y__],z__]]:=BraketJoin[CircleTimes[Ket[x,y],z]];
BraketJoin[CircleTimes[Bra[x__],Bra[y__]]]:=Bra[x,y];
BraketJoin[CircleTimes[Bra[x__],Bra[y__],z__]]:=BraketJoin[CircleTimes[Bra[x,y],z]];
(* This is needed for operators *)
BraketJoin[x_Plus]:=BraketJoin[#]&/@x;
BraketJoin[x_Times]:=BraketJoin[#]&/@x;
BraketJoin[x_CenterDot]:=BraketJoin[#]&/@x;
BraketJoin[x_List]:=BraketJoin[#]&/@x;
BraketJoin[x_?countBraket]:=x;
(* If the first conditions are not met apply BraketExpand *)
BraketJoin[x_]:=BraketJoin[BraketExpand[x]];


(* ::Input::Initialization:: *)
Clear[BraketSplit];
(* Undo BraketJoin *)
BraketSplit[Ket[x__]]:=(Ket[#]&/@List[x])/.List->CircleTimes;
BraketSplit[Bra[x__]]:=(Bra[#]&/@List[x])/.List->CircleTimes;
BraketSplit[x__Plus]:=BraketSplit[#]&/@x;
BraketSplit[x__Times]:=BraketSplit[#]&/@x;BraketSplit[x__CenterDot]:=BraketSplit[#]&/@x;
BraketSplit[x_?countBraket]:=x;
(* Sometimes it is convenient to split kets ina specific place *)
BraketSplit[Ket[x__],n_Integer]:=CircleTimes[List[x][[1;;n+1]],List[x][[n+2;;Length[List[x]]]]]/.List->Ket;
BraketSplit[Bra[x__],n_Integer]:=CircleTimes[List[x][[1;;n+1]],List[x][[n+2;;Length[List[x]]]]]/.List->Bra;
BraketSplit[x__Plus,n_Integer]:=BraketSplit[#,n]&/@x;
BraketSplit[x__Times,n_Integer]:=BraketSplit[#,n]&/@x;
BraketSplit[x_?countBraket,n_Integer]:=x;


(* ::Input::Initialization:: *)
(* TO DO *)
ClearAll[CircleCollect];
(* First we implement a CircleCollect which only works on the first tensor factor *)
CircleCollect[CircleTimes[a__,b__]+CircleTimes[a__,c__]]:=CircleTimes[a,b+c];
CircleCollect[CircleTimes[a__,b__]+CircleTimes[d__,c__]]:=Plus[CircleTimes[a,b],CircleTimes[d,c]]/;!a===d;
CircleCollect[Plus[CircleTimes[a__,b__],CircleTimes[a__,c__],d__]]:=CircleCollect[Plus[CircleTimes[a,b+c],d]];
CircleCollect[Plus[CircleTimes[a__,b__],CircleTimes[e__,c__],d__]]:=Plus[CircleTimes[a,b],CircleTimes[e,c],d];/;!a===d;
(* We implement CircleCollect on the other tensor factors by sandwitch it between Swap's*)
CircleCollect[x__,n_Integer]:=Swap[CircleCollect[Swap[x,0,n]],0,n];


(* ::Input::Initialization:: *)
ClearAll[Swap,swapCondition]
swapCondition[x_]:=
(MemberQ[{Ket,Bra,CenterDot},Head[#]]&/@ReplacePart[x,0->List])/.List->And;
Swap/:Swap[x_CircleTimes/;swapCondition[x],a_Integer,b_Integer]:=Module[{appo,list},
list=x/.{CircleTimes->List};
appo=list[[a]];
list[[a]]=list[[b]];
list[[b]]=appo;
list/.{List->CircleTimes}
];
(*Linear*)
Swap/:Swap[x_,a_Integer,b_Integer]:=Swap[x//BraketExpand,a,b];
Swap/:Swap[x_+y_,a_Integer,b_Integer]:=Swap[x,a,b]+Swap[y,a,b];
Swap/:Swap[c_?countBraket x__,a_Integer, b_Integer]:=c Swap[x,a,b];
Swap/:Swap[x__ c_?countBraket ,a_Integer, b_Integer]:=c Swap[x,a,b];
(*Define multiple swaps*)
Swap/:Swap[x_,{a_Integer,b_Integer}]:=Swap[x,a,b];
Swap/:Swap[x_,l_List]:=Fold[Swap,x,l];


(* ::Input::Initialization:: *)
Clear[BraketToVect];
(* Ket are mapped to columns vectors, (1xn) matrices in Mathematica, Bra's to row vectors, (nx1) matrices. *)
BraketToVect[x_Ket]:=Table[If[i==FromDigits[x/.Ket->List,d],{1},{0}],{i,0,d^Length[x/.Ket->List]-1}];BraketToVect[x_Bra]:=List[Table[If[i==FromDigits[x/.Bra->List,d],1,0],{i,0,d^Length[x/.Ket->List]-1}]];
(* CenterDot is mapped to Dot which, since we map bra and ket to row and column vectors, does automatically the inner or outer product *)
BraketToVect[x_CenterDot]:=(BraketToVect[#]&/@(dummyFun@@x))/.dummyFun->Dot;
BraketToVect[x_Plus]:=Map[BraketToVect,x];
BraketToVect[x_Times]:=Map[BraketToVect,x];
(*  Notice that the matrices we get keep memory of the tensor structure *)
BraketToVect[x_CircleTimes]:=KroneckerProduct@@Map[BraketToVect,List@@x];
BraketToVect[x_?countBraket]:=x ;


(* ::Input::Initialization:: *)
BraketFromVect[v_List/;Length[v[[1,All]]]==1]:=Sum[v[[i+1,1]]*Ket[Delete[PadLeft[IntegerDigits[i,d],Log[d,Length[v]]],0]],{i,0,Length[v]-1}]//BraketSplit;
BraketFromVect[v_List/;Length[v[[All,1]]]==1]:=Sum[v[[1,i+1]]*Bra[Delete[PadLeft[IntegerDigits[i,d],Log[d,Length[v[[1]]]]],0]],{i,0,Length[v[[1]]]-1}]//BraketSplit;
BraketFromVect[v_List/;ArrayDepth[v]==2]:=
Sum[v[[i+1,j+1]]*(Ket[Delete[PadLeft[IntegerDigits[i,d],Log[d,Length[v[[1,All]]]]],0]]\[CenterDot]Bra[Delete[PadLeft[IntegerDigits[j,d],Log[d,Length[v[[All,1]]]]],0]]),{i,0,Length[v[[1,All]]]-1},{j,0,Length[v[[All,1]]]-1}]//BraketSplit;


(* ::Input::Initialization:: *)
ClearAll[Basis]
Basis[1]:=Table[Ket[i],{i,0,d-1}];
Basis[n_Integer/;n>0]:=(ReplacePart[Table[Basis[1],n],0->CircleTimes]/.List->Plus//BraketExpand)/.Plus->List;
(*Basis called over negative integers gives the dual basis*)
Basis[n_Integer/;n<0]:=Basis[-n]/.{Ket->Bra};


(* ::Input::Initialization:: *)
Unprotect[Id];
Clear[Id];
Id[n_Integer]:=Sum[i\[CenterDot]Conjugate[i],{i,Basis[n]}];


(* ::Input::Initialization:: *)
Unprotect[B00,B01,B10,B11];
Clear[B00,B01,B10,B11];
B00=1/\[Sqrt]2 (Ket[0]\[CircleTimes]Ket[0]+Ket[1]\[CircleTimes]Ket[1]);
B01=1/\[Sqrt]2 (Ket[0]\[CircleTimes]Ket[1]+Ket[1]\[CircleTimes]Ket[0]);
B10=1/\[Sqrt]2 (Ket[0]\[CircleTimes]Ket[0]-Ket[1]\[CircleTimes]Ket[1]);
B11=1/\[Sqrt]2 (Ket[0]\[CircleTimes]Ket[1]-Ket[1]\[CircleTimes]Ket[0]);


(* ::Input::Initialization:: *)
Unprotect[\[Sigma]];
Clear[\[Sigma]];
\[Sigma][0]=Id[1];
\[Sigma][1]=Ket[0]\[CenterDot]Bra[1]+Ket[1]\[CenterDot]Bra[0];
\[Sigma][2]=I(Ket[1]\[CenterDot]Bra[0]-Ket[0]\[CenterDot]Bra[1]);
\[Sigma][3]=Ket[0]\[CenterDot]Bra[0]-Ket[1]\[CenterDot]Bra[1];


(* ::Input::Initialization:: *)
StateNorm[s_]:=Conjugate[s]\[CenterDot]s//BraketExpand;
DensityNorm[s_]:=Module[{appo,len},
appo=BraketExpand[s];
len=FirstCase[appo,x_CircleTimes,Missing[],Infinity]//Length;
TraceOp[appo,len]
]
(* Not needed anymore? *)
BraketNorm[CenterDot[x_Ket,y_Bra]]:=CenterDot[y,x];


(* ::Input::Initialization:: *)
Clear[TraceOp,PartialTrace];
PartialTrace[CenterDot[x_Ket,y_Bra],1]:=CenterDot[y,x];
PartialTrace[CenterDot[CircleTimes[x__Ket],CircleTimes[y__Bra]],place_Integer]:=(CenterDot[#[[2,place]],#[[1,place]]]&@CenterDot[CircleTimes[x],CircleTimes[y]])Delete[CenterDot[CircleTimes[x],CircleTimes[y]],{{2,place},{1,place}}];
(*PartialTrace[x_CircleTimes,place_Integer ]:=Times[BraketNorm[x[[place+1]]],CircleTimes[Drop[x,{place+1}]]];*)
PartialTrace[x_Plus,place_Integer]:=PartialTrace[#,place]&/@x;
PartialTrace[x_Times,place_Integer]:=PartialTrace[#,place]&/@x;
PartialTrace[x_?countBraket,place_Integer]:=x;
PartialTrace[x__,list_List]:=Block[{correctedList,appo},
appo=Sort[list];
correctedList=Table[appo[[i]]-(i-1),{i,Length[list]}];
Fold[PartialTrace,x,correctedList]
];
PartialTrace[x_,place_Integer]:=PartialTrace[x//BraketExpand,place];

TraceOp[operator_,size_]:=PartialTrace[operator,Range[size]];


(* ::Input::Initialization:: *)
Clear[EntropyVN];
EntropyVN[operator_]:=Sum[If[\[Lambda]!=0,-\[Lambda] Log[\[Lambda]],0],{\[Lambda],Eigenvalues[operator//BraketToVect]}];


(* ::Input::Initialization:: *)
Clear[Rewire,InternalRewire];
Rewire[x_,list_List, nOutputs_Integer]:=InternalRewire[BraketExpand[x],list,nOutputs];
(* Rewire first calls BraketExpand such that the expression is in a nice form *) 
InternalRewire[x_Plus,list_List,nOutputs_Integer]:=Rewire[#,list,nOutputs]&/@x;
InternalRewire[x_Times,list_List,nOutputs_Integer]:=Rewire[#,list,nOutputs]&/@x;
InternalRewire[x_?countBraket,list_List,nOutputs_Integer]:=x;
(* InternalRewire takes in the permutation of wires and an integer which tells how many wires should be input (inputs are always the leftmost wires) *)
InternalRewire[x_CenterDot,perm_List,nOutputs_Integer]:=CenterDot@@{CircleTimes@@#[[1;;nOutputs]],CircleTimes@@#[[nOutputs+1;;]]/.Ket->Bra}&@Permute[x/.{CenterDot->List,CircleTimes->List,Bra->Ket}//Flatten,perm]
InternalRewire[x_CircleTimes,perm_List,nOutputs_Integer]:=CenterDot[CircleTimes@@#[[1;;nOutputs]],CircleTimes@@#[[nOutputs+1;;]]/.Ket->Bra]&@Permute[List@@x,perm]


(* ::Input::Initialization:: *)
Protect[Id,\[Sigma]];
Protect[B00,B01,B10,B11];


(* ::Input::Initialization:: *)
End[];
EndPackage[];