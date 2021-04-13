<h1 data-nav-order="570">Pipe first</h1>

Melange has a special `|.` (or `->` for Reason) pipe syntax for dealing with various situations. This operator has many uses.

## Pipelining

The pipe takes the item on the left and put it as the first argument of the item on the right. Great for building pipelines of data processing:

```ocaml
let foo a b = a + b
let bar a b = a + b
let t = 2
|. foo 3
|. bar
```

is equal to

```ocaml
let foo a b = a + b
let bar a b = a + b
let t = bar(foo 2 3)
```

## JS Method Chaining

JavaScript's APIs are often attached to objects, and often chainable, like so:

```javascript
const result = [1, 2, 3].map(a => a + 1).filter(a => a % 2 === 0);

asyncRequest().setWaitDuration(4000).send();
```

Assuming we don't need the chaining behavior above, we'd bind to each case this using `bs.send` from the previous section:

```ocaml
external map : 'a array -> ('a -> 'b) -> 'b array = "map" [@@bs.send]
external filter : 'a array -> ('a -> 'b) -> 'b array = "filter" [@@bs.send]

type request
external asyncRequest: unit -> request = "asyncRequest"
external setWaitDuration: request -> int -> request = "setWaitDuration" [@@bs.send]
external send: request -> unit = "send" [@@bs.send]
```

You'd use them like this:

```ocaml
let result = filter (map [|1; 2; 3|] (fun a -> a + 1)) (fun a -> a mod 2 = 0)

let () = send(setWaitDuration (asyncRequest()) 4000)
```

This looks much worse than the JS counterpart! Now we need to read the actual logic "inside-out". We also cannot use the `|>` operator here, since the object comes _first_ in the binding. But `|.` and `->` work!

```ocaml
let result = [|1; 2; 3|]
  |. map(fun a -> a + 1)
  |. filter(fun a -> a mod 2 == 0)

let () = asyncRequest () |. setWaitDuration 400 |. send
```

## Pipe Into Variants

This works:

```ocaml
let name = "arwen"
let preprocess name = "name: " ^ name
let result = name |. preprocess |. Some
```

We turn this into:

```ocaml
let name = "arwen"
let preprocess name = "name: " ^ name
let result = Some(preprocess(name))
```
