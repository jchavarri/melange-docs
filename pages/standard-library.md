<h1 data-nav-order="700">Standard library</h1>

Melange is mostly just OCaml, so they share the same standard library:

* [OCaml syntax standard library documentation](https://ocaml.org/releases/4.12/htmlman/stdlib.html).
* [Reason syntax standard library documentation](https://reasonml.github.io/api/index.html). Note the Reason documentation might not be updated to the latest version of the compiler.

Melange only supports at the moment OCaml v4.12.

In addition, Melange provides a few extra modules:

<!-- TODO: fix api links -->

- [Belt](https://rescript-lang.org/docs/manual/latest/api/belt): the standard library. This standard library provides useful functions in addition to the OCaml standard library.
- [Dom](https://rescript-lang.org/docs/manual/latest/api/dom): contains DOM types. The DOM is very hard to bind to, so we've decided to only keep the types in the stdlib and let users bind to the subset of DOM they need downstream.
- [Js](https://rescript-lang.org/docs/manual/latest/api/js): all the familiar JS APIs and modules are here! E.g. if you want to use the [JS Array API](https://rescript-lang.org/docs/manual/latest/api/js/array) over the [OCaml Array API](https://ocaml.org/releases/4.12/api/Array.html) because you're more familiar with the former, go ahead.

The full index of modules is available at: https://rescript-lang.org/docs/manual/latest/api.