#!/bin/sh
# Measure what PLAN.md's criteria are judged on.
set -eu

FRONTEND=framebuffer
while [ $# -gt 0 ]; do
  case "$1" in
    --frontend) FRONTEND="$2"; shift 2 ;;
    *) shift ;;
  esac
done

case "$FRONTEND" in
  framebuffer) BIN=build/framebuffer/netsurf-fb ;;
  gtk)         BIN=build/gtk/netsurf-gtk3 ;;
  headless)    BIN=build/headless/netsurf-monkey ;;
  text)        BIN=build/text/netsurf-text ;;
  *) echo "unknown frontend $FRONTEND" >&2; exit 64 ;;
esac

[ -x "$BIN" ] || { echo "no binary at $BIN - build first" >&2; exit 1; }

echo "== frontend: $FRONTEND =="
ls -l "$BIN" | awk '{print "size_bytes: "$5}'
if [ -f libnodus.so ]; then ls -l libnodus.so | awk '{print "libnodus_bytes: "$5}'; fi

echo "== corpus render =="
if [ -d test/corpus/saved ]; then
  n=0
  for f in test/corpus/saved/*.html; do
    [ -e "$f" ] || continue
    n=$((n+1))
  done
  echo "saved pages: $n"
fi

echo "== rss, one page =="
# Headless measurement is the reproducible one; use it as the headline number.
if [ "$FRONTEND" = "headless" ]; then
  /usr/bin/time -v "$BIN" --text about:blank 2>&1 | grep -E "Maximum resident" || true
else
  echo "graphical frontends: run under xvfb-run and read /proc/<pid>/status VmHWM"
fi

echo
echo "Paste this into the pull request. Compare against PLAN.md, not against a feeling."
