let flatten = a => a |> Js.Array.reduce((flat, next) => flat |> Js.Array.concat(next), [])
