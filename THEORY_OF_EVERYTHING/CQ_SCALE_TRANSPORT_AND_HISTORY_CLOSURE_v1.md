# CQ Scale-Transport and History-to-State Closure v1

## Continuity
- Project: Theory of Everything
- Repository: `spiritofthefair/vera-truth-system`
- Branch: `truth-evolution`
- Parent frontier: physical-dilation / nonunitarity gate
- Repeater law: advance the same Theory-of-Everything chain only.

## New result 1 — CQ trade-off is regime-conditional
For Markovian completely-positive classical-quantum dynamics with quantum-to-classical backreaction, the decoherence, backreaction, and classical diffusion kernels are constrained by the positivity condition. In field form, the kernels satisfy the matrix-kernel trade-off

`D1_br D0^+ D1_br^dagger <= 2 D2`

schematically, with the precise statement understood as a positive matrix-kernel inequality.

Therefore nonzero gravitational backreaction cannot coexist with arbitrarily small quantum decoherence and arbitrarily small classical metric diffusion inside this CQ class.

However, this does not yet license transporting laboratory bounds directly into a black-hole regime.

## New result 2 — Scale-Transport Closure gate
To compare the same CQ law in tabletop gravity and evaporating black holes, the theory must supply a lawful map

`R_(mu1,background1 -> mu2,background2): (D0,D1,D2)_1 -> (D0,D1,D2)_2`

that determines how the kernels run/change with scale, curvature, state, background, and coarse-graining.

Acceptance requirements:
1. preserve the theory's probability/positivity conditions on the physical domain;
2. reproduce the weak-field laboratory limit;
3. reproduce the curved-space Hawking/backreaction regime where claimed applicable;
4. forbid arbitrary independent retuning of D0 and D2 between regimes;
5. specify the uncertainty and validity domain of the transport;
6. remain compatible with the same underlying Gamma_*.

Current literature does not yet establish this full transport for matter-coupled strong-field black-hole evolution. The postquantum-classical pure-gravity theory has been argued to be formally renormalisable, but complete positivity after renormalisation remains an open issue in that analysis. Recent stochastic-mode work constrains couplings in linearised Minkowski/FLRW settings, not a complete evaporating-black-hole background.

Classification:

`LAB BOUNDS -> BLACK-HOLE CQ EXCLUSION = NOT YET ESTABLISHED WITHOUT SCALE-TRANSPORT CLOSURE`.

## New result 3 — Black-hole CQ kernel map
Where the Markovian CQ assumptions hold, define stage-dependent kernels

`D0_BH(x,y;t)` = quantum decoherence/Lindblad kernel,

`D1_BH_br(x,y;t)` = matter-to-classical-gravity backreaction/drift kernel,

`D2_BH(x,y;t)` = classical gravitational diffusion/noise kernel.

Hawking evaporation requires nonzero average backreaction during mass loss, so a CQ model of this class cannot consistently set

`D1_BH_br != 0, D0_BH = 0, D2_BH = 0`.

Stochastic-gravity calculations independently show that stress-tensor fluctuations can induce growing metric fluctuations over long evaporation times before the Planck regime. These induced fluctuations are not automatically identical to the fundamental D2 of a postquantum classical-gravity model and must not be conflated.

## New result 4 — Classical trajectory as information record
In saturated CQ dynamics, the quantum state can remain pure conditioned on the complete classical trajectory. This means a stochastic classical gravitational history can in principle act as an information-bearing record correlated with the quantum system.

For black holes this opens a candidate mechanism:

`initial quantum distinctions -> stochastic gravitational trajectory + outgoing quantum state`.

But it is not yet endpoint closure.

## History-to-State Closure gate
A Theory of Everything cannot count information as preserved merely because an omniscient description of the entire past trajectory distinguishes initial states.

At the final epoch, ask whether the trajectory information is encoded in the final physical observable/state structure.

Let `Z_g[0,T]` denote the classical gravitational history and `O_final` the complete physically admissible final observables.

The model must establish a lawful map

`H: Z_g[0,T] -> O_final`

that preserves the initial-state distinctions required for recovery, or explicitly classify the missing history as a physical inaccessible sector.

