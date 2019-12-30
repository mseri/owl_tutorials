# Owl Tutorial Book

This tutorial book is for teaching how to use Owl software. The tooling and template reuse those in [Real World OCaml](https://realworldocaml.org/) under original authors' permission, with minor modidications.


## Compile

- `make` uses docker container to build the book.
- `make test` synchronises with Owl API by evaluating the code snippet in the tutorial book.
- `make compile` generates html files.
- Edit `book/toc.scm` to add more chapters. Do not edit `book/tune` and `static/dune` directly.
- Refer to [RWO](https://github.com/realworldocaml/book/blob/master/README.md) for details.

Note that tooling is not finished at the moment. Structure and tools are copied mostly from RWO book.


## People

- Liang Wang: project originator, reponsible for planning, tooling, and writing.
- Jianxin Zhao: project leader, lead the whole book writing, designing chapters, and coordinating contributors.