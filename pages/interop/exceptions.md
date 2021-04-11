<h1 data-nav-order="550">Exceptions</h1>

In the JS world, exception could be any data, while an OCaml exception is a structured data format and supports pattern matching. Catching an OCaml exception on JS side therefore doesn't work as intended.

JS exceptions can be raised from the Melange side by using the [`JS.Exn.raise*`](https://bucklescript.github.io/bucklescript/api/Js.Exn.html) functions, and can be caught as a Melange exception of the type `Js.Exn.Error` with the JS exception as its payload, typed as `Js.Exn.t`. The JS Exception can then either be manipulated with the accessor functions in `Js.Exn`, or casted to a more appropriate type.

```ocaml
try
  Js.Exn.raiseError "oops!"
with
| Js.Exn.Error e ->
  match Js.Exn.message e with
  | Some message -> Js.log {j|Error: $message|j}
  | None -> Js.log "An unknown error occurred"
```

## Usage

Take promise for example:

```ocaml
exception UnhandledPromise

let handlePromiseFailure = function [@bs.open]
  | Not_found ->
    Js.log "Not found";
    Js.Promise.resolve ()

let _ =
 Js.Promise.reject Not_found
 |> Js.Promise.catch (fun error ->
      match handlePromiseFailure error with
      | Some x -> x
      | None -> raise UnhandledPromise
  )
```
