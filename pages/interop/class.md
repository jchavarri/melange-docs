<h1 data-nav-order="390">Class</h1>

## `new`

Use `bs.new` to emulate e.g. `new Date()`:

```ocaml
type t
external createDate : unit -> t = "Date" [@@bs.new]

let date = createDate ()
```

You can chain `bs.new` and `bs.module` if the JavaScript module you're importing is itself a class:

```ocaml
type t
external book : unit -> t = "Book" [@@bs.new] [@@bs.module]
let bookInstance = book ()
```

## Bind to JavaScript Classes

JavaScript classes are really just JavaScript objects wired up funnily. In most cases it is possible to use the previous object section's features to bind to a JavaScript object.

OCaml having classes really helps with modeling JavaScript classes. Just add a `[@bs]` to a class type to turn them into a `Js.t` class:

```ocaml
class type _rect = object
  method height : int [@@bs.set]
  method width : int [@@bs.set]
  method draw : unit -> unit
end [@bs]

type rect = _rect Js.t
```

For `Js.t` classes, methods with arrow types are treated as real methods (automatically annotated with `[@bs.meth]`) while methods with non-arrow types are treated as properties. Adding `bs.set` to those methods will make them mutable, which enables you to set them using `#=` later. Dropping the `bs.set` attribute makes the method/property immutable. Basically like the object section's features.
