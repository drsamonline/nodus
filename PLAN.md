# Plan

## Mission

Turn NetSurf's engine into a library with a stable interface, and use that interface
to build the frontend the web has been missing: a text-mode browser that shares a
real rendering pipeline with a graphical one. Then make that library the family's
shared rendering asset.

## Position in the family

Tier 1. Above Sorex because it has more CSS, optional JavaScript and several
frontends; below Aetheris because its engine is older and its JavaScript is
incomplete. It is the only tier that is a *library* first and a browser second,
which is why the family's conformance corpus and shared rendering work live here.

## Users, in priority order

1. **The embedder.** Wants a small browser inside something else: a kiosk, a
   documentation viewer, an appliance, a test harness. The ABI is for them.
2. **The terminal user.** Wants images and CSS in a terminal, or wants a text
   browser whose parsing is not a decade behind.
3. **The accessibility user.** A text frontend that emits cells is a screen reader's
   dream: the structure is already linearised, and the layout is already resolved.
4. **The maintainer of a small distribution.** Wants one core and several surfaces,
   so that a bug is fixed once.

## Non-goals

- No new rendering engine. `libcss` and `libhubbub` are the engine; Nodus wires them.
- No Chromium-grade JavaScript. Duktape stays, stays optional, and stays honest.
- No process-per-tab. One optional sandboxed decoder child, no more.
- No plugin ecosystem. Frontends are the extension mechanism.
- No Windows or macOS polish. The GTK and framebuffer frontends are the targets.

## Success criteria for v1.0

| # | Criterion | Measured by |
|---|-----------|-------------|
| 1 | `libnodus` builds as a versioned shared library with a documented ABI | `make abi-check`, `docs/ABI.md` |
| 2 | A third-party frontend can be built against the installed headers alone | `examples/minimal-frontend/` builds out of tree |
| 3 | The text frontend renders 100% of Lite Profile v0 fixtures | `tools/check-corpus.sh --frontend=text` |
| 4 | Text frontend under 25 MB RSS on the saved-page corpus | `tools/measure.sh --frontend=text` |
| 5 | Headless frontend renders the corpus to PNG and text deterministically | byte-identical output across two runs |
| 6 | 500 cumulative fuzz hours on parsers and decoders with no crash | OSS-Fuzz dashboard or local corpus |
| 7 | Content-addressed cache beats `llcache` on hit rate and disk use | `tools/cache-bench.sh` |
| 8 | No frontend can crash the core: a misbehaving frontend exits alone | `tools/test-frontend-abuse.sh` |

## Workstreams

**W1 - Build and library-ise.** Get a clean build with pinned MIT libraries, then
turn the core into `libnodus.so` with an install target, a version script and
`docs/ABI.md`. Exit: criterion 1.

**W2 - The frontend contract.** Write the interface down: the ops a frontend
implements, the events it receives, the lifetime rules. Add
`examples/minimal-frontend/` - a frontend that renders nothing but prints the page
title and exits - as the executable specification. Exit: criterion 2.

**W3 - The text frontend.** The flagship. A plotter that emits terminal cells,
mapping the box tree to a character grid, with a style-to-ANSI mapping, link
numbering, and a status line. Exit: criteria 3 and 4.

**W4 - Headless and determinism.** Generalise `monkey` into `nodus-headless`:
`--png`, `--text`, `--pdf`, `--outline`, deterministic output, no display, no
random. This becomes the family's render oracle. Exit: criterion 5.

**W5 - The cache.** Replace `llcache` + `fs_backing_store` with a content-addressed
store: SHA-256 keys, hardlink dedupe, LRU with a size budget, an index that survives
a crash. Exit: criterion 7.

**W6 - Layout performance.** Dirty-region relayout, an arena for box allocation, and
a frame budget shared with the family. Exit: measurable improvement on the largest
fixtures with no pixel diff.

**W7 - Hardening.** libFuzzer harnesses for `libhubbub`, `libcss` and each decoder;
an optional sandboxed decoder child (seccomp); a threat model. Exit: criterion 6.

**W8 - JavaScript, honestly.** Keep Duktape as default-off. Add a backend interface
so a QuickJS build can be measured against it, and publish the comparison. No
promises about compatibility.

## Milestones

| Milestone | Contains | Gate |
|-----------|----------|------|
| v0.1 scaffold | upstream imported, docs, pinned libs, all frontends enumerated | `tools/build.sh --frontend=framebuffer` green |
| v0.2 library | `libnodus.so`, install target, ABI doc, minimal example frontend | criteria 1, 2 |
| v0.3 text | text frontend renders the fixtures | criterion 3 |
| v0.4 oracle | headless renderer, deterministic corpus output | criterion 5 |
| v0.5 cache | content-addressed store with a bench | criterion 7 |
| v0.6 hard | fuzzing, sandbox, threat model | criterion 6 |
| v1.0 release | all criteria, ABI frozen for 1.x | all |

## Risks

| Risk | Likelihood | Response |
|------|-----------|----------|
| Upstream churn makes the ABI work a treadmill | high | ABI is *ours*: a thin shim over upstream headers, so upstream moves behind it |
| A text frontend is harder than it looks | medium-high | the box tree is already linear; start with text-only fixtures and grow |
| NetSurf's GPL-2.0-only licence limits adoption | medium | accepted; the MIT helper libraries are the escape hatch for embedders |
| Duktape's incompleteness becomes a support burden | high | default off, documented as such, and no compatibility claims |
| Cache rewrite breaks the back button | medium | the store is content-addressed, history is separate; test both |
