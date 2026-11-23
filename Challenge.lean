module

public import Mathlib

@[expose] public section

/-!
# Dimension-free exponential entropy quotients over F₂

This is the independently auditable statement of record for seven results from
Josiah Park, arXiv:2610.38525v1 (28 October 2026): Theorems 1.1, 1.2, 8.2,
Proposition 9.3, Corollary 9.2, and both assertions of Corollary 9.4.

All entropies are Shannon entropies in bits. The ambient space is any finite
vector space over F₂; independent sums are encoded by convolution of probability
mass functions. No independence of coordinates is assumed. The numerical constant
320 is not asserted to be optimal. Proposition 9.3 uses the eventual lower-bound
form of the liminf assertion, avoiding the real-valued liminf of an unbounded
function. Novelty has not been independently established by this submission.

The definitions below are explicit copies of the ordinary definitions used in
the proof library. This file imports only Mathlib, never EntropyLean or PFR.
The seven `sorry` proofs are intentional Challenge placeholders. Solution.lean
re-exports the actual proofs; Comparator must check their statements and axiom
closures. There are no definition holes. The external entropic Marton theorem
is proved by the pinned PFR dependency, not assumed as an additional axiom.
-/

namespace EntropyLean

open scoped BigOperators
open Filter

/-- Finite-dimensional vector space over F₂. -/
abbrev F2Vec (m : ℕ) := Fin m → ZMod 2

