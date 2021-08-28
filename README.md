# BraKet
A Mathematica package to do simple quantum information calculations symbolically.

See the accompanying manual `BraKet.nb` for a more in-depth explanation. 

## Basic Notation
We can enter bras and kets using the built-in functions of Mathematica: `Ket[]` and `Bra[]`, or equivalently `esc ket esc` or `esc bra esc`
```Mathematica
  psi = Ket[0]
```

Tensor products can be built using `CircleTimes[]`, or equivalently using `\[CircleTimes]`
```Mathematica
  psi = Ket[0] \[CircleTimes] Ket[1]
```

Inner products are taken using `CenterDot[]`, or equivalently using `\[CenterDot]`
```Mathematica
  Bra[0] \[CenterDot] Ket[0]
```
It is assumed that all states are written in the same basis `{Ket[0], Ket[1], ..., Ket[d-1]}`. 
By default d=2 , but it can be changed through `SetBasis[d]`. 

Operators can be built by summing and taking tensor product of terms of form 
```Mathematica
  Ket[...] \[CenterDot] Bra[...]
```
For example
```Mathematica
pauliX = Ket[0] \[CenterDot] Bra[1] + Ket[1] \[CenterDot] Bra[0]
```
We can act on states by using again `CenterDot[]`
```Mathematica
  pauliX \[CenterDot] Ket[0]
```

Expressions involving `\[CircleTimes]` and `\[CenterDot]` can be expanded using `BraketExpand[]` (in addition to the usual `Expand[]`)

## Quantum Information
The package implements some basic quantum information operations and quantities:
- Bell states
- Pauli matrices
- Identity for n qudits

And some simple operations:
- Partial trace
- Von Neumann entropy
