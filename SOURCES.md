# Sources

Where this tree came from, exactly, and what may be pulled into it later.

## Upstream

| Field | Value |
|-------|-------|
| Project | NetSurf |
| Repository | https://github.com/netsurf-browser/netsurf |
| Website | https://www.netsurf-browser.org/ |
| Commit | `f08191a` (2026-11-15) |
| Version at that commit | 3.11 trunk (master) (trunk; last release 3.11, Dec 2023) |
| Licence | GPL-2.0-only plus OpenSSL linking exception (verified in `content/content.c` and `COPYING`) |
| Size / files | 24 MB, 1,829 tracked files |
| Language | C |
| Code lines | ~408,000 (`.c` + `.h`) |

The whole upstream tree is present at the commit above. This is a vendored fork,
not a GitHub network fork (the tooling used to build it cannot create forks), so
upstream is tracked as a git remote.

## How to sync upstream

```sh
./tools/sync-upstream.sh
./tools/sync-upstream.sh --merge
```

Upstream is very active - the pinned commit is days old - so expect real merge
traffic and keep local changes in new files wherever possible.

## Upstream layout

| Path | What it is | Will Nodus change it? |
|------|------------|-----------------------|
| `content/` | content objects, fetch, cache (`llcache`, `fs_backing_store`), handlers | yes: content-addressed cache |
| `desktop/` | browser window logic, layout glue, history, hotlist, cookies | yes: dirty-region layout |
| `frontends/` | `gtk`, `qt`, `framebuffer`, `monkey`, `windows`, `amiga`, `atari`, `beos`, `riscos` | yes: new `text` frontend, hardened `monkey` |
| `include/` | the public-ish headers | yes: this becomes the ABI |
| `utils/` | utilities, including the hash, URL and utf8 helpers | no |
| `test/` | upstream unit tests | yes: the corpus lives here |
| `tools/` | build and codegen tools (`nsgenbind`, `nslog`, `split-messages`) | no |
| `resources/` | default CSS, adblock data, messages | yes: Lite Profile defaults |

Note `frontends/monkey` - a headless frontend used upstream for automated testing.
It is the existence proof that this architecture can carry a non-graphical frontend,
and it is the template for both `headless` and `text` here.

## The helper libraries

NetSurf's own libraries are separate repositories, all MIT, all pinned by
`tools/fetch-libs.sh`:

| Library | Job | Licence |
|---------|-----|---------|
| `libparserutils` | input streams, charset handling | MIT |
| `libwapcaplet` | string interning | MIT |
| `libhubbub` | HTML5 tokeniser and tree builder | MIT |
| `libcss` | CSS parser and cascade | MIT |
| `libdom` | DOM implementation | MIT |
| `libnsgif`, `libnsbmp`, `libsvgtiny` | image decoders | MIT |
| `netsurf-buildsystem` | makefiles and tooling | MIT |

These MIT libraries are the family's single most valuable shared asset: they may be
vendored into Aetheris (MIT), Sorex (GPL-3.0-or-later) and Volumen (GPL-2.0-only)
without any licence question. See `FAMILY.md`.

## Licences of things we may NOT vendor

- **Nothing from Sorex.** Dillo is GPL-3.0-or-later and this tree is GPL-2.0-only;
  the two are incompatible in both directions. Ideas and specs may cross, source
  lines may not.
- **Nothing from Aetheris.** MIT code may enter a GPL project, but Aetheris itself is
  a C++ engine whose architecture would drag this tree into a rewrite. It is an
  oracle for conformance, not a source of code.

## Ideas taken from elsewhere

- The frontend/core split as a *product* rather than a build detail: NetSurf's own
  architecture, made explicit.
- Content-addressed caching: a common idea, implemented here first in the family and
  reimplemented independently in Sorex.
- The Lite Rendering Profile and its corpus: `shared/vinculum/lite-profile.md`.
- The handoff ladder and capability query: the family contract.
