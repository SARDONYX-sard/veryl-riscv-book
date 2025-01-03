# veryl-riscv-book

- ref: https://github.com/nananapo/veryl-riscv-book

## NOTE: Need core.f manual ordering

It seems to be a bug in VERYL according to the book's author.
It seems that using veryl of commit 22cb6d6 will solve this problem.
- https://github.com/veryl-lang/veryl/commit/22cb6d6d6e6c0959bf6bee5f0bb4ca981a35a9be

```
/workspaces/veryl-riscv-book/core/src/util.sv
/workspaces/veryl-riscv-book/core/src/eei.sv
/workspaces/veryl-riscv-book/core/src/memory.sv
/workspaces/veryl-riscv-book/core/src/membus_if.sv
/workspaces/veryl-riscv-book/core/src/core.sv
/workspaces/veryl-riscv-book/core/src/top.sv
```

## TODO

- [ ] Simulation run with CI using containers created from the Dockerfile.

## License

The source is also distributed under the following license, which is provided by the author of the book.

See [LICENSE](./LICENSE)

- SPDX pattern(https://spdx.github.io/spdx-spec/v2.3/file-tags/)

```
// SPDX-FileCopyrightText: Copyright (c) 2025 Kanata Abe
// SPDX-License-Identifier: BSD-3-Clause
```
