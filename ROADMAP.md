# Roadmap

The toolchain was built bottom up, in four phases. Nothing here could have been built in a different
order: each phase needed the one before it to exist first, and the digital twin at the end is only
possible because the measurement layer underneath it is trustworthy.

---

## Phase 1 — Foundation and core algorithms

**`cablecheck` · `zprofile` · `shieldeval`**

The measurement layer has to exist before anything else can. `cablecheck` is the foundation every
later package imports: Touchstone I/O, network algebra, fixture de-embedding, mixed-mode
decomposition, the standards limit library, and the evaluation that turns a measurement into a
verdict with a margin.

Two algorithm projects sit beside it. `zprofile` inverts a frequency-domain reflection into
impedance along the cable, which is what turns "this cable is out of spec" into "there is a defect
at 11.4 m". `shieldeval` is the one project that answers a different question entirely — how to
replace a legacy tool nobody fully understands without invalidating a decade of existing results.

*Delivered: the ability to measure a cable and defend the number.*

---

## Phase 2 — Production analytics

**`cableanalytics`**

A cable's electrical performance is decided on the extrusion line, hours before anybody measures it.
This phase fits the physical loss model to measurements, derives how performance derates with
temperature, and correlates manufacturing parameters against the resulting high-frequency behaviour —
producing a model that predicts loss and impedance, with honest prediction intervals, from a
production record alone.

*Delivered: the ability to say something about a cable before it is measured.*

---

## Phase 3 — Laboratory automation and the trust layer

**`labauto` · `labplatform`**

`labauto` turns the laboratory into a programmable system that understands what measurement is being
performed, refuses to measure when the calibration is stale, validates what comes back, and seals the
whole chain into an archive that reproduces six months later.

`labplatform` then sits above any number of such laboratories. It gives every result a full
uncertainty budget, runs the interlaboratory comparison, estimates repeatability and reproducibility,
keeps control charts, detects drift over months and attributes it to the cause.

*Delivered: the ability to trust a measurement, and to prove several laboratories agree.*

---

## Phase 4 — Predictive digital twin

**`linktwin`**

Everything above exists so that this can work. The twin assembles a virtual link from a measured
cable, an archived laboratory job, or a cable that exists only as a production record, adds connector
and PCB models, and answers the questions that actually decide a harness design: does it pass at
85 °C and at 125 °C, how far can the cable be stretched, how many connectors can it take, what does
the eye look like at the receiver, and — given the tolerances — what is the probability it passes.

*Delivered: a design decision, before the hardware exists.*

---

## What would come next

These are the honest gaps, in the order I would close them.

**Real measurement data.** Everything is synthetic today, which makes the validation rigorous but
leaves the last question open: how do these methods behave on a real cable with real stranding
resonances and real dielectric dispersion? Every package reads real files; none has been fed one.

**Multi-pair links.** `linktwin` models a single pair. Alien and pair-to-pair crosstalk enter only
as a noise term, and there is no multi-pair connector model. `cablecheck` already evaluates NEXT and
FEXT, so the evaluation side is ready.

**Measured connector models.** Connectors are compact models with declared parameters. Any measured
four-port can already be dropped in as a link element; nothing has been.

**Non-ideal equalisation.** The eye assumes an ideal DFE with correct decisions and a zero-forcing
FFE — no adaptation error, no noise enhancement, no error propagation, no timing jitter. The result
is therefore an upper bound on what a real PHY achieves, and it is reported as one.

**Asymmetric line extraction.** A non-uniform cable reflects differently from each end. The current
extraction symmetrises and keeps the average, which costs about 3 dB at the return-loss minimum. A
two-sided extraction would recover it.
