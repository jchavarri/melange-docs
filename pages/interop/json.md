<h1 data-nav-order="560">JSON</h1>

There are several ways to work with JSON right now, that we'll unify and polish very soon.

## Unsafe Conversion

This emulates JavaScript's JSON conversion.

### Parse

Simply use the (last resort) special [identity external](intro-to-external.md#special-identity-external):

```ocaml
type data = {name: string} [@@bs.deriving abstract]
external parseIntoMyData : string -> data = "parse" [@@bs.scope "JSON"][@@bs.val]

let result = parseIntoMyData "{\"name\": \"Luke\"}"
let n = result |. nameGet
```

Output:

```javascript
var result = JSON.parse("{\"name\": \"Luke\"}");
var n = result.name;
```

Where `data` can be any type you assume the JSON is. As you can see, this compiles to a straightforward `JSON.parse` call. As with regular JS, this is convenient, but has no guarantee that e.g. the data is correctly shaped, or even syntactically valid.

### Stringify

Since JSON.stringify is _slightly_ safer than `JSON.parse`, we've provided it out of the box in [Js.Json](https://bucklescript.github.io/bucklescript/api/Js.Json.html#VALstringifyAny). It compiles to `JSON.stringify`.

## Properly Use `Js.Json`

Technically, the correct way to handle JSON is to recursively parse each field, and handle invalid data accordingly. [Js.Json](https://bucklescript.github.io/bucklescript/api/Js.Json.html) provides such low-level building blocks. See the examples in the API docs.

## Higher-level Helpers

We have a community-maintaned, pseudo-official JSON helper library called [bs-json](https://github.com/reasonml-community/bs-json). Those interested in combinators can also check out [JsonCodec](https://github.com/state-machine-systems/JsonCodec). Both provide more convenient JSON parsing/printing helpers that leverage the previous section's low-level API.

We'll provide a better, first-party solution to JSON too in the future. Stay tuned!
