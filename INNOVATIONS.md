# Innovations

Ten enhancements, each with the reason, the module, and the measurement. Ordered by
how much of the family depends on it.

---

## I1 - `libnodus`: the core as a versioned library

**Why.** NetSurf's frontends work, but the boundary is informal, so every frontend
re-implements glue and every upstream change ripples into all of them. A real ABI
turns "a browser with ports" into "an engine with consumers", which is what makes
this repo the family's shared asset.

**What.** A hand-written public header, a version script, an install target, a
documented ops table, and `docs/ABI.md` with the stability promise: additive within a
major version.

**Where.** `include/nodus/`, `desktop/` shims, `Makefile` install rules.

**Measured by.** `make abi-check` (frontends include nothing private), and
`examples/minimal-frontend/` building out of tree against installed headers.

**Risk.** Medium. The temptation is to rewrite internals instead of wrapping them;
D1 forbids that.

---

## I2 - The text frontend

**Why.** It is the one thing in this family that does not exist anywhere: a text-mode
browser whose output is a rasterisation of a real layout engine's box tree. Lynx
serialises; w3m approximates; neither lays out a table with a CSS cascade behind it.

**What.** `frontends/text/`: a plotter that emits terminal cells, an ANSI style
mapper, link numbering, a status line, and a keymap from the shared Vinculum file.

**Where.** New frontend, plus one small hook in the core for reflow-at-width.

**Measured by.** Lite Profile v0 conformance for the text frontend, RSS under 25 MB,
and a readability comparison against Lynx on the saved corpus (does the table keep
its columns?).

**Risk.** Medium-high, and it is the flagship, so it gets the roadmap's attention.

---

## I3 - The headless renderer as the family oracle

**Why.** Four browsers need to agree on what a page should look like. The only way to
check that is a deterministic renderer that can run in CI with no display.

**What.** `nodus-headless` with `--png`, `--text`, `--outline`, `--serve`, all
deterministic: fixed DPI, no timers, no animations, no locale dependence.

**Where.** `frontends/headless/`, adapted from `frontends/monkey/`.

**Measured by.** Byte-identical output across two runs; corpus render time under 2 s
per page.

**Risk.** Low. `monkey` already proves the shape.

---

## I4 - Content-addressed cache

**Why.** `llcache` keys on URL, so identical bytes are stored many times and
eviction is arbitrary. A small browser has no disk to waste.

**What.** SHA-256 object store with hardlink dedupe, an index with refcounts, atomic
writes, LRU by object age, and a one-way import from `llcache`.

**Where.** `content/`, replacing `llcache.c` and `fs_backing_store.c` behind the same
internal interface.

**Measured by.** `tools/cache-bench.sh`: hit rate, disk bytes, and time-to-first-byte
on a warm cache versus `llcache`.

**Risk.** Medium. History and the back button must keep working; test both.

---

## I5 - Dirty-region relayout

**Why.** Any change - an image arriving, a font loading, a resize - re-lays out the
whole document. On a 400 KB page that is the difference between usable and not.

**What.** Track which boxes depend on which inputs, invalidate the smallest subtree,
relayout from the nearest stable ancestor, and reuse the rest.

**Where.** `desktop/` layout glue, `libcss` integration.

**Measured by.** Relayout time on the largest fixtures after an image arrives;
target 5x improvement, with zero pixel diff against the corpus.

**Risk.** High. Layout invalidation bugs are subtle; the pixel-diff corpus is the
safety net, and this is deliberately late in the roadmap.

---

## I6 - An arena allocator for the box tree

**Why.** Boxes are allocated and freed constantly, and `malloc` traffic dominates
layout on old hardware.

**What.** A per-document arena for box and style structs, freed wholesale on reflow,
with the existing accounting wrappers kept for observability.

**Where.** `desktop/`, `utils/`.

**Measured by.** Layout time and peak RSS on the largest fixtures.

**Risk.** Low-medium. ASan in CI.

---

## I7 - Fuzzing and a threat model

**Why.** In a no-script browser, the parsers and decoders are the entire attack
surface, and they are C.

**What.** libFuzzer harnesses for `libhubbub`, `libcss`, `libnsgif`, `libnsbmp`,
`libsvgtiny`; a seed corpus from the fixtures; a written threat model; and a
`-D_FORTIFY_SOURCE=3` hardened release build.

**Where.** `test/fuzz/`, CI.

**Measured by.** Cumulative fuzz hours with no crash; criterion 6.

**Risk.** Low. Mostly plumbing, and it makes every other claim credible.

---

## I8 - Sandboxed decoder child

**Why.** An image decoder bug in the UI process is a full compromise of a browser
that runs no scripts. The cheapest fix is a process boundary with a seccomp filter.

**What.** An optional child process that receives bytes and returns a bitmap, with a
seccomp allowlist that permits almost nothing. Falls back to in-process when the
platform cannot do it.

**Where.** `content/handlers/image/`, new `utils/decoder-child.c`.

**Measured by.** Decode throughput cost (target under 10%), and a test that a
deliberately crashing decoder kills only the child.

**Risk.** Medium. Portability, and it must degrade cleanly.

---

## I9 - A JavaScript backend interface, with published numbers

**Why.** "Duktape is incomplete" is a claim; a measurement is an argument. If QuickJS
fits the budget and passes more of the corpus, that is worth knowing, and if it does
not, the negative result is worth publishing.

**What.** A backend interface behind the existing `dukky` layer; a QuickJS
implementation behind a build flag; a comparison table of size, memory, and fixture
pass rate.

**Where.** `content/handlers/javascript/`.

**Measured by.** The published table, reproducible by `tools/js-bench.sh`.

**Risk.** Low, provided nobody starts promising compatibility.

---

## I10 - The Lite Profile conformance runner

**Why.** The family's shared spec is only real if something enforces it, and the
enforcement belongs in the repo that owns the corpus.

**What.** `tools/check-corpus.sh` runs every frontend over every fixture and diffs
against `expect/`, reporting per-requirement pass rates from
`shared/vinculum/lite-profile.md`.

**Where.** `tools/`, `test/corpus/`.

**Measured by.** It is the measurement.

**Risk.** Very low, and it unblocks every other criterion.
