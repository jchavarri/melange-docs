<h1 data-nav-order="360">Bind to global values</h1>

Do you want to use `window`? Or `Math`? Or anything that you don't have to first `import` or `require` in JavaScript? This section describes how to access those from Melange.

Now, here's how you bind to a JS value:

```ocaml
external setTimeout : (unit -> unit) -> int -> float = "setTimeout" [@@bs.val]
external clearTimeout : float -> unit = "clearTimeout" [@@bs.val]
```

This binds to the JavaScript [`setTimeout`](https://developer.mozilla.org/en-US/docs/Web/API/WindowOrworkerGlobalScope/setTimeout) methods and the corresponding `clearTimeout`. The `external`'s type annotation specifies that `setTimeout`:

- takes a function that accepts `unit` and returns `unit` (which on the JS side turns into a function that accepts nothing and returns nothing. More on modeling functions later)
- and an integer that specifies the duration before calling said function
- returns a number that is the timeout's ID. This number might be big, so we're modeling it as a float rather than the 32-bit int

### Abstract Type

**The above still isn't ideal**. See how `setTimeout` returns a `float` and `clearTimeout` accepts one. There's no guarantee that you're passing the float created by `setTimeout` into `clearTimeout`! For all we know, someone might pass it `Math.random()` into the latter.

We're in a language with a great type system now! Let's leverage a popular feature to solve this problem: abstract types.

```ocaml
type timerId
external setTimeout : (unit -> unit) -> int -> timerId = "setTimeout" [@@bs.val]
external clearTimeout : timerId -> unit = "clearTimeout" [@@bs.val]
```

Clearly, `timerId` is a type that can only be created by `setTimeout`! Now we've guaranteed that `clearTimeout` _will_ be passed a valid ID. Whether it's a number under the hood is now a mere implementation detail.

Inspect the output [here](https://reasonml.github.io/en/try.html?reason=C4TwDgpgBMCWC2EBOBJAJgbgFAG0ACARgM4B0AbgIYA2AulBAB7DIB21UREwAKghAPYBXYFABcUABSCWsEQF4AfFGmyANFFgtgASiiKYfVGj1QARJx58hwU9nzFy1Oo2ZI2VKAGMqECkl6I1mIGiEZ6SiryZt6+-lbCtlhYPiKwxnIcXAECwhISuvoAUqRU-ADmEqYAFhBUpaba6gCMAAwt2thYMX7Z1hJpHUA). It's as clean as hand-written JS code, except you know it comes from correctly typed Melange. If these kind of features are all you use from Melange, you'd already have derived values from them!

This trick is often used to allow folks to agree on _what_ JS functionalities to bind to, without prescribing _how_ to bind to them. For example, the Melange library exposes a few abstract types like [`window`](https://bucklescript.github.io/bucklescript/api/Dom.html#TYPEwindow). The DOM API is _huge_ and extremely hard to bind to correctly; we don't provide an opinionated way of doing it, so exposing the types and allowing you to use them as input/output types of your `external`s and have everyone's opinionated wrapper still agreeing on the types is a great middle-ground. You, for example, might only need 3 methods from DOM, and so wrote your own, thin wrappers for them.

## Global Modules

If you want to bind to a value inside a global module, e.g. `Math.random`, attach a `bs.scope` to your `bs.val` external:

```ocaml
external random: unit -> float = "random" [@@bs.val][@@bs.scope "Math"]
let someNumber = random ()
```

you can bind to an arbitrarily deep object by passing a tuple to `bs.scope`:

```ocaml
external length: int = "length" [@@bs.val][@@bs.scope "window", "location", "ancestorOrigins"]
```

This binds to `window.location.ancestorOrigins.length`.

