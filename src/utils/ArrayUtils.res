let flatten = a => a |> Js.Array.reduce((flat, next) => flat |> Js.Array.concat(next), [])

let isEmpty = a => Js.Array.length(a) == 0

let isNotEmpty = a => !isEmpty(a)
