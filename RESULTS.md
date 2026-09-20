# Validation results

Every package in this toolchain is checked against something independent: a closed-form result, a
reciprocal transform, a synthetic case whose ground truth is known exactly, or a published reference
value. This file collects what each one demonstrates. All numbers are reproducible by running the
command shown.

---

## A · cablecheck — measurement to verdict

| check | result |
|---|---|
| Touchstone round trip | read → write → read is bit-exact for v1 and v2, any port count, MA/DB/RI |
| Network identities | passivity and reciprocity hold to < 1e-9 on every synthesised network |
| De-embedding | exact T-matrix removal recovers the known DUT to < 1e-9; 2x-thru bisection to < 0.02 dB |
| Mixed-mode transform | matches the analytic differential/common decomposition of a symmetric pair |
| Regression | a frozen reference set of expected verdicts and margins, refreshed only with a stated reason |

`cablecheck demo demo_a` · **40 tests** · [report](reports/cablecheck.pdf)

---

## B · labauto — the laboratory as a system

| check | result |
|---|---|
| Gates | a job with a stale calibration, an out-of-tolerance verification or an unmet environment condition is refused before it measures |
| Validation | grid, passivity, reciprocity, trace noise, connection, length against the registry, loss against DC resistance, far-end termination |
| Trust decision | each job resolves to trusted / flagged / rejected, with the reasons recorded |
| Archive replay | a sealed job directory re-analysed six months later reproduces the sealed result exactly; manifest hashes verify |
| Barcodes | GS1-128 with GTIN check digit and an internal scheme with a mod-36 check character, both round-tripped |

`labauto demo demo_b` · **25 tests** · [report](reports/labauto.pdf)

---

## C · shieldeval — legacy reconstruction

| check | result |
|---|---|
| Compatibility mode | **byte-identical** output against every archived legacy result |
| Quirk register | nine documented behaviours (Q1–Q9) of the legacy method, each reproduced deliberately and each with a test |
| Modern method | agrees with analytic transfer-impedance physics for a single braid across the band |
| Migration cost | the difference between legacy and modern is reported per fixture and per frequency, so replacing the old tool is a number rather than an argument |

`shieldeval demo demo_c` · **13 tests** · [report](reports/shieldeval.pdf)

---

## D · zprofile — impedance against position

| check | result |
|---|---|
| Bias of the plain transform | **+4 to +9 Ω** over a 15 m automotive pair — the √t rise of a lossy line, which a real TDR instrument shows too |
| Loss-aware reconstruction | brings that to **within a few tenths of an ohm** on the same cables |
| Reference set | five synthetic cables — uniform, sectioned, ripple + defect, thin lossy, short defect — with profiles known exactly |
| Feature extraction | ripple period and amplitude, and defect position, depth and extent, read correctly once the bandwidth resolves them |
| Sensitivity budget | the shift in every reported statistic is quantified for each processing choice |

`zprofile demo demo_d` · **14 tests** · [report](reports/zprofile.pdf)

---

## E · cableanalytics — production to physics

| check | result |
|---|---|
| Loss fit | the physical basis `c/√f + a√f + b·f` separates conductor, dielectric and DC-resistance contributions, with parameter covariance |
| Derating | material coefficients fitted across a temperature sweep, each point weighted by its fit uncertainty |
| Prediction | design physics, then a ridge-regularised correction, cross-validated against held-out samples with a boosted-tree comparison |
| Intervals | 90 % prediction intervals on the loss coefficients and impedance, from the residual quantiles |

`cableanalytics demo demo_e` · **14 tests** · [report](reports/cableanalytics.pdf)

---

## F · labplatform — multi-site trust

Simulated network: four sites (Roth, Kitzingen, Jelenia Góra, Changzhou), ten fortnightly rounds,
200 measurement runs, 3,610 results, 40 calibrations, 48 verifications.

Insertion loss at 600 MHz on the circulating artefact, against a Cox largest-consistent-subset
consensus of **7.9149 dB**:

| site | value | U (k=2) | E_n | status |
|---|---|---|---|---|
| 1 · Roth *(reference)* | 7.9071 dB | 0.047 | −0.22 | compatible |
| 2 · Kitzingen | 7.9180 dB | 0.080 | +0.04 | compatible |
| 3 · Jelenia Góra | 7.9193 dB | 0.063 | +0.08 | compatible |
| 4 · Changzhou | 7.9231 dB | 0.065 | +0.14 | compatible |

| check | result |
|---|---|
| Uncertainty budgets | every result carries repeatability, reproducibility, calibration, fixture, instrument, environment, noise and resolution, combined per the GUM |
| Compatibility | a difference is only called a problem when it exceeds the expanded uncertainty *of the difference*, not of the value |
| Drift | a site whose test cable degrades is caught on its verification chart **three rounds before the gate refuses to measure** |
| Traceability | the five results taken under the last calibration before a failed verification are identified as suspect |
| Statistics | ISO 5725-2 nested ANOVA, Cochran and Grubbs screening, Shewhart + EWMA charts with Western Electric rules |

`labplatform demo demo_f` · **16 tests** · [report](reports/labplatform.pdf)

---

## G · linktwin — the digital twin

The twin is built from **one noisy 10 m measurement at 23 °C** and then asked about cables it has
never seen. Ground truth is the synthesiser, which the twin has no access to.

| prediction | error against ground truth |
|---|---|
| Insertion loss, 3 m to 25 m, 23 °C to 125 °C | **≤ 0.1 dB** over 5–600 MHz (0.09 dB at the 25 m / 125 °C corner, of 16.7 dB) |
| Extrapolation to 2.5 GHz (an octave past the measured band) | **≤ 0.04 dB** |
| Whole-harness verdict vs a harness built from true pieces | same verdict, headline margin within **0.002 dB** |
| Worst-case eye vs bit-level simulation, 5 m | **420 mV** bound against **421 mV** simulated |
| Worst-case eye vs bit-level simulation, 15 m | **311 mV** bound against **311 mV** simulated |

Declared limitations: the impedance *pattern* of a different physical piece is not predictable (the
twin carries the measured piece's structure, and its return-loss minima land within about 3 dB);
equalisation is ideal, so the eye is an upper bound on what an implementation achieves.

`linktwin demo demo_g` · **21 tests** · [report](reports/linktwin.pdf)

---

## Reproducing all of it

```sh
./scripts/install-all.sh
./scripts/run-all-demos.sh out
```

Roughly 25 minutes on a laptop. Every figure in every report and on the
[site](https://anilram30.github.io) is regenerated.
