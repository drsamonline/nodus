# Roadmap

Dates are targets, not promises. Each phase has an exit criterion that is a command,
not a feeling: if the command does not pass, the phase is not done and the next one
does not start.

Phases are deliberately short. A phase that cannot be finished in six to ten weeks of
evenings is a phase that will be abandoned, so scope is cut before dates move.

## P0 - Scaffold (November 2026)

Upstream imported at `f08191a`, MIT helper libraries pinned, documentation written,
shared Vinculum contract in place.

**Exit:** `./tools/fetch-libs.sh` then `./tools/build.sh --frontend=framebuffer`
produces a working binary; `--frontend=gtk` and `--frontend=headless` too. Library
SHAs recorded in `SOURCES.md`.

## P1 - The ABI, written down and tested (December 2026 - January 2027)

`docs/ABI.md` describing the contract as it behaves today, `include/nodus/` as the
public surface, and `examples/minimal-frontend/` building out of tree. `make abi-check`
enforces that no frontend includes private headers.

**Exit:** criteria 1 and 2 in `PLAN.md`. A frontend written by someone who has only
read the header compiles.

**Cut if late:** the install target and pkg-config file can trail; the example cannot.

## P2 - The text frontend (February - April 2027)

The flagship. `frontends/text/` with a cell plotter, ANSI style mapping, link
numbering, a status line, and the shared Vinculum keymap.

**Exit:** Lite Profile v0 conformance for the text frontend on all fixtures; RSS under
25 MB; a table fixture keeps its columns.

**Cut if late:** sixel and kitty image protocols; the `[alt]` placeholder is the
contract and the images are a bonus.

## P3 - The oracle (May 2027)

`nodus-headless` with `--png`, `--text`, `--outline`, `--serve`, all deterministic.
This is what makes the family's conformance claims testable, so it comes before any
further rendering work.

**Exit:** byte-identical output across two runs; corpus render under 2 s per page.

## P4 - Cache and layout (June - July 2027)

The content-addressed cache (I4), then dirty-region relayout (I5) if it proves
tractable without touching `libcss` internals.

**Exit:** cache bench beats `llcache` on hit rate and disk bytes with history intact;
relayout 5x faster on the largest fixtures with zero pixel diff, or the item is closed
with the numbers that killed it.

## P5 - Hardening and v1.0 (August - September 2027)

Fuzzing (I7), the sandboxed decoder child (I8), the arena allocator (I6), the corpus
runner (I10), and the ABI frozen for 1.x.

**Exit:** all eight success criteria in `PLAN.md` pass; 500 cumulative fuzz hours with
no crash; `examples/minimal-frontend/` still compiles against the frozen ABI.

## What is explicitly not on this roadmap

- Rewriting the internals "properly". D1 forbids it.
- A second JavaScript engine as the default.
- Process-per-tab.
- Windows or macOS frontends.

## How this roadmap changes

The ABI lands early and freezes late; rendering work fills the middle. If the text
frontend slips, the headless frontend moves up, because the family needs an oracle more
than it needs a terminal browser - and the text frontend is the harder of the two.
