<h1 data-nav-order="600">Build system</h1>

One of the main differences between Melange and ReScript, and a relevant reason for Melange to become a separate project, is the replacement of the build system.

Melange attempts to be as compatible as possible with OCaml, while keeping compatibility with existing ReScript projects. To fulfill that goal, Melange replaces almost completely the implementation of `bsb`, the ReScript build tool. The new implementation in Melange relies on [Dune](https://dune.build/), a composable build system for OCaml, to take care of the most intricate parts of the build process.

In the articles included in this section, we will see how Melange build system works and the differences with ReScript, and how Dune configurations differ between standard OCaml projects and Melange.
