<h1 data-nav-order="320">Embed Raw JavaScript</h1>

Here is a last-resort escape first, that can be useful for prototyping. Here's how you can drop a chunk of JavaScript right into your Melange file:

```ocaml
let add = [%raw {|
  function(a, b) {
    console.log('hello from raw JavaScript!');
    return a + b;
  }
|}]

let _ = Js.log (add 1 2)
```

The `{|foo|}` syntax stands for OCaml's multi-line, ["quoted string"](https://ocaml.org/manual/lex.html#quoted-string-id) syntax. Think of them as the equivalent of JavaScript's template literals. No escaping is needed inside that string.

Note the difference between OCaml and Reason syntax here. `[%raw foo]` allows you to embed an expression. For top-level declarations in OCaml/Reason, use `[%%raw foo]` (two `%`):

```ocaml
[%%raw "var a = 1"]

let f = [%raw "function() {return 1}"]
```

<!-- TODO: add explaination about extension syntax  -->
<!-- TODO: add reason counter part -->

## Debugger

You can also drop a `[%debugger]` expression in a body:

```ocaml
let f x y =
  [%debugger];
  x + y
```

## Detect Global Variables

Melange provides a relatively type safe approach for such use case: `external`. `[%external a_single_identifier]` is a value of type `option`. Example:

```ocaml
let () = match [%external __DEV__] with
| Some _ -> Js.log "dev mode"
| None -> Js.log "production mode"
```
<!-- TODO: change it to `= None` which is more idiomatic -->

Another example:

```ocaml
let () = match [%external __filename] with
| Some f -> Js.log f
| None -> Js.log "non-node environment"
```
