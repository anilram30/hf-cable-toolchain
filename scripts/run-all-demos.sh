#!/usr/bin/env bash
# Run every demonstration in the toolchain and collect the output.
#
#   ./scripts/run-all-demos.sh [OUTDIR] [--quick]
#
# Every package exposes the same `demo` entry point. Takes roughly 25 minutes, or
# about 6 with --quick. Needs all seven packages installed (see install-all.sh).
#
# Note on exit codes: a demo exits non-zero when samples fail their limits, and several
# of these demonstrations are *built* around samples that fail — that is what makes them
# demonstrations. So a step is judged by whether it produced its output, not by its exit
# code, and the summary at the end reports both.
set -uo pipefail

OUT=${1:-out}
QUICK=${2:-}
mkdir -p "$OUT"
START=$SECONDS
STEPS=()

run() {                      # run <label> <expected-output-path> <command...>
  local label="$1" expect="$2"; shift 2
  printf '\n\033[1m==> %s\033[0m\n' "$label"
  "$@"
  local rc=$?
  local ok="missing"
  [ -e "$expect" ] && ok="ok"
  STEPS+=("$label|$rc|$ok|$expect")
  [ "$ok" = "missing" ] && printf '\033[31m    expected output not found: %s\033[0m\n' "$expect"
  return 0
}

run "A · cablecheck — measurement to verdict"        "$OUT/a-cablecheck/reports"   cablecheck demo "$OUT/a-cablecheck"
run "D · zprofile — impedance against position"      "$OUT/d-zprofile"             zprofile demo "$OUT/d-zprofile"
run "C · shieldeval — legacy and modern method"      "$OUT/c-shieldeval"           shieldeval demo "$OUT/c-shieldeval"
run "E · cableanalytics — production to performance" "$OUT/e-cableanalytics"       cableanalytics demo "$OUT/e-cableanalytics"
run "B · labauto — the simulated laboratory"         "$OUT/b-lab/archive"          labauto demo "$OUT/b-lab"
run "F · labplatform — four sites, comparison, drift" "$OUT/f-labplatform"         labplatform demo "$OUT/f-labplatform"
if [ "$QUICK" = "--quick" ]; then
  run "G · linktwin — the digital twin"              "$OUT/g-linktwin/index.html"  linktwin demo "$OUT/g-linktwin" --quick
else
  run "G · linktwin — the digital twin"              "$OUT/g-linktwin/index.html"  linktwin demo "$OUT/g-linktwin"
fi

printf '\n\033[1mSummary\033[0m  (exit 1 usually means "samples failed their limits", which is the point)\n'
FAILED=0
for s in "${STEPS[@]}"; do
  IFS='|' read -r label rc ok expect <<< "$s"
  if [ "$ok" = "ok" ]; then
    printf '  \033[32m✓\033[0m %-52s exit %s\n' "$label" "$rc"
  else
    printf '  \033[31m✗\033[0m %-52s exit %s  no output at %s\n' "$label" "$rc" "$expect"
    FAILED=$((FAILED + 1))
  fi
done

printf '\n%d min %d s. Output in %s\n' $(( (SECONDS-START)/60 )) $(( (SECONDS-START)%60 )) "$OUT"
find "$OUT" -name '*.html' 2>/dev/null | sed 's/^/  /'
[ "$FAILED" -eq 0 ] || { printf '\n\033[31m%d step(s) produced no output.\033[0m\n' "$FAILED"; exit 1; }
