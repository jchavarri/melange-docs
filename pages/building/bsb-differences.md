<h1 data-nav-order="601">ReScript <code>bsb</code> vs Melange <code>bsb</code></h1>

At the moment, Melange shares the same name for the build tool `bsb`. But the behavior of this tool in Melange differs quite a lot from what `bsb` does in ReScript. This article explains in general terms what happens when calling `bsb -make-world` in ReScript and compares it with what happens when calling the same command in Melange.

## Calling `bsb -make-world` in ReScript

ReScript build configurations are specified in a `bsconfig.json` file, that is added to the project root folder.

This file is used by ReScript build tool, called `bsb`. `bsb` itself is a fork of [Ninja](https://ninja-build.org/). When a ReScript user runs `bsb -make-world`, the build tool will read the `bsconfig.json` file, then the folders and files that are part of the project, and then generate all the build rules that are written to a file called `build.ninja`. This file can be found under the `lib/bs` folder.

At the end of the build process, ReScript will defer to Ninja to know which rules should be executed, which ones can be parallelized, and then execute them.

## Calling `bsb -make-world` in Melange

Melange keeps all user-facing interfaces compatible with ReScript. For the build system, this means preserving `bsconfig.json` as the way to describe how an application should be built.

However, Melange replaces `bsb` behavior almost completely. When a Melange user runs `bsb -make-world`, instead of generating rules in a format that Ninja can understand —like ReScript does—, Melange version of `bsb` will generate rules in a format that Dune can understand. Instead of generating a `build.ninja` file, Melange `bsb` generates a `dune.bsb` file using Dune [stanzas](https://dune.readthedocs.io/en/stable/dune-files.html#stanza-reference).

After this `dune.bsb` file has been generated, the second part of `bsb -make-world` is to run the `dune build @bsb_world` command, which happens implicitly. This command leverages Dune [aliases](https://dune.readthedocs.io/en/stable/dune-files.html#alias) to build exclusively the rules that have been generated from the `bsconfig.json` file, and not more. At the point where this command is called, Melange defers to Dune the execution of these rules, the same way ReScript defers to Ninja, so the same kind of optimizations can be performed: incremental builds, parallelization, etc.

In subsequent builds, users can decide to not call `bsb -make-world` and instead call `dune build @bsb_world` directly, to skip the `dune.bsb` file creation step if the original `bsconfig.json` has not changed.