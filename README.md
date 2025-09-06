# S-Bandwidth Graph Weightings

![License: MIT](https://img.shields.io/badge/License-MIT-pink.svg)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/JuliaDiff/BlueStyle)
[![Code Style: Ruff](https://img.shields.io/badge/code%20style-ruff-rebeccapurple.svg)](https://github.com/astral-sh/ruff)

## Overview

Recall that an undirected, possibly weighted graph *G* is said to be "*S*-diagonalizable" for some finite set of integers *S* &subset; **Z** if there exists some diagonal matrix *D* and matrix *P* with all entries from *S* such that *G*'s Laplacian matrix *L*(*G*) = *PDP*<sup>-1</sup>. If *G* is *S*-diagonalizable, then its "*S*-bandwidth" is the minimum integer *k* &isin; {1, 2, &hellip;, |*V*(*G*)|} such that there exists some diagonal matrix *D* and matrix *P* with all entries from *S* such that *L*(*G*) = *PDP*<sup>-1</sup> and [*P*<sup>T</sup>*P*]<sub>*i,j*</sub> = 0 whenever |*i* - *j*| &ge; *k*; otherwise, its *S*-bandwidth is simply &infin;.[^JP25] We denote this quantity by *&beta;*<sub>*S*</sub>(*G*) &isin; **R&#x305;** (where, of course, **R&#x305;** is the extended real number line).

For specific choices of *S* (namely {-1, 1} and {-1, 0, 1}), the *S*-bandwidth of a quantum network has been shown to be an indicator of high state transfer fidelity due to automorphic properties of the graph, a topic of interest in the broader context of quantum information theory. Given that the edge weights of a graph represent coupling strengths between qubits in the corresponding quantum network, it is only natural to ask whether one can assign edge weights to an unweighted graph *G* to reduce its *S*-bandwidth.

We conjecture that this cannot be done with positive edge weightings. More formally: if *G* is a simple connected graph, *G*<sup>\*</sup> is a positively weighted version of *G*, and *S* &isin; {{-1, 1}, {-1, 0, 1}} is a finite set of integers, then *&beta;*<sub>*S*</sub>(*G*) &le; *&beta;*<sub>*S*</sub>(*G*<sup>\*</sup>). We further suspect that the statement holds for all edge weights of the form *a* + *bi* &isin; **C** where *a* > 0 and *b* &ge; 0, and we know it to be false once one allows for any real nonzero edge weights (both positive and negative). However, positive edge weightings are the most physically relevant in the context of quantum networks, since they correspond to the strength of qubit couplings.

Based on the computational survey of small connected undirected graphs conducted herein, we find strong evidence in support of this conjecture. More precisely, we use linear programming techniques to confirm that [TODO: Write here]

## Methodology

[TODO: Write here][^Var25][^VJP25]

## Dependencies

Should one wish to run the scripts in `jobs` themselves to confirm reproducibility, the following requirements must be installed and accessible in your `PATH` environment variable:

- Python (v3.11+)
- Julia (v1.10+)
- MATLAB (R2023b+)

The [CVX](https://cvxr.com/cvx/) package (v2.0+) must also be accessible in your MATLAB path. (All external Python and Julia packages, on the other hand, are automatically installed in a virtual environment when running any of the `jobs/job*.sh` scripts.)

## Citing

I encourage you to cite this work if you find this data useful in your research. The citation information may be found in the [CITATION.bib](https://raw.githubusercontent.com/Luis-Varona/s-bandwidth-graph-weightings/main/CITATION.bib) file within the repository.

## References

[^JP25]: N. Johnston and S. Plosker. Laplacian {−1,0,1}- and {−1,1}-diagonalizable graphs. *Linear Algebra and its Applications*, 704:309&ndash;339, 2025. [10.1016/j.laa.2024.10.016](https://doi.org/10.1016/j.laa.2024.10.016).
[^Var25]: L. M. B. Varona. Luis-Varona/small-graph-s-bandwidths: A computational survey of the S-bandwidths of small simple connected graphs. *GitHub*, 2025. [Luis-Varona/small-graph-s-bandwidths](https://GitHub/Luis-Varona/small-graph-s-bandwidths).
[^VJP25]: L. M. B. Varona, N. Johnston, and S. Plosker. GraphQuantum/SDiagonalizability.jl: A dynamic algorithm to minimize or recognize the *S*-bandwidth of an undirected graph. *GitHub*, 2025. [GraphQuantum/SDiagonalizability.jl](https://github.com/GraphQuantum/SDiagonalizability.jl).
