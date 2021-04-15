#!/usr/bin/env bash

set -e -o pipefail

# Some externals that are referenced multiple times in pipe first section
pipefirst_prelude="
external map : 'a array -> ('a -> 'b) -> 'b array = \"map\" [@@bs.send]
external filter : 'a array -> ('a -> 'b) -> 'b array = \"filter\" [@@bs.send]

type request'
external asyncRequest: unit -> request' = \"asyncRequest\"
external setWaitDuration: request' -> int -> request' = \"setWaitDuration\" [@@bs.send]
external send: request' -> unit = \"send\" [@@bs.send]
"

snippet="$pipefirst_prelude $(cat -)"

echo "$snippet" > $1 && bsc -bs-no-version-header $1 | tr "\n" "\f" | sed -e "s/^[[:space:]]*'use strict';//" | sed -e "s/exports\..*//" | sed "s/\(.*\)/<code class=\"output-language-javascript\">\1<\/code>/" | tr "\f" "\n"

