#!/usr/bin/env bash
# Install all seven packages of the HF cable toolchain, in dependency order.
#
#   ./scripts/install-all.sh              install from GitHub into the active environment
#   ./scripts/install-all.sh --editable   clone into ./src and install editable, for development
set -euo pipefail

USER_NAME=anilram30
ORDER=(cablecheck zprofile shieldeval cableanalytics labauto labplatform linktwin)
EDITABLE=${1:-}

python3 - <<'PY'
import sys
if sys.version_info < (3, 11):
    sys.exit(f"Python 3.11 or newer is required; this is {sys.version.split()[0]}")
PY

if [ "$EDITABLE" = "--editable" ]; then
  mkdir -p src && cd src
  for p in "${ORDER[@]}"; do
    [ -d "$p" ] || git clone --depth 1 "https://github.com/$USER_NAME/$p.git"
    echo "==> installing $p (editable)"
    pip install -e "./$p[dev]"
  done
  echo
  echo "All seven installed editable under $(pwd)."
else
  for p in "${ORDER[@]}"; do
    echo "==> installing $p"
    pip install "git+https://github.com/$USER_NAME/$p.git"
  done
fi

echo
echo "Installed:"
for p in "${ORDER[@]}"; do
  printf '  %-16s %s\n' "$p" "$(python3 -c "import $p; print($p.__version__)" 2>/dev/null || echo '(version unavailable)')"
done
