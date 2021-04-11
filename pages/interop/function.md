<h1 data-nav-order="400">Function</h1>

Modeling a JavaScript function is like modeling a normal value:

```ocaml
external encodeURI: string -> string = "encodeURI" [@@bs.val]
let result = encodeURI "hello"
```

Melange also exposes a few special features, described below.

## Labeled Arguments

OCaml has labeled arguments, that can be made optional. These work on an `external` too. You can use them to fix a JavaScript function's unclear usage. Assuming we're modeling this:

```js
function draw(x, y, border) {
   /* border is optional, defaults to false */
}
draw(10, 20)
draw(20, 20, true)
```

It'd be nice if on the Melange side, we can bind & call `draw` while labeling things a bit:

```ocaml
external draw: x:int -> y:int -> ?border:bool -> unit -> unit = "draw" [@@bs.val]

let _ = draw ~x:10 ~y:20 ~border:true ()
let _ = draw ~x:10 ~y:20 ()
```

We've compiled to the same function, but now the usage is much clearer on the Melange side thanks to labels!

**Note**: in this particular case, you need a unit, `()` after `border`, since `border` is an [optional argument at the last position](https://reasonml.github.io/docs/en/function.html#optional-labeled-arguments). Not having a unit to indicate you've finished applying the function would generate a warning.

Note that you can change the order of labeled arguments on the Melange side and it will ensure that they appear the right way in the JavaScript output:

```ocaml
external draw: x:int -> y:int -> ?border:bool -> unit -> unit = "draw" [@@bs.val]
let _ = draw ~x:10 ~y:20 ()
let _ = draw ~y:20 ~x:10 ()
```

## Object Method

Functions attached to a JavaScript object require a special way of binding to it, using `bs.send`:

```ocaml
type document (* abstract type for a document object *)
external getElementById: document -> string -> Dom.element = "getElementById" [@@bs.send]
external doc: document = "document" [@@bs.val]

let el = getElementById doc "myId"
```

In a `bs.send`, the object is always the first argument. Actual arguments of the method follow (this is a bit what modern OOP objects are really).

### Chaining

Ever used `foo().bar().baz()` chaining ("fluent api") in JavaScript OOP? We can model that in Melange too, through the Pipe First operator described in the next section.

## Variadic Function Arguments

You might have JavaScript functions that take an arbitrary amount of arguments. Melange supports modeling those, under the condition that the arbitrary arguments part is homogenous (aka of the same type). If so, add `bs.variadic` (was `bs.splice` prior to version 4.08) to your `external`.

```ocaml
external join: string array -> string = "join" [@@bs.module "path"] [@@bs.variadic]
let v = join [| "a"; "b"|]
```

_`bs.module` will be explained in the Import & Export section next_.

## Modeling Polymorphic Function

Apart from the above special-case, JavaScript function in general are often arbitrary overloaded in terms of argument types and number. How would you bind to those?

### Trick 1: Multiple `external`s

If you can exhaustively enumerate the many forms an overloaded JavaScript function can take, simply bind to each differently:

```ocaml
external drawCat: unit -> unit = "draw" [@@bs.module "Drawing"]
external drawDog: giveName:string -> unit = "draw" [@@bs.module "Drawing"]
external draw : string -> useRandomAnimal:bool -> unit = "draw" [@@bs.module "Drawing"]
```

Note how all three externals bind to the same JavaScript function, `draw`.

### Trick 2: Polymorphic Variant + `bs.unwrap`

If you have the irresistible urge of saying "if only this JavaScript function argument was a variant instead of informally being either `string` or `int`", then good news: we do provide such `external` features through annotating a parameter as a polymorphic variant! Assuming you have the following JavaScript function you'd like to bind to:

```js
function padLeft(value, padding) {
  if (typeof padding === "number") {
    return Array(padding + 1).join(" ") + value;
  }
  if (typeof padding === "string") {
    return padding + value;
  }
  throw new Error(`Expected string or number, got '${padding}'.`);
}
```

Here, `padding` is really conceptually a variant. Let's model it as such.

```ocaml
external padLeft:
  string
  -> ([ `Str of string
      | `Int of int
      ] [@bs.unwrap])
  -> string
  = "padLeft" [@@bs.val]

let _ = padLeft "Hello World" (`Int 4)
let _ = padLeft "Hello World" (`Str "Message from Melange: ")
```

The JavaScript side can not have an argument that is a polymorphic variant. But here, we are leveraging poly variants' type checking and syntax. The secret is the `[@bs.unwrap]` annotation on the type. It strips the variant constructors and compile to just the payload's value.

## Constrain Arguments Better

Consider the Node `fs.readFileSync`'s second argument. It can take a string, but really only a defined set: `"ascii"`, `"utf8"`, etc. You can still bind it as a string, but we can use poly variants + `bs.string` to ensure that our usage's more correct:

```ocaml
external readFileSync:
  name:string ->
  ([ `utf8
   | `useAscii [@bs.as "ascii"]
   ] [@bs.string]) ->
  string = "readFileSync"
  [@@bs.module "fs"]

let _ = readFileSync ~name:"xx.txt" `useAscii
```

- Attaching `[@bs.string]` to the whole poly variant type makes its constructor compile to a string of the same name.
- Attaching a `[@bs.as "foo"]` to a constructor lets you customize the final string.

And now, passing something like `"myOwnUnicode"` or other variant constructor names to `readFileSync` would correctly error.

Aside from string, you can also compile an argument to an int, using `bs.int` instead of `bs.string` in a similar way:

```ocaml
external test_int_type:
  ([ `on_closed
   | `on_open [@bs.as 20]
   | `in_bin
   ]
   [@bs.int]) -> int =
  "test_int_type" [@@bs.val]

let _ = test_int_type `in_bin
```

`on_closed` will compile to `0`, `on_open` to `20` and `in_bin` to **`21`**.

## Special-case: Event Listeners

One last trick with polymorphic variants:

```ocaml
type readline

external on:
  readline
  -> ([
      |`close of unit -> unit
      | `line of string -> unit
      ] [@bs.string])
  -> readline = "on" [@@bs.send]

let register rl =
  rl
  |. on (`close (fun event -> ()))
  |. on (`line (fun line -> print_endline line))
```

<!-- TODO: GADT phantom type -->

## Fixed Arguments

Sometimes it's convenient to bind to a function using an `external`, while passing predetermined argument values to the JavaScript function:

```ocaml
external process_on_exit:
  (_ [@bs.as "exit"]) ->
  (int -> unit) ->
  unit =
  "process.on" [@@bs.val]

let () = process_on_exit (fun exit_code ->
  Js.log ("error code: " ^ string_of_int exit_code)
)
```

The `[@bs.as "exit"]` and the placeholder `_` argument together indicates that you want the first argument to compile to the string `"exit"`. You can also use any JSON literal with `bs.as`: `[@bs.as {json|true|json}]`, `[@bs.as {json|{"name": "John"}|json}]`, etc.

## Curry & Uncurry

Curry is a delicious Indian dish. More importantly, in the context of Melange (and functional programming in general), currying means that function taking multiple arguments can be applied a few arguments at time, until all the arguments are applied.

```ocaml
let add x y z = x + y + z
let addFive = add 5
let twelve = addFive 3 4
```

See the `addFive` intermediate function? `add` takes in 3 arguments but received only 1. It's interpreted as "currying" the argument `5` and waiting for the next 2 arguments to be applied later on. Type signatures:

```ocaml
val add: int -> int -> int -> int
val addFive: int -> int -> int
val twelve: int
```

(In a dynamic language such as JavaScript, currying would be dangerous, since accidentally forgetting to pass an argument doesn't error at compile time).

### Drawback

Unfortunately, due to JavaScript not having currying because of the aforementioned reason, it's hard for Melange multi-argument functions to map cleanly to JavaScript functions 100% of the time:

1. When all the arguments of a function are supplied (aka no currying), Melange does its best to to compile e.g. a 3-arguments call into a plain JavaScript call with 3 arguments.

2. If it's too hard to detect whether a function application is complete\*, Melange will use a runtime mechanism (the `Curry` module) to curry as many args as we can and check whether the result is fully applied.

3. Some JavaScript APIs like `throttle`, `debounce` and `promise` might mess with context, aka use the function `bind` mechanism, carry around `this`, etc. Such implementation clashes with the previous currying logic.

\* If the call site is typed as having 3 arguments, we sometimes don't know whether it's a function that's being curried, or if the original one indeed has only 3 arguments.

Melange tries to do #1 as much as it can. Even when it bails and uses #2's currying mechanism, it's usually harmless.

**However**, if you encounter #3, heuristics are not good enough: you need a guaranteed way of fully applying a function, without intermediate currying steps. We provide such guarantee through the use of the `[@bs]` "uncurrying" annotation on a function declaration & call site.

### Solution: Guaranteed Uncurrying

If you annotate a function declaration signature on an `external` or `let` with a `[@bs]` (or, in Reason syntax, annotate the start of the parameters with a dot), you'll turn that function into an similar-looking one that's guaranteed to be uncurried:

```ocaml
type timerId
external setTimeout: (unit -> unit [@bs]) -> int -> timerId = "setTimeout" [@@bs.val]

let id = setTimeout (fun [@bs] () -> Js.log "hello") 1000
```

**Note**: both the declaration site and the call site need to have the uncurry annotation. That's part of the guarantee/requirement.

When you try to curry such a function, you'll get a type error:

```ocaml-invalid
let add = fun [@bs] x y z -> x + y + z
let addFiveOops = add 5
```

Error:

```
This is an uncurried Melange function. It must be applied with a `[@bs]`.
```

#### Extra Solution

The above solution is safe, guaranteed, and performant, but sometimes visually a little burdensome. We provide an alternative solution if:

- you're using `external`
- the `external` function takes in an argument that's another function
- you want the user **not** to need to annotate the call sites with `[@bs]` or the dot in Reason

<!-- TODO: is this up-to-date info? -->

Then try `[@bs.uncurry]`:

```ocaml
external map: 'a array -> ('a -> 'b [@bs.uncurry]) -> 'b array = "map" [@@bs.send]
let _ = map [|1; 2; 3|] (fun x -> x+ 1)
```

#### Pitfall

If you try to do this:

```ocaml
let id: ('a -> 'a [@bs]) = ((fun v -> v) [@bs])
```

You’ll get this cryptic error message:

```
Error: The type of this expression, ('_a -> '_a [@bs]),
       contains type variables that cannot be generalized
```

The issue here isn’t that the function is polymorphic. You can use polymorphic uncurried functions as inline callbacks, but you can’t export them (and `let`s are exposed by default unless you hide it with an interface file). The issue here is a combination of the uncurried call, polymorphism and exporting the function. It’s an unfortunate limitation of how OCaml’s type system incorporates side-effects, and how Melange handles uncurrying.

The simplest solution is in most cases to just not export it, by adding an interface to the module. Alternatively, if you really need to export it, you can do so in its curried form, and then wrap it in an uncurried lambda at the call site. E.g.:

```ocaml
let _ = map (fun v -> id v [@bs])
```

##### Design Decisions

In general, `bs.uncurry` is recommended; the compiler will do lots of optimizations to resolve the currying to uncurrying at compile time. However, there are some cases the compiler can't optimize it. In these cases, it will be converted to a runtime check.

This means `[@bs]` are completely static behavior (no runtime cost), while `[@bs.uncurry]` is more convenient for end users but, in some rare cases, might be slower than `[@bs]`.

## Modeling `this`-based Callbacks

Many JavaScript libraries have callbacks which rely on this (the source), for example:

```js
x.onload = function(v) {
  console.log(this.response + v)
}
```

Here, `this` would point to `x` (actually, it depends on how `onload` is called, but we digress). It's not correct to declare `x.onload` of type `unit → unit [@bs]`. Instead, we introduced a special attribute, `bs.this`, which allows us to type `x` as so:

```ocaml
type x
external x: x = "x" [@@bs.val]
external set_onload: x -> (x -> int -> unit [@bs.this]) -> unit = "onload" [@@bs.set]
external resp: x -> int = "response" [@@bs.get]

let _ =
  set_onload x begin fun [@bs.this] o v ->
    Js.log(resp o + v )
  end
```

`bs.this` is the same as `bs`, except that its first parameter is reserved for `this` and for arity of 0, there is no need for a redundant `unit` type.
