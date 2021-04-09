<h1 data-nav-order="2050-02-01">Dune integration</h1>

```ocaml
let rec sort = function
  | [] -> []
  | x :: l -> insert x (sort l)
and insert elem = function
  | [] -> [elem]
  | x :: l -> if elem < x then elem :: x :: l
else x :: insert elem l
```
