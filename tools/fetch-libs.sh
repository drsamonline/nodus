#!/bin/sh
# Fetch the MIT helper libraries NetSurf's git tree expects as siblings.
# These are the family's shared asset: MIT, so they can go anywhere.
set -eu

WORK=${WORK:-.}
cd "$WORK"

fetch() {
  name=$1; url=$2; ref=${3:-master}
  if [ -d "$name/.git" ]; then
    echo "== $name: updating =="
    git -C "$name" fetch --depth 1 origin "$ref" 2>/dev/null || git -C "$name" fetch origin
    git -C "$name" checkout -q FETCH_HEAD 2>/dev/null || true
  else
    echo "== $name: cloning =="
    git clone --depth 1 --branch "$ref" "$url" "$name" 2>/dev/null || \
      git clone --depth 1 "$url" "$name"
  fi
}

fetch netsurf-buildsystem https://github.com/netsurf-browser/netsurf-buildsystem.git master
fetch libwapcaplet      https://github.com/netsurf-browser/libwapcaplet.git      master
fetch libparserutils    https://github.com/netsurf-browser/libparserutils.git    master
fetch libhubbub         https://github.com/netsurf-browser/libhubbub.git         master
fetch libcss            https://github.com/netsurf-browser/libcss.git            master
fetch libdom            https://github.com/netsurf-browser/libdom.git            master
fetch libnsgif          https://github.com/netsurf-browser/libnsgif.git          master
fetch libnsbmp          https://github.com/netsurf-browser/libnsbmp.git          master
fetch libsvgtiny        https://github.com/netsurf-browser/libsvgtiny.git        master

cat <<'EOF'

All nine are MIT. Before you trust this, pin them:
  for d in netsurf-buildsystem lib*; do echo "$d $(git -C $d rev-parse HEAD)"; done
Record the SHAs in SOURCES.md. "master" is not a version.
EOF
