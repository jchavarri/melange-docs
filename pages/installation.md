<h1 data-nav-order="200">Installation</h1>

This project is currently unreleased. The easiest way to get started
is to clone the
[basic template](https://github.com/melange-re/melange-basic-template). Before
you do, make sure you have [Esy](https://esy.sh/) installed (`npm install -g esy` should cover
most workflows).

## Existing projects
If you have an existing project, you can get started by adding an `esy.json` file with the following configuration:

```
{
  "name": "my-project",
  "dependencies": {
    "ocaml": "4.12.x",
    "melange": "melange-re/melange"
  },
  "esy": {
    "buildsInSource": "unsafe",
    "build": ["ln -sfn #{melange.install} node_modules/bs-platform"]
  },
  "installConfig": {
    "pnp": false
  }
}
```

Then call `esy x bsb -make-world` to build the project with Melange.

## Help to get started

If you are running into any issues while trying out Melange, Please reach out on the [ReasonML Discord](https://discord.gg/reasonml),
there is a dedicated channel #melange where related discussions happen.