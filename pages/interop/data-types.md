<h1 data-nav-order="340">Representation of Types</h1>

## Types Representation

Melange's primitives such as `string`, `float`, `array` compile to the exact same types in JavaScript.

This means that if you receive e.g. a string from the JavaScript side, you can use it without conversion on the Melange side, and vice-versa.

<!-- TODO change link once docs become available -->
<!-- **Melange uses the same standard library as OCaml**; see the docs [here](https://reasonml.github.io/api/) (in Reason syntax). Additionally, we provide access to all the familiar JavaScript primitives [here](https://bucklescript.github.io/bucklescript/api/Js). You can mix and match these two. -->

### String

Immutable on both sides, as expected. [Melange String API](https://reasonml.github.io/api/String.html). [JavaScript String API](https://bucklescript.github.io/bucklescript/api/Js.String.html).

#### Unicode Support

OCaml string is an immutable byte sequence. If the user types some unicode:

```ocaml
Js.log "你好"
```

Which gives you cryptic console output. To rectify this, Melange exposes a special `js` annotation to the default [quoted string syntax](https://reasonml.github.io/docs/en/string-and-char.html#quoted-string) built into the language. Use it like this:

```ocaml
Js.log {js|你好，
世界|js}
```

#### Interpolation

For convenience, we also expose another special tag quoted string annotation, `j`, which supports the equivalent of JavaScript' string interpolation, but for variables only (not arbitrary expressions):

```ocaml
let world = {j|世界|j}
let helloWorld = {j|你好，$world|j}
```

You can surround the variable in parentheses too: `{j|你好，$(world)|j}`.

### Float

Melange floats are JavaScript numbers, vice-versa. The OCaml standard library doesn't come with a Float module. JavaScript Float API is [here](https://bucklescript.github.io/bucklescript/api/Js.Float.html).

### Int

**Ints are 32-bits**! Be careful, you can potentially treat them as JavaScript numbers and vice-versa, but if the number's large, then you better treat JavaScript numbers as floats. For example, we bind to Js.Date using `float`s. Js Int API [here](https://bucklescript.github.io/bucklescript/api/Js.Int.html).

### Array

Idiomatic OCaml arrays are supposed to be fix-sized. This constraint is relaxed on the Melange size. You can change its length using the usual [JavaScript Array API](https://bucklescript.github.io/bucklescript/api/Js.Array.html#VALdefault). Melange's own Array API is [here](https://reasonml.github.io/api/Array.html).

### Tuple

OCaml tuples are compiled to JavaScript arrays. This is convenient when interop-ing with a JavaScript array that contains heterogeneous values, but happens to have a fixed length.

### Bool

OCaml/Reason bool compiles to JavaScript boolean.

## Records

OCaml records map directly to JavaScript objects. If records contain any Non-Shared data types (like variants), then these values must be transformed separately and cannot be directly used in JavaScript.

## Non-shared Data Types

Variants (including `option` and `list`), Melange objects and others can be exported as well, but their representation might change in the future, so one should not rely on it on the JavaScript side. The reason is that if this internal representation changes at some point, your JavaScript code will break.

However, for Melange related data types, we provide [generation of converters and accessors](generate-converters-accessors.md). Once you convert e.g. variants to a string, you can naturally use them on the JavaScript side.

For list, use `Array.of_list` and `Array.to_list` in the [Array](https://reasonml.github.io/api/Array.html) module. `option` will be highlighted shortly later on and also has [its dedicated section](/docs/en/null-undefined-option) as well.

For a seamless JavaScript / TypeScript / Flow integration experience, you might
want to use [genType](https://github.com/cristianoc/gentype) instead of doing
conversion by hand.

### Design Decisions

As to why we don't compile list to JavaScript array or vice-versa, it's because OCaml array and JavaScript array share similar characteristics: mutable, similar read/write performance, etc. List, on the other hand, is immutable and has different access perf characteristics.

The same justification applies for records. OCaml records are fixed, nominally typed, and in general doesn't work well with JavaScript objects. We do provide excellent facilities to bind to JavaScript objects in the [object section](object.md).

<!-- TODO: playground link -->

## Cheat Sheet

### Shared

 <table style="width:100%">
  <tr>
    <th style="text-align: left">OCaml/Melange Type</th>
    <th style="text-align: left">JavaScript Type</th>
  </tr>
  <tr>
    <td style="text-align: left">int</td>
    <td style="text-align: left">number</td>
  </tr>
  <tr>
    <td style="text-align: left">nativeint</td>
    <td style="text-align: left">number</td>
  </tr>
  <tr>
    <td style="text-align: left">int32</td>
    <td style="text-align: left">number</td>
  </tr>
  <tr>
    <td style="text-align: left">float</td>
    <td style="text-align: left">number</td>
  </tr>
  <tr>
    <td style="text-align: left">string</td>
    <td style="text-align: left">string</td>
  </tr>
  <tr>
    <td style="text-align: left">array</td>
    <td style="text-align: left">array</td>
  </tr>
  <tr>
    <td style="text-align: left">tuple</td>
    <td style="text-align: left">array</td>
  </tr>
  <tr>
    <td style="text-align: left">bool</td>
    <td style="text-align: left">boolean</td>
  </tr>
  <tr>
    <td style="text-align: left">Js.Nullable.t</td>
    <td style="text-align: left"><code>null</code>/<code>undefined</code></td>
  </tr>
  <tr>
    <td style="text-align: left">option</td>
    <td style="text-align: left"><code>None</code>-><code>undefined</code></td>
  </tr>
  <tr>
    <td style="text-align: left">option</td>
    <td style="text-align: left"><code>null</code>/<code>undefined</code></td>
  </tr>
  <tr>
    <td style="text-align: left">option</td>
    <td style="text-align: left"><code>null</code>/<code>undefined</code></td>
  </tr>
  <tr>
    <td style="text-align: left">record</td>
    <td style="text-align: left"><code>null</code>/<code>undefined</code></td>
  </tr>
</table> 

<!-- Markdown tables are not supported in omd

OCaml/Melange/Reason Type | JavaScript Type
---------------------|---------------
int | number
nativeint | number
int32 | number
float | number
string | string
array | array
tuple | array. `(3, 4)` -> `[3, 4]`
bool | boolean
Js.Nullable.t | `null`/`undefined`
option | `None` -> `undefined`
option | `Some( Some .. Some (None))` -> internal representation
option | `Some other` -> other
record | object. `{x: 1; y: 2}` -> `{x: 1, y: 2}`
special `bs.deriving abstract` record | object -->

### Non-shared

Again, the representations are subject to change.

OCaml/Melange/Reason Type | JavaScript Value
---------------------|---------------
int64 | array. [high, low]. high is signed, low unsigned
char | `'a'` -> `97`
bytes | number array (we might encode it as buffer in NodeJS)
list | `[]` -> `0`, `[x, y]` -> `[x, [y, 0]]`, `[1, 2, 3]` -> `[ 1, [ 2, [ 3, 0 ] ] ]`
Variant | \*
Polymorphic variant | \*\*
exception | -
extension | -
object | -

\* Variants with a single non-nullary constructor:

```ocaml
type tree = Leaf | Node of int * tree * tree
(* Leaf -> 0 *)
(* Node a b c -> [a, b, c] *)
```

Variants with more than one non-nullary constructor:

```ocaml
type u = A of string | B of int
(* A a -> [a].tag = 0 -- tag 0 assignment is optional *)
(* B b -> [b].tag = 1 *)
```

\*\* Polymorphic Variant:

```ocaml
`a (* 97 *)
`a (1, 2) (* [ 97, [1, 2] ] *)
```

Melange compiles `unit` to `0` in some cases but don't worry about it because it's considered internal and subject to change.
