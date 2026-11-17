# AGENTS.md

Working rules for coding agents in this repository. Humans should read
`START_PROMPT.md`, the long form of this file.

## Read order

`docs/UPSTREAM-FIRST.md` first — this tree is a fork, so the answer to "how should
this work" is already on disk. Read the vendored source before designing anything,
and read `Libraries/LibWeb` (Ladybird) for anything interaction-shaped.

`FAMILY.md` -> `SOURCES.md` -> `PLAN.md` -> `DESIGN.md` -> `INNOVATIONS.md` ->
`ROADMAP.md` -> `PATCHES.md`.

## Non-negotiables

1. The ABI is additive within a major version.
2. Frontends link only against `libnodus`; `make abi-check` must pass.
3. The core never calls a frontend directly.
4. Headless output is deterministic.
5. GPL-2.0-only tree: Volumen (GPL-2.0) code may merge; Sorex (GPL-3.0) code may not.
6. Vendored-file edits are logged in `PATCHES.md` in the same commit.
7. One optional child process, for decoders only.
8. JavaScript stays optional and default off.

## Commit style

`feat(abi):`, `feat(text):`, `feat(cache):`, `fix(layout):`, `perf(arena):`,
`docs(adr):`.

## Before you claim success

Run the command, paste the output. A claim without a command is folklore.

## Where things live

| Need | Path |
|------|------|
| Content objects, fetch, cache, handlers | `content/` |
| Window logic, layout glue, history, cookies | `desktop/` |
| Frontends | `frontends/{framebuffer,gtk,headless,text,monkey}/` |
| Public ABI headers | `include/nodus/` (created by W1) |
| Utilities | `utils/` |
| Tests, fixtures, fuzzing | `test/` |
| Our documentation | `docs/` |
| Shared family specs (do not diverge) | `shared/vinculum/` |

## Check the instrument before the subject

Reading upstream first is half of it. The other half is not blaming the engine for a bad measurement. In
Aetheris on 2026-11-17, three investigations blamed the browser and were wrong three times: a pixel sample
read as a picture, a verdict string a script computed backwards, and a colour assertion that also matched
white. The engine was correct throughout.

1. Print the raw value, never a derived verdict (`print(pixel)`, not `print("SIDE-BY-SIDE")`).
2. Test a colour as that colour, never as "not the other one" — white matches most careless tests.
3. Look at the rendered frame before reasoning from coordinates.
4. A control case must be able to come out the other way; if it cannot, it proves nothing.

