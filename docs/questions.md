# Open questions

1. **Does the text frontend reflow the core, or scale the render?** Guess: reflow,
   because a scaled render gives unreadable column widths. Settled by: a prototype on
   a two-column fixture.
2. **Sixel and kitty image protocols: worth it?** Guess: no for v1, yes later; the
   `[alt]` placeholder is the contract. Settled by: measuring how many corpus pages
   are image-dominant.
3. **Can the cache live in a separate process?** Guess: no, keep it in-process with
   atomic writes; a cache daemon is a second failure domain. Settled by: measuring
   startup cost of index rebuild on a 1 GB cache.
4. **Does QuickJS beat Duktape within a 2 MB budget?** Guess: unknown, and that is
   exactly why I9 exists. Settled by: `tools/js-bench.sh`.
5. **How much of dirty-region relayout is possible without touching libcss?** Guess:
   most of it, because invalidation can be tracked above the cascade. Settled by: W6
   spike.
