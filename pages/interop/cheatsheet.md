<h1 data-nav-order="310">Cheatsheet</h1>

## Raw JS

```ocaml
let add = [%raw "a + b"]
[%%raw "var a = 1"]
```

## String Unicode & Interpolation

```ocaml
Js.log {js|你好，
世界|js}

let world = "world"
let helloWorld = {j|hello, $world|j}
```

## Global Value

```ocaml
external setTimeout : (unit -> unit) -> int -> float = "setTimeout" [@@bs.val]
```

## Global Module

```ocaml
external random: unit -> float = "random" [@@bs.val][@@bs.scope "Math"]
let someNumber = random ()

external length: int = "length" [@@bs.val][@@bs.scope "window", "location", "ancestorOrigins"]
```

## Nullable

```ocaml
let a = Some 5 (* compiles to 5 *)
let b = None (* compiles to undefined *)
```

Handling a value that can be `undefined` and `null`, by ditching the `option` type and using `Js.Nullable.t`:

```ocaml
let jsNull = Js.Nullable.null
let jsUndefined = Js.Nullable.undefined

let result1: string Js.Nullable.t = Js.Nullable.return "hello"
let result2: int Js.Nullable.t  = Js.Nullable.fromOption (Some 10)
let result3: int option  = Js.Nullable.toOption (Js.Nullable.return 10)
```

## Object

### Records as Objects

```ocaml
type action = {
  type_: string [@bs.as "type"];
  username: string;
}
external createAddUser : string -> action = "addUser" [@@bs.module "actions/addUser.js"]
let myAction = createAddUser "arwen")
```

### Hash Map Mode

```ocaml
let myMap = Js.Dict.empty ()
let _ = Js.Dict.set myMap "Allison" 10
```

### Abstract Record Mode

```ocaml
type person = {
  name: string [@bs.optional];
  age: int;
  mutable job: string;
} [@@bs.deriving abstract]

external getNickname: person -> string = "getNickname" [@@bs.send]

external john : person = "john" [@@bs.val]

let age = john |. ageGet
let () = john |. jobSet "Accountant"
let nick = john |. getNickname
```

### New Instance

```ocaml
type t
external createDate : unit -> t = "Date" [@@bs.new]
```

## Function

### Object Method & Chaining

```ocaml
external map : 'a array -> ('a -> 'b) -> 'b array = "map" [@@bs.send]
external filter : 'a array -> ('a -> bool) -> 'a array = "filter" [@@bs.send]

(* 2, 4 *)
let () = [|1; 2; 3|]
  |. map (fun a -> a + 1)
  |. filter (fun a -> a mod 2 = 0)
  |. Js.log
```

### Variadic (was bs.splice prior to version 4.08)

```ocaml
external join : string array -> string = "join" [@@bs.module "path"] [@@bs.variadic]
```

### Polymorphic Function

```ocaml
external drawCat: unit -> unit = "draw" [@@bs.module "Drawing"]
external drawDog: giveName:string -> unit = "draw" [@@bs.module "Drawing"]
```

```ocaml
external padLeft :
  string
  -> ([ `Str of string
      | `Int of int
      ] [@bs.unwrap])
  -> string
  = "padLeft" [@@bs.val]

let _ = padLeft "Hello World" (`Int 4)
```

### Curry/Uncurry

```ocaml
let add = fun [@bs] x y z -> x + y + z
let six = (add 1 2 3) [@bs]
```

## Module

```ocaml
external dirname: string -> string = "dirname" [@@bs.module "path"]
```

### Import module.exports

```ocaml
external simpleFunction: string -> string = "simple-module-that-is-a-function" [@@bs.module]
```

### Import Default

It's important to note that you are not providing the module path to `bs.module`, but instead as the last argument of `external`.

```ocaml
external leftPad: string -> int -> string = "./leftPad" [@@bs.module]
```

Import ES6 default compiled from Babel:

```ocaml
external studentName: string = "default" [@@bs.module "./student"]
```

### Export ES6 default

```ocaml
let default = "Arwen"
```

## Identity External

Final escape hatch converter. Use with care as it converts any type to any other type, bypassing any type checking. Effectively the same as OCaml `Obj.magic`.

```ocaml
external myShadyConversion : foo -> bar = "%identity"
```

---

You can find more examples for the various `bs.*` attributes [here](https://github.com/moroshko/bs-blabla).
