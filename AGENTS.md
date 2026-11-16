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
