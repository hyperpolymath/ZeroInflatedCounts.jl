<!--
SPDX-License-Identifier: MPL-2.0
SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

# You are in the hyperpolymath estate — orient before acting

If you are unsure what something is, **read the canon; do not guess** (guessing is how the fake `lith` monorepo got fabricated). Start here, then the files named below.

## Doctrine (the rules here)
1. **Holes before anything else** — fix soundness holes before features/perf/docs.
2. **Fixes first, on firm foundations** — ground-truth by running the tool, not trusting status docs.
3. **Fail loudly, seal soundly** — no silent green; seams (ABI/FFI) sealed & proven.
4. **Distrust the neural for exactness** — licences/invariants/equivalence belong to **PLASMA** (formal), not to an LLM. Your edits there are provisional + supervised.
5. **Squabble, don't bypass** — reach green by *satisfying* the gate, never by admin-override.
6. **No automated licence edits — ever** — manual, owner-only; third-party untouchable.
7. **No deletion by access-recency** — cold ≠ disposable.
8. **Wire first** — unwired is not done.
9. **Always sign** commits (`id_ed25519_signing`; verify `status:G`).
10. **Report faithfully — no overclaim** (the AFFIRMATION ethos).
11. **Stop-first** when an action is costly to undo or outward-facing.
12. **Boundaries are real** — respect IS / IS-NOT; never assimilate or rename across them.
13. **Equivalence as identity** — the estate's intellectual through-line.
14. **Solutions at source** — fix the canonical/upstream origin, never patch the downstream symptom; trace and respect every up- and down-stream before you act.
15. **Elegance by default** — treat the most elegant and correct long-term option as the default arm; when you put a choice to the owner, LABEL which option that is, and if you recommend another, name both arms and say why you depart. Binds unasked design calls too: report the departure, never absorb it.

## Where the facts are (read in this order on arrival)

| File | Answers |
|---|---|
| `ZeroInflatedCounts.jl_chora.deed` | The repo deed — the single machine-readable record: identity, clade, lineage, status (phase), maturity, meta, ecosystem (IS / IS-NOT, chain, relations), and agent permissions. Grammar: `hyperpolymath/standards` `1-formats/deed/spec/abnf/deed.abnf`. |
| `.machine_readable/descriptiles/provisioning_praxis.deed` | How the toolchain is provisioned (`just setup`, `just doctor`). |
| `.machine_readable/self-validating/*.k9.ncl` | k9 validation contracts. Kennel (data) / Yard (pure eval) / Hunt (guarded exec). |
| `docs/status/ROADMAP.adoc` | Milestones, what is done, next actions. |
| `docs/method-conditions/zero-inflation-and-hurdle.adoc` | The specification every implementation must meet. |

## Canon pointers
- `hyperpolymath/standards` — the canon source (DEED and k9 grammars). · `hyperpolymath/gv-clade-index` — the estate map (identity registry). · `hyperpolymath/manifesto` — this doctrine.
- **Before you invent, rename, or consolidate anything: STOP and check the map + IS-NOT.**

## Estate language policy
Deny: **Nix, Python, Go, TypeScript, Deno, ReScript, AGPL**. (Guix, not Nix.)
JavaScript tooling: **Bun**, in plain JavaScript.

---

# This repo: `ZeroInflatedCounts.jl`

- **IS** — Hurdle and zero-inflated negative binomial models for sequencing count data: R `pscl` in production, a Julia likelihood oracle in tests, and Agda proofs of the model identities.
- **IS-NOT** — an implementation yet (only the method-conditions specification exists) · a replacement for MetaManifold-WebUI's NB GLM differential abundance (that stays the method of record; these are alternative fits shown beside it) · an occupancy model (single-visit occupancy is not identifiable; a replicate-only design is planned separately) · a Julia reimplementation of `pscl` for production use (the Julia likelihood is a test oracle only).
- **Where it sits** — a library; consumed by MetaManifold-WebUI through a thin adapter (route, panel, keys in the `differential` section of `config/defaults/pipeline.yml`, dependency pinned by commit).
- **Clade** — `dx` (Developer Ecosystem), like the other Julia libraries in the registry.
- **Constraints here** — fail-closed; evidence per step; no silent skip; rerun after a fix; a release claim requires a hard pass. Never: banned languages (above), secrets, state files in the repo root, AGPL.
- **Golden path** — `just test && just quality`.
- **State** — phase incubating; maturity experimental. See `docs/status/ROADMAP.adoc`.
