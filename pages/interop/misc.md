<h1 data-nav-order="580">Miscellaneous</h1>

## Browser support and polyfills

Melange compiles to JavaScript **ES5**, with the exception of allowing to compile to ES6 module import/export.

For [old browsers](https://caniuse.com/#search=typed%20array), you also need to polyfill TypedArray. The following OCaml standard library functions require it:

- `Int64.float_of_bits`
- `Int64.bits_of_float`
- `Int32.float_of_bits`
- `Int32.bits_of_float`

If you don't use these functions, you're fine. Otherwise, it'll be a runtime failure.

## Composing `bs` Attributes

As you might have guessed, most `bs.*` attributes can be used together. Here's an extreme example:

Note that `bs.splice` was renamed to `bs.variadic` after version 4.08

```ocaml
external draw: (_ [@bs.as "dog"]) -> int array -> unit = "draw" [@@bs.val] [@@bs.scope "global"] [@@bs.variadic]

let _ = draw [|1;2|]
```

## Safe External Data Handling

In some cases, the data could either come from JS or BS; it's very hard to give precise type information because of this. For example, for an external promise whose creation could come from the JS API, its failed value caused by `Promise.reject` could be of any shape.

Melange provides a solution, `bs.open`, to filter out OCaml structured exception data from the mixed data source. It preserves type safety while allowing you to deal with mixed source. It makes use of OCaml’s extensible variant, so that users can mix values of type `exn` with JS data.

```ocaml
let handleData = function [@bs.open]
 | Invalid_argument _ -> 0
 | Not_found -> 1
 | Sys_error _ -> 2

(* handleData is 'a -> int option *)
```

For any input source, as long as it matches the exception pattern (nested pattern match supported), the matched value is returned, otherwise return `None`.

## NodeJS special variables

NodeJS has several file local variables: `__dirname`, `__filename`, `_module`, and `require`. Their semantics are more like macros instead of functions.

`bs.node` exposes support for these.

```ocaml
let dirname : string option = [%bs.node __dirname]
let filename : string option = [%bs.node __filename]
let _module : Node.node_module option = [%bs.node _module]
let require : Node.node_require option = [%bs.node require]
```
