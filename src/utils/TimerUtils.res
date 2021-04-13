let timer = ref(Js.Nullable.null)

let setTimeout = (work, seconds) => {
  Js.Nullable.iter(timer.contents, (. timer) => Js.Global.clearTimeout(timer))
  timer := Js.Nullable.return(Js.Global.setTimeout(work, seconds * 100))
}
