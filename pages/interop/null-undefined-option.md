<h1 data-nav-order="370">Null, Undefined & Option</h1>

Melange itself doesn't have the notion of `null` or `undefined`. This is a _great_ thing, as it wipes out an entire category of bugs. No more `undefined is not a function`, and `cannot access foo of undefined`!

However, the **concept** of a potentially nonexistent value is still useful, and safely exists in our language.

We represent the existence and nonexistence of a value by wrapping it with the `option` type. Here's its definition from the standard library:

```ocaml
type 'a option =
  | None
  | Some of 'a
```

It means "a value of type option is either `None` (nothing) or that actual value wrapped in a `Some`". You might wonder why we can't drop that `Some` wrapper and just do the following:

```ocaml-invalid
type 'a option = None | 'a
```

So that the value can be either `None` or `theActualValue`. While convenient, there are many reasons why this is undesirable later on. We'll spare the explanation here.

## Example

Here's a normal value:

```ocaml
let licenseNumber = 5
```

To represent the concept of "maybe null", you'd turn this into an `option` type by wrapping it. For the sake of a more illustrative example, we'll put a condition around it:

```ocaml
let personHasACar = true
let licenseNumber =
  if personHasACar then
    Some(5)
  else
    None
```

Later on, when another piece of code receives such value, it'd be forced to handle both cases:

```ocaml
let licenseNumber = Some 90210
let () = match licenseNumber with
| None -> print_endline "The person doesn't have a car"
| Some(number) -> print_endline ("The person's license number is " ^ (string_of_int number))
```

By turning your ordinary number into an `option` type, and by forcing you to handle the `None` case, the language effectively removed the possibility for you to mishandle, or forget to handle, a conceptual `null` value!

## Usage

**The `Option` helper module** is [here](https://bucklescript.github.io/bucklescript/api/Belt.Option.html).

## Interoperate with JavaScript `undefined` and `null`

The `option` type is common enough that we special-case it when compiling to JavaScript:

```ocaml
let t = Some 5
```

simply compiles down to `5`, and

```ocaml
let t = None
```

compiles to `undefined`! If you've got e.g. a string in JavaScript that you know might be `undefined`, type it as `option(string)` and you're done! Likewise, you can send a `Some(5)` or `None` to the JS side and expect it to be interpreted correctly =)

### Caveat 1

The option-to-undefined translation isn't perfect, because on our side, `option` values can be composed:

```ocaml
let u = Some (Some (Some 5))
let () = Js.log(u)
```

This still compiles to `5`, but this gets troublesome:

```ocaml
let u = Some None
let () = Js.log(u)
```

This is compiled into the following JS:

```javascript
let _ = Js_primitive.some(undefined);
```

What's this `Js_primitive` thing? Why can't this compile to `undefined`? Long story short, when dealing polymorphic `option` type (aka `option('a)`, for any `'a`), many operations become tricky if we don't mark the value with some special annotation. If this doesn't make sense, don't worry; just remember the following rule:

- **Never, EVER, pass a nested `option` value (e.g. `Some(Some(Some(5)))`) into the JS side.**
- **Never, EVER, annotate a value coming from JS as `option('a)`. Always give the concrete, non-polymorphic type.**

### Caveat 2

Unfortunately, lots of times, your JavaScript value might be _both_ `null` or `undefined`. In that case, you unfortunately can't type such value as e.g. `option(int)`, since our `option` type only checks for `undefined` and not `null` when dealing with a `None`.

#### Solution: More Sophisticated `undefined` & `null` Interop

To solve this, we provide access to more elaborate `null` and `undefined` helpers through the [`Js.Nullable`](https://bucklescript.github.io/bucklescript/api/Js.Nullable.html) module. This somewhat works like an `option` type, but is different from it.

#### Examples

To create a JS `null`, use the value `Js.Nullable.null`. To create a JS `undefined`, use `Js.Nullable.undefined` (you can naturally use `None` too, but that's not the point here; the `Js.Nullable.*` helpers wouldn't work with it).

If you're receiving, for example, a JS string that can be `null` and `undefined`, type it as:

```ocaml
external myId: string Js.Nullable.t = "myId" [@@bs.module "MyConstant"]
```

To create such a nullable string from our side (presumably to pass it to the JS side, for interop purpose), do:

```ocaml
external validate: string Js.Nullable.t -> bool = "validate" [@@bs.module "MyIdValidator"]
let personId: string Js.Nullable.t = Js.Nullable.return "abc123"

let result = validate personId
```

The `return` part "wraps" a string into a nullable string, to make the type system understand and track the fact that, as you pass this value around, it's not just a string, but a string that can be `null` or `undefined`.

The `.t` in `Js.Nullable.t` is an OCaml convention.
`Js.Nullable.t` denotes the primary data type that module `Js.Nullable` operates on.
Most of the time, this `t` type is also usually an [abstract type](https://reasonml.github.io/docs/en/module#creation-1) i.e. you do not know (and should not have to know) the internal representation of `t`.
However, in the case of `Js.Nullable.t('a)`, you can guess that it's something a long the line of `type Js.Nullable.t('a) = Js.Nullable.null | Js.Nullable.undefined | Some('a)`.

#### Convert to/from `option`

`Js.Nullable.fromOption` converts from a `option` to `Js.Nullable.t`. `Js.Nullable.toOption` does the opposite.
