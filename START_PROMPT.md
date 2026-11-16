# Start prompt

Paste this whole file into a coding agent at the start of a work session in this
repository. It is self-contained: the agent needs nothing else except the files it
names.

---

You are working in **Nodus**, a fork of the NetSurf browser, at
`https://github.com/drsamonline/nodus`. You are one of four browsers in the Aetheris
family; Nodus is tier 1, and it is the family's shared core.

## Read before you type

In this order, and the first one is not optional:

0. `docs/UPSTREAM-FIRST.md` - this tree is a fork; read the vendored source for the
   feature before designing it, and read Ladybird's `Libraries/LibWeb` for anything
   interaction-shaped (focus, events, style invalidation).


1. `FAMILY.md` - the four tiers, the Vinculum contract, and the licence firewall.
2. `SOURCES.md` - the pinned upstream commit and the MIT helper libraries.
3. `PLAN.md` - mission, non-goals, workstreams, success criteria.
4. `DESIGN.md` - the ABI, the frontend contract, and decisions D1-D6.
5. `INNOVATIONS.md` - the ten-item backlog with measurements.
6. `ROADMAP.md` - which item belongs to the release you are in.
7. `PATCHES.md` - every local change to vendored upstream code.

If a file contradicts this prompt, the file wins and this prompt gets fixed.

## What this project is

A browser core as a library, with four frontends: framebuffer, gtk, headless, and -
the reason the project exists - a text frontend that rasterises a real layout to
terminal cells. GPL-2.0-only plus the OpenSSL exception. ~408,000 lines of C, most of
it inherited, and the job is to put a contract around it rather than to rewrite it.

## Hard constraints

1. **The ABI is additive.** Within a major version, never change the meaning of an
   existing entry in `struct nodus_frontend_ops`. Add at the end, or add a new
   function.
2. **A frontend links only against `libnodus`.** No `desktop/` headers in a frontend.
   `make abi-check` enforces this and must stay green.
3. **The core never calls a frontend directly.** Everything goes through the ops
   table.
4. **Determinism in the headless frontend.** Fixed DPI, no timers, no animations, no
   locale-dependent formatting. Two runs, byte-identical output.
5. **Licence hygiene.** This tree is GPL-2.0-only. Code from Volumen (also GPL-2.0)
   may be merged in. Code from Sorex (GPL-3.0-or-later) may not, and MIT code from
   Aetheris may, but nothing from Aetheris should be: it is an oracle, not a source.
   The MIT NetSurf libraries are always fine.
6. **Upstream edits are logged** in `PATCHES.md` in the same commit.
7. **One optional child process, for decoders.** No process-per-tab, ever.
8. **JavaScript stays optional, default off, and un-promised.**

## How to work

- **Small commits, conventional messages:** `feat(abi): add nodus_caps`,
  `feat(text): map bold and italic to ANSI`, `fix(cache): survive kill -9`.
- **One workstream per branch.** W1 build/ABI, W2 frontend contract, W3 text, W4
  headless, W5 cache, W6 layout, W7 hardening, W8 JavaScript.
- **Shim, do not rewrite.** If upstream internals are awkward, wrap them. D1 exists
  because "properly modular" is a decade-long trap.
- **Fixture first.** Any rendering change starts with a fixture that fails today.
- **Measure, do not assert.** `tools/measure.sh` output goes in the pull request.
- **Freeze before you ship.** ABI changes land early in a milestone, never in the
  release commit.

## Your first three tasks

**Task 1 - Make the build real.** Run `./tools/fetch-libs.sh` then
`./tools/build.sh --frontend=framebuffer`. Fix what breaks, pin the library refs that
actually work, and record the versions in `SOURCES.md`. Then do the same for
`--frontend=gtk` and `--frontend=headless`. Do not start anything else until all
three build.

**Task 2 - Write the frontend contract down.** Read `frontends/framebuffer/` and
`frontends/monkey/` and extract what they actually need from the core. Write
`docs/ABI.md` as it behaves *today*, warts included. Then create
`examples/minimal-frontend/`: a frontend that prints the page title and exits, built
out of tree against installed headers. That example is the executable version of the
contract, and it is the deliverable.

**Task 3 - Begin the text plotter.** Create `frontends/text/` with a `main.c` that
opens a page and dumps nothing yet, plus `plotter.c` implementing `plot_text` as cell
output and every other op as a no-op with a log line. Render one fixture. It will look
wrong. Commit it anyway, with the output in the message, because that is the baseline
every later text commit is measured against.

## Definition of done

- The relevant `tools/build.sh` targets pass from clean.
- `make abi-check` passes.
- New behaviour has a fixture or test that fails without the change.
- `tools/measure.sh` output is in the pull request for any performance claim.
- `PATCHES.md` updated if a vendored file changed.
- Docs updated in the same commit.
- The commit message says why.

## Anti-goals, restated because they keep coming back

- Do not rewrite the layout engine. Wrap it.
- Do not make the text frontend a Lynx clone. It is a rasteriser of the core's
  layout, and that is the whole point.
- Do not add a second JavaScript engine as the default.
- Do not add process-per-tab "for security". One decoder child, no more.
- Do not touch the ABI in a release milestone.
- Do not claim a page renders "correctly" without a corpus fixture that proves it.

## When you are unsure

Write the question in `docs/questions.md` with your best guess and the reason. Prefer
the guess that keeps the ABI stable and the licence clean. Those two are never the
wrong answer.
