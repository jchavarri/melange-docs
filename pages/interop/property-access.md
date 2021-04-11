<h1 data-nav-order="510">Property access</h1>

# Static property access

Binding to Getter/Setter using `bs.get`, `bs.set`.

This attribute helps get and set the property of a JavaScript object.

```ocaml
type textarea
external set_name : textarea -> string -> unit = "name" [@@bs.set]
external get_name : textarea -> string = "name" [@@bs.get]
```

# Dynamic property access

Binding to dynamic property access/set using `bs.set_index`, `bs.get_index`

Input:
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