# Design

## The shape of the thing

NetSurf is already a core with frontends, but the boundary is informal: frontends
reach into `desktop/`, headers leak, and the build system decides what exists.
Nodus makes the boundary a contract.

```
   frontends/text      frontends/framebuffer    frontends/gtk    frontends/headless
        |                     |                     |                 |
        +---------------------+----------+----------+-----------------+
                                         |
                              +----------v-----------+
                              |      libnodus        |   stable C ABI
                              |  desktop/ content/   |
                              +----------+-----------+
                                         |
                 +-----------------------+-----------------------+
                 |                       |                       |
            libhubbub                libcss/libdom           fetch + cache
            (MIT)                    (MIT)                   (libcurl + store)
```

Three rules make this real:

1. **A frontend links only against `libnodus`.** It never includes `desktop/`
   headers directly. Enforced by a `make abi-check` that greps the frontend's
   include graph.
2. **The core never calls a frontend directly.** Everything the core wants to say
   goes through an ops table the frontend supplied at init.
3. **The ABI is versioned and additive.** New function pointers go at the end of a
   struct; existing ones never change meaning within a major version.

## The frontend contract, in outline

A frontend provides (all function pointers in one `struct nodus_frontend_ops`):

| Op | Called when | Frontend must |
|----|-------------|---------------|
| `init` | startup | allocate its surface, return a handle |
| `invalidate` | a region needs redrawing | mark dirty, do not draw yet |
| `plot` | core wants a rectangle, text run, image or path drawn | rasterise, or convert to cells |
| `set_extent` | layout produced a page size | size the viewport or scrollbar |
| `set_title`, `set_status`, `set_url` | navigation state changed | reflect it, or ignore it |
| `scroll_request` | core wants the view moved | scroll, or refuse |
| `get_clipboard`, `set_clipboard` | text selection | bridge to the platform, or no-op |
| `log` | anything | write it, filter it, or drop it |

The core provides (frontends call these):

`nodus_create`, `nodus_destroy`, `nodus_navigate`, `nodus_back`, `nodus_forward`,
`nodus_reload`, `nodus_stop`, `nodus_resize`, `nodus_mouse`, `nodus_key`,
`nodus_poll`, `nodus_dump_text`, `nodus_dump_outline`, `nodus_render_png`,
`nodus_caps` (returns the JSON capability object from
`shared/vinculum/capabilities.json`).

Everything else is private. If a frontend needs something not on this list, the list
is wrong - fix the list, in an ADR, not in a header.

## The text frontend, which is the point

This is the piece with no upstream equivalent, so it gets the most design.

**Model.** The core produces a box tree with resolved positions in CSS pixels. A text
frontend converts that to a character grid. The conversion is a *plotter*, exactly
like the framebuffer's, so nothing in the core knows the difference:

- `plot_text` with a font size and family becomes a cell span, with bold/italic/
  underline mapped to ANSI attributes, and colour quantised to the terminal's palette
  (256 or 16, auto-detected).
- `plot_rectangle` becomes a background or a rule of `-` characters.
- `plot_bitmap` becomes either an `[alt]` placeholder or, when the terminal can do
  it, a sixel or kitty-protocol image. Off by default; the placeholder is the
  contract, the image is a bonus.
- `plot_path` (SVG, borders) is dropped, with a log line.

**Column width.** The grid is 1 cell per character cell, so the mapping from CSS
pixels to columns needs a fixed scale: `columns = viewport_px / cell_px`, with
`cell_px` measured from the terminal font. When the core reflows at a narrower
pixel width, it produces a layout that maps cleanly onto the terminal width. This is
the whole trick: reflow the core at the terminal's pixel width, then rasterise to
cells.

**Why not just dump text like Lynx does.** Because Lynx's text is a *serialisation*,
not a rendering: no CSS, no float positioning, no table layout algorithm worth the
name. Here the text is a *rasterisation of the same layout the GUI uses*, so a table
lays out as a table and a sidebar sits beside the text instead of above it. That is
the difference between a text browser and a browser that happens to draw text.

**Cost.** One new file, `frontends/text/plotter.c`, plus `frontends/text/main.c` for
the terminal, keymap and status line. Roughly 3-4k lines. The core is untouched,
which is the entire argument for this architecture.

## The headless frontend

`monkey` upstream is a test harness. `nodus-headless` is a product: a frontend with
no window that renders to a file.

- `--png out.png` - render at a given viewport, deterministic (fixed DPI, no
  animations, no timers, no random).
- `--text` - the same text dump the text frontend would produce.
- `--outline` - the element tree with computed styles, JSON, for tests.
- `--serve :8080` - an HTTP endpoint that renders on demand. Useful for
  screenshotting, useless for browsing, and therefore safe to expose on localhost.

Determinism is the feature: two runs of the same input must produce byte-identical
output, or the corpus cannot be diffed, or the family has no oracle.

## The content-addressed cache

`llcache` keys on URL and stores per-URL files. Nodus keys on content:

```
objects/ab/cd/abcdef...        # raw response body, sha256 named
index/<sha256 prefix>.json     # metadata: url, mime, headers, fetched_at, refcount
tmp/                           # writes land here, then rename
```

Properties this buys:

- **Dedupe.** The same jQuery from forty sites is stored once.
- **Correct revalidation.** A 304 reuses the object without a URL-keyed copy.
- **Crash safety.** Writes are atomic; the index is rebuilt by scanning if lost.
- **A size budget that means something.** Eviction is by object age and refcount, not
  by URL recency.

Migration from `llcache` is a one-way import at first start.

## Decisions

### D1 - The ABI is a shim, not a rewrite

Upstream headers change constantly. The public header is a thin, hand-written layer
that wraps them, so upstream churn is absorbed in one file. Rewriting NetSurf's
internals to be "properly" modular would take years and buy nothing a shim does not.

### D2 - Text is a rasterisation, not a serialisation

See above. This is the decision that makes the text frontend worth building, and the
one that would be abandoned first if it were merely a port of Lynx's dump.

### D3 - Determinism is a feature of the headless frontend

Fixed DPI, no timers, no animations, no locale-dependent formatting. The corpus
depends on it, and the corpus is how the family measures itself.

### D4 - GPL-2.0-only is accepted, and shapes the family

NetSurf's licence cannot be upgraded without every copyright holder's consent, and
those holders are scattered across two decades. So Nodus is GPL-2.0-only forever,
which makes Volumen its only code-sharing partner. Plan accordingly: Sorex is a
sibling, not a consumer.

### D5 - One optional child process, for decoders only

Image decoders parse hostile bytes in C. If sandboxing them proves cheap (seccomp
plus a pipe), it happens; the child is a decoder, not a renderer, so the model stays
simple.

### D6 - JavaScript stays optional and stays honest

Duktape, default off, no compatibility claims. A backend interface allows a QuickJS
build to be measured, and the comparison gets published. Sites that need real
JavaScript are tier 0's job.

## Testing strategy

- **The corpus is the oracle.** `test/corpus/` (see
  `shared/vinculum/lite-profile.md`) with three outputs per fixture: text, PNG,
  outline.
- **Frontend abuse tests.** A deliberately hostile frontend that returns garbage from
  every op must not crash the core.
- **Fuzzing.** `libhubbub`, `libcss` and each decoder, in CI, continuously.
- **Cache invariants.** Property tests: no object is evicted while referenced; index
  survives a kill -9.
