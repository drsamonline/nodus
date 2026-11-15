#!/bin/sh
# Nodus build driver. NetSurf uses a hand-rolled make with a TARGET variable.
set -eu

FRONTEND=framebuffer
JOBS=$( (getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2) )

for arg in "$@"; do
  case "$arg" in
    --frontend=*) FRONTEND="${arg#--frontend=}" ;;
    --debug) DEBUG=1 ;;
    -h|--help)
      cat <<'EOF'
usage: tools/build.sh [--frontend=framebuffer|gtk|headless|text] [--debug]

Needs the sibling MIT libraries: run tools/fetch-libs.sh first.
EOF
      exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 64 ;;
  esac
done

[ -d libcss ] || { echo "missing libcss. Run ./tools/fetch-libs.sh first." >&2; exit 1; }

case "$FRONTEND" in
  framebuffer) TARGET=netsurf-fb ;;
  gtk)         TARGET=netsurf-gtk3 ;;
  headless)    TARGET=netsurf-monkey ;;
  text)        TARGET=netsurf-text ;;
  *) echo "unknown frontend: $FRONTEND" >&2; exit 64 ;;
esac

if [ "${DEBUG:-0}" = "1" ]; then
  CFLAGS="-O0 -g3 -fno-omit-frame-pointer"
else
  CFLAGS="-O2 -flto -fomit-frame-pointer -DNDEBUG -fstack-protector-strong -D_FORTIFY_SOURCE=2"
fi
export CFLAGS

echo "== make TARGET=$TARGET -j$JOBS =="
# NetSurf's makefiles read TARGET and NETSURF_USE_* toggles; see Makefile.defaults.
make TARGET="$TARGET" -j"$JOBS" \
  NETSURF_USE_JPEG=YES \
  NETSURF_USE_PNG=YES \
  NETSURF_USE_WEBP=YES \
  NETSURF_USE_JS=NO \
  NETSURF_USE_NSSVG=YES \
  || { echo "build failed. Most likely a missing dev package or an unpinned lib." >&2; exit 1; }

echo "== built =="
find build -maxdepth 2 -type f -perm -u+x 2>/dev/null | head -20 || true
