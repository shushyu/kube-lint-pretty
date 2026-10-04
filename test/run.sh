#!/usr/bin/env bash
# Integrationstests gegen ein echtes kube-linter (muss im PATH liegen).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

bin=("$BASH" ./kube-lint-pretty)   # läuft mit der Bash des Testlaufs, kein +x nötig
fail=0

# shellcheck disable=SC2329  # indirekt über t() aufgerufen
contains()     { [[ $1 == *"$2"* ]]; }
# shellcheck disable=SC2329
not_contains() { [[ $1 != *"$2"* ]]; }
t() { local name=$1; shift; if "$@"; then echo "ok    $name"; else echo "FAIL  $name"; fail=1; fi; }

export NO_COLOR=1 NO_UNICODE=1

# Einzelne Datei mit Findings
out=$("${bin[@]}" test/fixtures/insecure.yaml 2>/dev/null); rc=$?
t "insecure: exit code 1"            [ "$rc" -eq 1 ]
t "insecure: 11 findings"            contains "$out" "11 findings"
t "insecure: grouped check (2)"      contains "$out" "NET_RAW capability configuration (2)"
t "insecure: privileged title"       contains "$out" "Privileged container"
t "insecure: footer shows rc"        contains "$out" "exit code 1"
t "insecure: no ANSI"                not_contains "$out" $'\e'

# Rückgabecode == kube-linter
kube-linter lint test/fixtures/insecure.yaml >/dev/null 2>&1; want=$?
t "exit code matches kube-linter"    [ "$rc" -eq "$want" ]

# Keine Findings
out=$("${bin[@]}" test/fixtures/clean 2>/dev/null); rc=$?
t "clean: exit code 0"               [ "$rc" -eq 0 ]
t "clean: success line"              contains "$out" "no findings"

# Verzeichnis mit mehreren Objekten
out=$("${bin[@]}" test/fixtures 2>/dev/null); rc=$?
t "dir: exit code 1"                 [ "$rc" -eq 1 ]
t "dir: multiple objects"            contains "$out" "2 objects in 2 files"
t "dir: both objects listed"         contains "$out" "legacy-redis"

# Fehlende Datei: kein erfundener Output
out=$("${bin[@]}" does-not-exist.yaml 2>&1); rc=$?
t "missing file: non-zero"           [ "$rc" -ne 0 ]
t "missing file: no fake findings"   not_contains "$out" "findings in"

# Fehlendes Binary
KUBE_LINTER=definitely-not-installed "${bin[@]}" test/fixtures >/dev/null 2>&1; rc=$?
t "missing binary: rc 127"           [ "$rc" -eq 127 ]

# Rohausgabe
out=$(KLP_RAW=1 "${bin[@]}" test/fixtures/insecure.yaml 2>/dev/null)
t "KLP_RAW shows original"           contains "$out" "(check: host-network"

# Farbe nur auf Anforderung
unset NO_COLOR
out=$(FORCE_COLOR=1 "${bin[@]}" test/fixtures/insecure.yaml 2>/dev/null)
t "FORCE_COLOR emits ANSI"           contains "$out" $'\e['
out=$("${bin[@]}" test/fixtures/insecure.yaml 2>/dev/null)
t "non-TTY: no ANSI by default"      not_contains "$out" $'\e'

exit "$fail"
