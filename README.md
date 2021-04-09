# melange.re

This is the documentation site for the [Melange](https://github.com/melange-re/melange) project.

## Building

`esy` to download OCaml dependencies.

`yarn` to download JavaScript dependencies.

`make gen_index` to extract site index first without generating pages.

`make all` to build site and copy assets to build folder.

`make serve` to start local server.

Then open `http://localhost:8000`.

## Tools

This project uses:
- [soupault](https://soupault.app) as static site generator
- [omd](https://github.com/ocaml/omd) extensible markup library in pure OCaml
- [Just the docs](https://pmarsceill.github.io/just-the-docs/) a Jekyll theme for documentation sites, adapted for Soupault.
- [prism.js](https://prismjs.com/) to highlight syntax (at build time, through Node.js script)