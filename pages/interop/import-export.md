<h1 data-nav-order="530">Import and export</h1>

## Export

Melange allows compiling to:

- CommonJS (`require('myFile')`)
- ES6 modules (`import * from 'myFile'`)

The output format is configurable in bsb, described in a later section.
<!-- TODO: bsb link -->

By default, every `let` binding is exported. If their values are safe to use on the JS side, you can directly require the generated JS file and use them (see the JS file itself!).

To only export a few selected `let`s, simply add an [interface file](https://reasonml.github.io/docs/en/module.html#signatures) that hides some of the let bindings.

### Export an ES6 default value

If your JS project is using ES6 modules, you're likely exporting & importing some default values:

```js
// student.js
export default name = "Al";
```

```js
// teacher.js
import studentName from 'student.js';
```

Technically, since a Melange file maps to a module, there's no such thing as "default" export, only named ones. However, we've made an exception to support default module when you do the following:

```ocaml
(* FavoriteStudent.ml *)
let default = "Bob"
```

<!-- TODO: playground link on the result -->

You can then require the default as normal JS side:

```js
// teacher2.js
import studentName from 'FavoriteStudent.js';
```

**Note**: the above JS snippet _only_ works if you're using that ES6 import/export syntax in JS. If you're still using `require`, you'd need to do:

```js
let studentName = require('FavoriteStudent').default;
```

## Import

Use `bs.module`. It's like a `bs.val` that accepts a string that's the module name or path.

```ocaml
external dirname: string -> string = "dirname" [@@bs.module "path"]
let root = dirname "/User/chenglou"
```

**Note**: the string inside `bs.module` can be anything: `"./src/myJsFile"`, `"@myNpmNamespace/myLib"`, etc.

### Import a Default Value

By omitting the payload to `bs.module`, you bind to the whole JS module:

```ocaml
external leftPad: string -> int -> string = "./leftPad" [@@bs.module]
let paddedResult = leftPad "hi" 5
```

#### Import an ES6 Default Value

This is a recurring question, so we'll answer it here. **If your JS project is using ES6**, you're likely using Babel to compile it to regular JavaScript. Babel's ES6 default export actually exports the default value under the name `default`. You'd bind to it like this:

```ocaml
external studentName: string = "default" [@@bs.module "./student"]
let _ = Js.log studentName
```
