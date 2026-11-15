# Patches

Every change to a file that came from upstream NetSurf is recorded here, in the same
commit that makes the change.

## Format

```
### <path> - <one-line summary>
- Commit: <sha>
- Why: <the reason, in one sentence>
- Upstream: <issue or PR link if one exists, else "not filed">
- Revert risk: <what breaks if upstream changes this area>
```

## Log

Nothing yet. This tree is a clean import of NetSurf `f08191a`.

## Policy

1. **Wrap, do not edit.** The ABI shim exists so that most changes never touch
   vendored files. Use it.
2. **Keep hunks small** and one purpose each.
3. **File upstream when it is a bug.** NetSurf is actively developed - the pinned
   commit is days old - so a fix that belongs there should go there first.
4. **Expect merge traffic.** Sync monthly at minimum; the longer the gap, the worse
   the merge.