/-- Shannon entropy in bits, `H(P) = -∑ p(a) log₂ p(a)`, with `0 log 0 = 0`
(Mathlib's `Real.logb 2 0 = 0`). -/
noncomputable def entropyBits {α : Type*} (P : PMF α) : ℝ :=
  ∑' a, -(P a).toReal * Real.logb 2 (P a).toReal

/-- Law of `A + B` for independent `A ∼ P`, `B ∼ Q`. -/
noncomputable def conv {V : Type*} [Add V] (P Q : PMF V) : PMF V :=
  P.bind fun a => Q.map fun b => a + b

/-- Entropy increment `D(X) = H(X + X') - H(X)`. -/
noncomputable def entropyIncrement {V : Type*} [Add V] (P : PMF V) : ℝ :=
  entropyBits (conv P P) - entropyBits P

/-- Entropy defect `E(X) = 2H(X) - H(X + X')`. -/
noncomputable def entropyDefect {V : Type*} [Add V] (P : PMF V) : ℝ :=
  2 * entropyBits P - entropyBits (conv P P)

/-- Interaction `s(P, Q) = H(P) + H(Q) - H(P * Q)` (equation (8)). -/
noncomputable def interaction {V : Type*} [Add V] (P Q : PMF V) : ℝ :=
  entropyBits P + entropyBits Q - entropyBits (conv P Q)

/-- Subspace defect `F_P(W) = H(P) - H(q_W P)` (equation (10)); for `A ∼ P` this is
`H(A | q_W A)`. -/
noncomputable def quotientLoss {V : Type*} [AddCommGroup V] [Module (ZMod 2) V]
    (P : PMF V) (W : Submodule (ZMod 2) V) : ℝ :=
  entropyBits P - entropyBits (P.map fun v => W.mkQ v)

/-- λ-sparsity of a single law (equation (6)): `H(Z | q_W Z) ≤ λ dim W` for every `W`. -/
def IsSparse {V : Type*} [AddCommGroup V] [Module (ZMod 2) V]
    (lam : ℝ) (P : PMF V) : Prop :=
  ∀ W : Submodule (ZMod 2) V, quotientLoss P W ≤ lam * (Module.finrank (ZMod 2) W : ℝ)

/-- A finite weighted family of laws on `V`. -/
structure WeightedFamily (V : Type*) where
  index : Type
  [indexFintype : Fintype index]
  laws : index → PMF V
  weights : index → ℝ
  weights_pos : ∀ i, 0 < weights i
  weights_sum : ∑ i, weights i = 1

attribute [instance] WeightedFamily.indexFintype

namespace WeightedFamily

variable {V : Type*}

/-- Mean component entropy `h(𝒫) = ∑ a_i H(P_i)`. -/
noncomputable def meanEntropy (P : WeightedFamily V) : ℝ :=
  ∑ i, P.weights i * entropyBits (P.laws i)

/-- Mean interaction `e(𝒫) = ∑ a_i a_j s(P_i, P_j)`. -/
noncomputable def meanInteraction [Add V] (P : WeightedFamily V) : ℝ :=
  ∑ i, ∑ j, P.weights i * P.weights j * interaction (P.laws i) (P.laws j)

/-- Averaged subspace defect `F_𝒫(W) = ∑ a_i F_{P_i}(W)`. -/
noncomputable def averagedLoss [AddCommGroup V] [Module (ZMod 2) V]
    (P : WeightedFamily V) (W : Submodule (ZMod 2) V) : ℝ :=
  ∑ i, P.weights i * quotientLoss (P.laws i) W

/-- Averaged λ-sparsity (equation (13)). -/
def IsSparse [AddCommGroup V] [Module (ZMod 2) V] (lam : ℝ) (P : WeightedFamily V) : Prop :=
  ∀ W : Submodule (ZMod 2) V, P.averagedLoss W ≤ lam * (Module.finrank (ZMod 2) W : ℝ)

end WeightedFamily

/-- **Theorem 1.1** (exponential entropy quotient), equations (2)–(3).
`H(q_G X) ≤ (1+ε) D(q_G X) ≤ (1+ε) D(X)`; the second inequality is stated as
`D(q_G X) ≤ D(X)`. -/
theorem exponential_entropy_quotient
    {V : Type*} [AddCommGroup V] [Module (ZMod 2) V] [Fintype V]
    (ε : ℝ) (hε : 0 < ε) (X : PMF V) :
    ∃ G : Submodule (ZMod 2) V,
      (Module.finrank (ZMod 2) G : ℝ) ≤ (2 : ℝ) ^ (320 * (1 + ε) / ε) * entropyBits X ∧
      entropyBits (X.map fun v => G.mkQ v) ≤
        (1 + ε) * entropyIncrement (X.map fun v => G.mkQ v) ∧
      entropyIncrement (X.map fun v => G.mkQ v) ≤ entropyIncrement X := by
  sorry

/-- **Theorem 1.2** (sparse-law rigidity), equation (7). -/
theorem sparse_rigidity
    {V : Type*} [AddCommGroup V] [Module (ZMod 2) V] [Fintype V]
    (lam : ℝ) (hlam : 0 < lam ∧ lam < 1) (Z : PMF V)
    (hsparse : IsSparse lam Z) (hpos : 0 < entropyBits Z) :
    entropyDefect Z / entropyBits Z ≤ min 1 (320 / Real.logb 2 (1 / lam)) := by
  sorry

/-- **Theorem 8.2** (weighted-family logarithmic rigidity). -/
theorem weighted_family_rigidity
    {V : Type*} [AddCommGroup V] [Module (ZMod 2) V] [Fintype V]
    (lam : ℝ) (hlam : 0 < lam ∧ lam < 1) (P : WeightedFamily V)
    (hsparse : P.IsSparse lam) (hpos : 0 < P.meanEntropy) :
    P.meanInteraction / P.meanEntropy ≤ min 1 (320 / Real.logb 2 (1 / lam)) := by
  sorry

/-- **Proposition 9.3** (exponential scale is necessary). If `C ε` is valid for every law on
every `F₂^m` in the original-input form `dim G ≤ C(ε) H(X)`, `H(q_G X) ≤ (1+ε) D(X)`, then
`liminf_{ε↓0} ε log₂ C(ε) ≥ 2`, stated without `liminf` as: for every `c < 2`, eventually
`c ≤ ε log₂ C(ε)` (this avoids `liminf`'s junk value for functions unbounded above). -/
theorem exponential_scale_necessary (C : ℝ → ℝ)
    (hC : ∀ ε > 0, ∀ (m : ℕ) (X : PMF (F2Vec m)), ∃ G : Submodule (ZMod 2) (F2Vec m),
      (Module.finrank (ZMod 2) G : ℝ) ≤ C ε * entropyBits X ∧
      entropyBits (X.map fun v => G.mkQ v) ≤ (1 + ε) * entropyIncrement X) :
    ∀ c : ℝ, c < 2 → ∀ᶠ ε in nhdsWithin (0 : ℝ) (Set.Ioi 0), c ≤ ε * Real.logb 2 (C ε) := by
  sorry

/-- **Corollary 9.2** (two-input almost-additivity), with no hypothesis: (45), (46), the additive
error `s(q_G U, q_G Y) ≤ α(H(U) + H(Y))` and both mixed-input bounds. -/
theorem two_input_almost_additivity {V : Type*} [AddCommGroup V] [Module (ZMod 2) V]
    [Fintype V] (α : ℝ) (hα : 0 < α ∧ α < 1) (U Y : PMF V) :
    ∃ G : Submodule (ZMod 2) V,
      (Module.finrank (ZMod 2) G : ℝ) ≤
        (2 : ℝ) ^ (320 / α) * ((entropyBits U + entropyBits Y) / 2) ∧
      (1 - α) * (entropyBits (U.map fun v => G.mkQ v) + entropyBits (Y.map fun v => G.mkQ v)) ≤
        entropyBits (conv (U.map fun v => G.mkQ v) (Y.map fun v => G.mkQ v)) ∧
      interaction (U.map fun v => G.mkQ v) (Y.map fun v => G.mkQ v) ≤
        α * (entropyBits U + entropyBits Y) ∧
      entropyBits (U.map fun v => G.mkQ v) ≤ entropyBits (conv U Y) - entropyBits Y +
        α * (entropyBits (U.map fun v => G.mkQ v) + entropyBits (Y.map fun v => G.mkQ v)) ∧
      entropyBits (Y.map fun v => G.mkQ v) ≤ entropyBits (conv U Y) - entropyBits U +
        α * (entropyBits (U.map fun v => G.mkQ v) + entropyBits (Y.map fun v => G.mkQ v)) := by
  sorry

open Classical in
open scoped Pointwise in
/-- **Corollary 9.4** (subspace-coset concentration), with no hypothesis: for `0 < α < η ≤ 1` and
nonempty `A` with `|A + A| ≤ |A|^(2−η)` there is a subspace `G` with
`dim G ≤ 2^(320/α) log₂ |A|` on whose cosets `A` concentrates. -/
theorem coset_concentration {V : Type*} [AddCommGroup V] [Module (ZMod 2) V] [Fintype V]
    [DecidableEq V] {α η : ℝ} (hα : 0 < α)
    (hαη : α < η) (hη : η ≤ 1) (A : Finset V) (hA : A.Nonempty)
    (hAA : ((A + A).card : ℝ) ≤ (A.card : ℝ) ^ (2 - η)) :
    ∃ G : Submodule (ZMod 2) V,
      (Module.finrank (ZMod 2) G : ℝ) ≤ (2 : ℝ) ^ ((320 : ℝ) / α) * Real.logb 2 (A.card : ℝ) ∧
      (η - α) / (1 - α) * Real.logb 2 (A.card : ℝ) ≤
        1 / (A.card : ℝ) * ∑ a ∈ A, Real.logb 2 ((A.filter fun b => b - a ∈ G).card : ℝ) := by
  sorry

open Classical in
open scoped Pointwise in
/-- **Corollary 9.4, last assertion**, with no hypothesis: some coset of `G` meets `A` in at least
`|A|^(η−α)` points. -/
theorem exists_large_coset {V : Type*} [AddCommGroup V] [Module (ZMod 2) V] [Fintype V]
    [DecidableEq V] {α η : ℝ} (hα : 0 < α)
    (hαη : α < η) (hη : η ≤ 1) (A : Finset V) (hA : A.Nonempty)
    (hAA : ((A + A).card : ℝ) ≤ (A.card : ℝ) ^ (2 - η)) :
    ∃ G : Submodule (ZMod 2) V,
      (Module.finrank (ZMod 2) G : ℝ) ≤ (2 : ℝ) ^ ((320 : ℝ) / α) * Real.logb 2 (A.card : ℝ) ∧
      ∃ a ∈ A, (A.card : ℝ) ^ (η - α) ≤ ((A.filter fun b => b - a ∈ G).card : ℝ) := by
  sorry

end EntropyLean
