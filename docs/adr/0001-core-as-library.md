# ADR 0001 - The core becomes a library, by shim and not by rewrite

- Status: accepted
- Date: 2026-11-16

## Context

NetSurf is architecturally a core with frontends, but the boundary is informal:
frontends include `desktop/` headers, the build system decides what exists, and the
public surface changes whenever upstream feels like it. Nine frontends live with this,
which is evidence the shape is right and the contract is missing.

The obvious response - restructure the internals so the boundary is clean - is a
rewrite of 400,000 lines with no user-visible benefit, and it would fork us from
upstream so far that we could never merge again.

## Decision

Add a thin, hand-written public ABI (`include/nodus/`) that wraps the internals, and
declare that as the contract. Frontends include only `nodus/*.h`. Upstream churn is
absorbed in the shim, in one place, per sync.

The ABI is versioned and additive: new entries go at the end of the ops struct, and
nothing changes meaning within a major version.

## Consequences

- Upstream merges stay cheap, which matters because upstream is very active.
- The ABI is ours to document and test, and `examples/minimal-frontend/` is its
  executable specification.
- Some genuinely bad internal interfaces remain bad, forever, behind the shim. This
  is the price and it is worth paying.
- A third-party frontend becomes possible, which is the whole point.
