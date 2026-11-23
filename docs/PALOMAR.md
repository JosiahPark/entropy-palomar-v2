# Palomar submission

This update prepares the substantive `JosiahPark/entropy-quotients-lean`
development for the [Palomar submission form](https://submit.palomar-registry.org/).
It is based on source commit `83216fe940b2d917875a3001a0394e296fcbf2d7`.
The submitted commit must include this update; the base commit is not ready.

## Registered statement selection

One configuration, `comparator.json`, selects these seven existing declarations.
All names below have the prefix `EntropyLean.`.

| Source result | Declaration | Content |
| --- | --- | --- |
| Theorem 1.1 | `exponential_entropy_quotient` | An entropy-sized subspace gives the intrinsic quotient-increment bound with coefficient `2^(320(1+ε)/ε)`. |
| Theorem 1.2 | `sparse_rigidity` | A sparse law with positive entropy has defect ratio at most `min 1 (320/log₂(1/λ))`. |
| Theorem 8.2 | `weighted_family_rigidity` | The same logarithmic rigidity estimate holds for averaged sparsity of finite weighted families. |
| Proposition 9.3 | `exponential_scale_necessary` | Every universally valid coefficient in the original-input formulation obeys the eventual lower bound corresponding to `liminf ε log₂ C(ε) ≥ 2`. |
| Corollary 9.2 | `two_input_almost_additivity` | Two laws admit a common quotient with almost-additive entropy and the two mixed-input estimates. |
| Corollary 9.4 | `coset_concentration` | A moderate-doubling set has an averaged concentration estimate on cosets of a bounded-dimensional subspace. |
| Corollary 9.4 | `exists_large_coset` | Some coset of a bounded-dimensional subspace has the stated large intersection. |

`Challenge.lean` is a short independent statement file. It imports only canonical
Mathlib and states the ordinary entropy, convolution, quotient-loss, and weighted
family definitions explicitly. Definitions have values; there are no definition
holes. Its seven `sorry` proofs are intentional and confined to the statement
side of the comparison.

`Solution.lean` re-exports the actual declarations from `EntropyLean.Statements`.
It never imports Challenge, and it fails compilation if any of the seven results
transitively uses an axiom other than `propext`, `Classical.choice`, or `Quot.sound`.
Comparator must additionally verify that the selected types and their definition
closures agree with Challenge and replay their proofs through the kernels.

## Mathematical scope and provenance

The primary source is Josiah Park, *Dimension-free exponential entropy quotients
over F₂*, [arXiv:2610.38525v1](https://arxiv.org/abs/2610.38525v1), included at
`paper/2610.38525v1.pdf`. Its coefficients and hypotheses are retained. Finite
F₂-modules generalize a chosen coordinate space. Weighted-family indices live in
`Type`. The lower-bound statement uses an eventual inequality rather than a
real-valued `liminf`, whose convention for unbounded functions is unsuitable here.

The two Corollary 9.4 declarations have separately existentially quantified
subspaces. This configuration does not claim a single conjunction with the same
witness for both statements. No optimality of 320, efficient algorithm for finding
the quotient, extension to other groups, or independently established novelty is
claimed. Supporting lemmas and stronger constants elsewhere in the library are
not extra claims selected by this Comparator configuration.

The entropic Marton input is a proved dependency, not an additional axiom.
`EntropyLean.PFRBridge` translates the pinned PFR theorem
`entropic_PFR_conjecture_improv` from random variables and nats to PMFs and bits,
then weakens its one-variable constant 5 to the paper's 6. The PFR project's
contributors and Jyun-Jie Liao's improved argument are credited in
`formalization.yaml`. The Mathlib and PFR revisions remain unchanged.

Josiah Park is the sole human author and responsible maintainer. The MIT license
was selected for this update. Cited sources and external dependencies retain
their own terms. `formalization.yaml` separately records the documented roles of
Claude, Grok, OpenAI tools, and this packaging session. AI assistance and existing
build reports are not independent human peer review.

## Unselected drafts and source migration

The repository retains the historical drafts rather than concealing them. There
are 47 source-token `sorry` occurrences outside Challenge: 2 in the unrelated
`EntropyLean/FeatureMap.lean` stub, 39 in `archive/`, and 6 in
`missing/DraftLeftovers.lean`. The conservative metadata count includes all of
them. These are separate from the seven selected results' transitive proof
closures. Archive and missing files are not build targets; their contents are
not claimed to be compilable proofs. The numerical scripts are diagnostic only.

Palomar checks source headers even in unused files. Every existing source now
uses `module`; former public declarations/imports are preserved through
`public import` and `@[expose] public section`. Module documentation that preceded
imports was moved after the header. The original draft mathematics is retained.
No file exceeds 10,000 physical lines. Challenge is below both the 300-line
warning threshold and the 1,000-line/100-KiB hard limits.

## Local validation

The package was checked against PalomarPolicy commit
`28bd48b9b71bbb2a82c718ce761d5a4220ef8e60` and PalomarSubmission commit
`14aa8d6b3c2f14a8540605e37144560b9a00e7e7`.

- Palomar's own source scanner: passed for all 82 Lean files.
- Lean 4.35.0 `--deps-json` header parsing: passed for all 82 files.
- Palomar's own metadata validator and upstream v0.4 JSON schema: passed.
- Palomar's own Comparator configuration validator: passed, seven theorems.
- All 12 dependency revisions are full immutable SHAs; Mathlib's resolved
  toolchain agrees exactly with the project toolchain.
- `lake build`: passed, 9,168 jobs including cached dependencies. The seven
  intentional Challenge placeholders and two unrelated FeatureMap placeholders
  produce expected warnings; other style/deprecation warnings are non-fatal.
- `Solution` compiled with the transitive axiom guard for every selected theorem.
- `lake build +Main`: passed, 9,148 jobs including cached dependencies.
- Full Comparator / NanoDa verification: **not completed locally**. Bubblewrap
  stopped before the isolated Challenge build with
  `Failed to create NETLINK_ROUTE socket: Operation not permitted` in this
  execution environment. The sandbox was not disabled. A subsequent standalone
  proof-export attempt did not produce a verified comparison or kernel-replay
  result. No Comparator, NanoDa, or Palomar mechanical pass is claimed.

The ordinary Lean build and selected-result axiom checks passed. Submission
eligibility remains conditional on a successful official full preflight for the
exact public commit, as described below.

To reproduce the ordinary build, with the pinned Lean toolchain installed:

```sh
lake exe cache get
lake build
lake build +Main
```

For an additional local Comparator check on a system supporting bubblewrap:

```sh
PATH="$(lean --print-prefix)/bin:$PATH" lake comparator --config comparator.json
```

The local configuration requests NanoDa replay as well as Lean's kernel.
That command alone does not constitute Palomar's complete verification. The
registry adds its protected kernel configuration, isolated Challenge dependency checks,
license detection, source preservation checks, and resource accounting. Use the
official full workflow below for the submission gate.

## Full preflight and intake

1. Commit and push the update to the public repository. Make the workflow
   available on the default branch, then select the exact ref to test in Actions.
2. Run **Palomar full preflight**. Select the truthful authorization relationship;
   repository write access alone does not establish authorship or approval.
3. The workflow calls the official reusable verifier with `mode: full` and
   `execution_profile: palomar-standard-v1`. Both the workflow reference and
   `pipeline_commit` are pinned to the same full revision. It checks the run's
   `github.sha`, not a moving branch tip.
4. Require the resulting `mechanical-report.json` to say `status: pass` for that
   exact repository, commit, and `comparator.json`. A successful source scan,
   local build, or standalone Comparator run does not replace this report.
5. Check the repository's active registrations at
   `https://data.palomar-registry.org/repositories/josiahpark/entropy-quotients-lean.json`.
   If the same registration identity exists, follow Palomar's versioning rules;
   do not resubmit an already registered commit as a new result.
6. Submit the exact passing commit at the form. Use repository
   `JosiahPark/entropy-quotients-lean`, configuration `comparator.json`, the root
   project, and root `formalization.yaml`. Review the displayed abstract and
   authorization declaration.
7. Review Palomar's private editorial result before deciding whether to register.
   Registration publishes the record and review and is intended to be permanent.

An agent using the API must first follow the current
[`llms.txt`](https://submit.palomar-registry.org/llms.txt), including the repository
tag and secret-gist proof of access. Do not begin intake until the passing commit
and the submitter's authorization declaration are ready. This update does not
perform intake or registration.
