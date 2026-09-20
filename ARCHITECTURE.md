# Architecture

How the seven packages fit together, what flows between them, and why the boundaries are where they are.

## The shape of it

```
                    ┌──────────────────────────────────────────────────────┐
  cable sample ────▶│  B · labauto                                         │
  instruments       │  barcode → procedure → calibration gate → measure    │
                    │  → validate → seal archive → analyse → database      │
                    └───────────────┬──────────────────────┬───────────────┘
                                    │  sealed archives     │  raw S-parameters
                                    ▼                      ▼
                    ┌──────────────────────────┐   ┌──────────────────────┐
                    │  F · labplatform         │   │  D · zprofile        │
                    │  uncertainty budgets     │   │  impedance vs        │
                    │  site comparison, drift  │   │  position            │
                    └───────────────┬──────────┘   └──────────┬───────────┘
                                    │                         │
  extrusion-line ──▶ ┌──────────────────────────┐             │
  records            │  E · cableanalytics      │             │
                     │  production → performance│             │
                     └───────────────┬──────────┘             │
                                     │                        │
                                     ▼                        ▼
                     ┌────────────────────────────────────────────────┐
                     │  G · linktwin                                  │
                     │  cable + connectors + PHY → verdict, eye,      │
                     │  reach, connector budget, P(pass)              │
                     └────────────────────────────────────────────────┘

  shield ──────────▶ ┌──────────────────────────┐
  measurements       │  C · shieldeval          │   independent of the main chain
                     │  legacy + modern method  │
                     └──────────────────────────┘

  ══════════════════════════════════════════════════════════════════════════
   A · cablecheck — the foundation every package above is built on:
   Touchstone I/O · network algebra · fixture de-embedding · mixed-mode
   decomposition · standards limit lines · quantities · verdicts
  ══════════════════════════════════════════════════════════════════════════
```

## Dependencies

| package | requires | optionally uses |
|---|---|---|
| `cablecheck` | — | — |
| `shieldeval` | — | — |
| `zprofile` | `cablecheck` | — |
| `cableanalytics` | `cablecheck` | — |
| `labauto` | `cablecheck` | `zprofile`, `cableanalytics` |
| `labplatform` | `cablecheck`, `labauto` | — |
| `linktwin` | `cablecheck` | `labauto`, `cableanalytics` |

Optional dependencies are genuinely optional: `labauto` runs its analysis with `cablecheck` alone and
adds the impedance profile and loss analytics when those packages are present; `linktwin` reads a
cable from a Touchstone file without `labauto`, and from a production record only when
`cableanalytics` is installed.

## What actually flows

**`labauto` → `labplatform`.** Sealed job directories. Each carries the raw Touchstone file, a
sidecar with the sample, procedure hash, instrument identity, calibration record, fixture method,
environment, validation checks and trust decision, plus a manifest of SHA-256 hashes. `labplatform`
ingests these — including the jobs that were *refused* at a gate, because a network that cannot see
its refusal rate cannot manage it.

**`labauto` → `zprofile` / `cableanalytics`.** Called as analysers on the measured network, in
process, with the results written into the job's analysis directory and the laboratory database.

**`cableanalytics` → `linktwin`.** Predicted loss coefficients `a`, `b` and impedance `Z` with 90 %
prediction intervals, for a cable that has never been measured. The twin turns the interval
half-widths into the relative standard uncertainties its Monte Carlo draws from.

**`labauto` → `linktwin`.** A job directory used directly as a cable source: the measured length,
sample temperature, fixture method, trust decision, calibration record and raw-file hash all come
from the sidecar, and the manifest is verified before the file is used.

**`cablecheck` → everything.** Not a data flow but an API. The same `Network` type, the same
mixed-mode transform, the same limit library and the same evaluator are used by every package, which
is why a verdict from `linktwin` on a harness that does not exist is directly comparable to a verdict
from `cablecheck` on one that does.

## Why these boundaries

**The foundation is a library, not a service.** `cablecheck` has no state and no I/O beyond reading
and writing files. Everything above it can be tested without it running anywhere.

**Trust is a separate layer from measurement.** `labauto` decides whether *this* measurement is
sound. `labplatform` decides whether *this laboratory* is sound. Those are different questions on
different timescales, and conflating them is how drift goes unnoticed for months.

**Prediction is separate from evaluation.** `linktwin` composes elements and hands the result to
`cablecheck`'s evaluator rather than reimplementing the limits. A change to a standard is a change in
one file, and every package picks it up.

**`shieldeval` is deliberately isolated.** It answers a different question with different physics and
shares no code path with the main chain. Coupling it in would have bought nothing.
