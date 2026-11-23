module

public import EntropyLean.Statements

/-!
# Proved entropy-quotient results

This module re-exports the seven existing declarations selected by comparator.json.
Their proofs are in EntropyLean.Statements and its dependency closure, including
the pinned PFR proof of the entropic Marton theorem. It does not import Challenge.

The check below fails the build if any selected result transitively uses sorryAx,
Lean.ofReduceBool, or any axiom beyond the three standard permitted axioms.
Comparator additionally checks these proofs against the independent Challenge.
-/

open Lean Elab Command in
run_cmd
  for n in [``EntropyLean.exponential_entropy_quotient,
      ``EntropyLean.sparse_rigidity,
      ``EntropyLean.weighted_family_rigidity,
      ``EntropyLean.exponential_scale_necessary,
      ``EntropyLean.two_input_almost_additivity,
      ``EntropyLean.coset_concentration,
      ``EntropyLean.exists_large_coset] do
    for a in (← collectAxioms n) do
      unless [``propext, ``Classical.choice, ``Quot.sound].contains a do
        throwError "Palomar result {n} depends on the forbidden axiom {a}"