Possible physical endpoint records include, only if derived by the theory:
- hard radiation correlations;
- gravitational radiation;
- asymptotic soft/memory/charge data;
- residual metric/configuration variables;
- remnant/successor sectors.

If reconstruction requires access to a past trajectory that leaves no final physical record, then path-level distinguishability has not established final-state information closure.

## Stronger CQ black-hole test
For a reference R entangled/correlated with collapsing input B, test simultaneously:

1. CQ positivity/trade-off throughout each stage where the Markovian CQ description is claimed valid;
2. scale transport of D0,D1,D2 from laboratory/weak-field constraints into the black-hole background;
3. reference correlation with outgoing quantum degrees of freedom;
4. reference correlation with the classical gravitational trajectory;
5. whether the trajectory record is encoded in final observables;
6. recovery error from the complete final physical output.

A CQ candidate passes black-hole information closure only if the same Gamma_* that defines its laboratory behavior also provides the scale transport and endpoint record needed for recovery.

## Current status
`VERIFIED / ESTABLISHED WITH STATED ASSUMPTIONS:`
- Markovian CP CQ dynamics obeys a decoherence/backreaction/diffusion trade-off.
- the field-theoretic version is a matrix-kernel positivity condition.
- in saturated CQ trajectories, the conditioned quantum state can remain pure and the classical trajectory can carry correlated record information.
- stochastic-gravity calculations show induced metric fluctuations in evaporating black holes can become important over long evaporation times before Planck curvature.
- postquantum-classical pure gravity has a formal renormalisation result, while preservation of complete positivity under the renormalisation prescription remains open in that work.

`THEORETICAL / PROJECT INFERENCE:`
- Scale-Transport Closure is required before using weak-field CQ bounds as black-hole exclusion bounds.
- History-to-State Closure is required before treating a classical gravitational trajectory as an information-preserving black-hole complement.

`UNKNOWN:`
- the full matter-coupled strong-field running/transport of CQ kernels;
- whether a CQ trajectory record survives as recoverable final gravitational/asymptotic data;
- whether any surviving CQ parameter region can satisfy both laboratory constraints and black-hole recovery;
- whether nature uses CQ, quantum gravity, fundamental nonunitarity, or a deeper framework.

## Source anchors
- Isaac Layton, Jonathan Oppenheim, Zachary Weller-Davies, `A healthier semi-classical dynamics`, Quantum 8, 1565 (2024), arXiv:2208.11722.
- Isaac Layton et al., `Gravitationally induced decoherence vs space-time diffusion: testing the quantum nature of gravity`, Nature Communications 14, 7910 (2023).
- Jonathan Oppenheim, Zachary Weller-Davies, `Covariant path integrals for quantum fields back-reacting on classical space-time`, arXiv:2302.07283; published in PRX in 2026.
- Andrzej Grudka et al., `Renormalisation of postquantum-classical gravity`, arXiv:2402.17844.
- Jonathan Oppenheim, Muhammad Sajjad, `Stochastic modes in postquantum classical gravity`, arXiv:2605.05375 (2026).
- B. L. Hu, Albert Roura, `Metric fluctuations of an evaporating black hole from back reaction of stress tensor fluctuations`, Phys. Rev. D 76, 124018 (2007), arXiv:0708.3046.

## Next GPS
`CQ LAB DECOHERENCE/DIFFUSION BOUND`
`-> SCALE-TRANSPORT CLOSURE` **CURRENT GATE**
`-> BLACK-HOLE D0/D1/D2 KERNEL FLOW`
`-> TRAJECTORY INFORMATION RECORD`
`-> HISTORY-TO-STATE CLOSURE`
`-> COMPLETE FINAL REFERENCE RECOVERY`
`-> CQ SURVIVES OR IS EXCLUDED`
`-> COMPARE SURVIVOR AGAINST QUANTUM-GRAVITY / NONUNITARY CLASSES`
`-> NOVEL DISCRIMINATING PREDICTION`
`-> TOE CLOSURE OR RIGOROUS NON-CLOSURE CLASSIFICATION`
