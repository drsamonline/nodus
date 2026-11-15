# Nodus

**nodus, nodi** *(m.) - a knot; a node.* A knot is where separate strands hold each
other without being spliced into one. That is what this project is: one browser
core, many frontends, tied together by an interface instead of by a build flag.

Nodus is a fork of [NetSurf](https://www.netsurf-browser.org/) at commit `f08191a`,
turned into a **library with frontends on top**, and given the one frontend nobody
has written yet: a real text-mode browser sharing the same parser, layout and
network code as the graphical one.

Part of the [Aetheris browser family](FAMILY.md) - tier 1, the shared core.

```
T0 Aetheris   full fidelity, 200 MB+
T1 Nodus      THIS REPO, 25-70 MB
T2 Sorex      everyday GUI, 15-30 MB
T3 Volumen    text only, 5-8 MB
```

## What Nodus is

- **A core, not a browser.** `libnodus` is the product: HTML parse, CSS cascade,
  layout, fetch, cache, history, forms. Frontends are consumers of a documented C
  ABI. NetSurf already has this shape; Nodus makes it a promise with a version
  number.
- **A family of frontends.** `framebuffer` (no toolkit, draws its own widgets),
  `gtk` (desktop), `headless` (render to PNG, PDF or text with no display at all),
  and `text` (the new one: terminal cells instead of pixels).
- **The place the family's hard rendering work happens.** CSS coverage, the
  conformance corpus, the cache design and the fuzzing live here and are available
  to Volumen under the same licence.
- **Honest about JavaScript.** Duktape is present and incomplete; it stays optional
  and off by default. Nothing in this project pretends otherwise.

## What Nodus is not

- Not a NetSurf release. It is a divergent fork with a compatibility promise NetSurf
  never made.
- Not a Chromium competitor. If a page needs a modern engine, tier 0 has one.
- Not finished. The tree is at v0.1: imported, documented, frontends enumerated,
  nothing yet rebuilt around the ABI.

## Build

NetSurf's git tree expects its libraries as siblings; the release tarball bundles
them. Both routes are supported here:

```sh
./tools/fetch-libs.sh          # clone the MIT helper libraries at pinned refs
./tools/build.sh --frontend=framebuffer
./tools/build.sh --frontend=gtk
./tools/build.sh --frontend=headless
./tools/build.sh --frontend=text     # the new one; not implemented yet
```

`tools/fetch-libs.sh` pins `libcss`, `libdom`, `libhubbub`, `libparserutils`,
`libwapcaplet`, `libnsgif`, `libnsbmp`, `libsvgtiny` and `netsurf-buildsystem`. All
are MIT, which is why they are also the family's shared asset (see `FAMILY.md`).

## Run

```sh
./build/framebuffer/nodus-fb https://example.org
./build/gtk/nodus-gtk https://example.org
./build/headless/nodus-headless --png out.png https://example.org
```

## Budget

| Metric | Target | Why this number |
|--------|--------|-----------------|
| `libnodus.so` stripped | <= 4 MB | it is the shared asset; it must be shippable |
| Text frontend RSS, one page | <= 25 MB | cheaper than a terminal multiplexer with a browser in it |
| Framebuffer frontend RSS | <= 70 MB | images and CSS are the cost, and they are worth it |
| Headless render of the corpus | <= 2 s per page, 4 threads | fast enough to be a test suite |
| Fuzz hours without crash | >= 500 h cumulative | the decoders are the attack surface |

## Documentation

| File | Read it when |
|------|--------------|
| [FAMILY.md](FAMILY.md) | how the four browsers relate, and what may legally be shared |
| [SOURCES.md](SOURCES.md) | exactly which upstream this came from |
| [PLAN.md](PLAN.md) | scope, workstreams, success criteria |
| [DESIGN.md](DESIGN.md) | the ABI, the frontend contract, the module map |
| [INNOVATIONS.md](INNOVATIONS.md) | the enhancement backlog with measurements |
| [ROADMAP.md](ROADMAP.md) | release sequence and exit criteria |
| [START_PROMPT.md](START_PROMPT.md) | you are an agent or a new contributor starting work |
| [AGENTS.md](AGENTS.md) | the working rules only |
| [PATCHES.md](PATCHES.md) | you are touching vendored upstream code |

## Provenance and licence

Derived from NetSurf `f08191a` (2026-11-15), version 3.11 trunk (master),
`netsurf-browser/netsurf`. NetSurf is **GPL-2.0-only** - the file headers say "version 2 of the
License" with no "or later" clause - plus a special exception permitting linkage
against OpenSSL. Nodus inherits exactly that: **GPL-2.0-only, with the OpenSSL
exception**. See `COPYING`.

This licence is why Nodus and Volumen can share code freely and Sorex cannot; see
the licence firewall in `FAMILY.md`. The NetSurf helper libraries are MIT and are
vendored under their own terms.

Shared specs in `shared/vinculum/` are CC0-1.0.

Author: Dr Sohil Momin.
