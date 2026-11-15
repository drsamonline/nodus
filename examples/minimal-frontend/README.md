# minimal-frontend

The executable specification of the Nodus ABI: a frontend that opens one URL, prints
the page title, and exits. About 100 lines, built out of tree against installed
headers.

If this stops compiling, the ABI has broken its promise and the release is blocked.
It is criterion 2 in `PLAN.md`.

```sh
# after ./tools/build.sh and make install
cc -o minimal minimal.c $(pkg-config --cflags --libs nodus)
./minimal https://example.org
```

Not implemented yet: this directory is the specification, written before the code.
Task 2 in `START_PROMPT.md` fills it in.
