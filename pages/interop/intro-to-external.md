<h1 data-nav-order="350">Intro to External</h1>

Many parts of the interop system uses a concept called `external`, so we'll specially introduce it here.

`external` is a keyword for declaring a value in Melange/OCaml:

```ocaml
external myCFunction : int -> string = "theCFunctionName"
```

It's like a `let`, except that the body of an external is, as seen above, a string. That string usually has specific meanings depending on the context. For native OCaml, it usually points to a C function of that name. For Melange, these externals are usually decorated with certain `[@bs.blabla]` attributes.

Once declared, you can use an `external` as a normal value.

Melange `external`s are turned into the expected JS values, inlined into their callers during compilation, **and completely erased afterward**. You won't see them in the JS output. It's as if you wrote the generated JS code by hand! No performance cost either, naturally.

**Note**: do also use `external`s and the `[@bs.blabla]` attributes in the interface files. Otherwise the inlining won't happen.

## Special Identity External

One external worth mentioning is the following one:

```ocaml
type foo = string
type bar = int
external dangerZone : foo -> bar = "%identity"
```

This is a final escape hatch which does nothing but convert from the type `foo` to `bar`. In the following sections, if you ever fail to write an `external`, you can fall back to using this one. But try not to.
