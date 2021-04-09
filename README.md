# melange.re

This is the documentation site for the [Melange](https://github.com/melange-re/melange) project.

## Building

`esy` to download all dependencies.

`make all` to build assets.

`make serve` to start local server.

## Tools

This project uses:
- [soupault](https://soupault.app) as static site generator
- [omd](https://github.com/ocaml/omd) extensible markup library in pure OCaml
- [Just the docs](https://pmarsceill.github.io/just-the-docs/) a Jekyll theme for documentation sites, adapted for Soupault.
- [prism.js](https://prismjs.com/) to highlight syntax (at build time, through Node.js script)