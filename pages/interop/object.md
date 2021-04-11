<h1 data-nav-order="380">Object</h1>

# Bind to JS Object

JavaScript objects are a combination of several use-cases:

- As a "record" or "struct" in other languages (like OCaml and C).
- As a hash map.
- As a class.
- As a module to import/export.

Melange cleanly separates the binding methods for JS object based on these 4 use-cases. This page documents the first three. Binding to JS module objects is described in the [Import from/Export to JS](import-from-export-to-js.md) section.

<!-- TODO: mention scope here too? -->

## Bind to Record-like JavaScript Objects

### Bind Using Melange Record

If your JavaScript object has fixed fields, then it's conceptually like an OCaml record. Since an OCaml record compiles to a JavaScript object, you can type a JavaScript object as an OCaml record.

```ocaml example
type person = {
  name: string;
  friends: string array;
  age: int;
}

external john: person = "john" [@bs.module "MySchool"]

let johnName = john.name
```

External is documented [here](external.md). `@module` is documented [here](import-from-export-to-js.md).

### Bind Using a `Js.t` Object

Alternatively, you can use [OCaml object](https://ocaml.org/manual/objectexamples.html) to model a JavaScript object too. In particular, Melange exposes a type `'a Js.t` that will be transformed into plain JavaScript objects:

```ocaml example
type person = <
  name: string ;
  friends: string array;
  age: int
> Js.t

external john : person = "john" [@@module "MySchool"]
let johnName = john##name
```

One of the main differences with records is that objects don't require a previous type declaration, so one can just inline values as needed, which is useful for prototyping.

### Bind Using Special Getter and Setter Attributes

Alternatively, you can use `get` and `set` to bind to individual fields of a JS object:

```ocaml
type textarea
external setName : textarea -> string -> unit = "name" [@@bs.set]
external getName : textarea -> string = "name" [@@bs.get]
```

You can also use `get_index` and `set_index` to access a dynamic property or an index:

```ocaml
type t
external create : int -> t = "Int32Array" [@@bs.new]
external get : t -> int -> int = "" [@@bs.get_index]
external set : t -> int -> int -> unit = "" [@@bs.set_index]

let _ =
  let i32arr = (create 3) in
  set i32arr 0 42;
  Js.log (get i32arr 0)
```

## Bind to Hash Map-like JS Object

If your JavaScript object:

- might or might not add/remove keys
- contains only values that are of the same type

<!-- TODO: add link to Js.Dict -->
Then it's not really an object, it's a hash map. Use `Js.Dict`, which contains operations like `get`, `set`, etc. and cleanly compiles to a JavaScript object still.

## Bind to a JS Object That's a Class

Use `new` to emulate e.g. `new Date()`:

```ocaml
type t

external createDate : unit -> t = "Date" [@@bs.new ]
let date = createDate ()
```

You can chain `new` and `module` if the JS module you're importing is itself a class:

```ocaml
type t;
[@bs.new] [@bs.module] external book: unit => t = "Book";
let myBook = book();
```