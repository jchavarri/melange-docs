<h1 data-nav-order="41">Interop</h1>

"Interop" (short for "interoperability"), in the context of Melange, means communicating with JavaScript. 

## Variables

Most variables' name compile to clean JavaScript names. `hello` compiles to `hello`. See the output below:

```ocaml
let t = "2"

let u = 3
```

## Data Structures

Major data structures in Melange map over cleanly to JavaScript. For example, a Melange string is a JavaScript string. A Melange array is a JavaScript array. The following Melange code:

```ocaml
let messages = [| "hello"; "world"; "how"; "are"; "you" |]
```

This behavior doesn't hold for complex data structures; the dedicated sections for each offer more info.

## Functions

In most cases, you can directly call a JavaScript function from Melange, and vice-versa.

## Module/File

Every `let` declarations in a Melange file is exported by default and usable from JavaScript. For the other way around, you can declare in a Melange file what JavaScript module you want to use inside Melange. Melange can both output and consume CommonJS and ES6 modules.

<!-- TODO: add default export explaination >
<!-- TODO: playground link -->

## Build system

Melange leverages Dune to build the projects, and it will generate simple rules that call `bsc` behind the scenes.

Each `.ml` (or `.re`) file compiles to one `.bs.js` file. The output files will be put out of source, into the `_build` folder, by Dune.