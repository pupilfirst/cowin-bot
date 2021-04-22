let str = React.string

type state = {
  loading: bool,
  saving: bool,
}

type action =
  | SetSaving
  | ClearSaving

let reducer = (state, action) =>
  switch action {
  | SetSaving => {...state, saving: true}
  | ClearSaving => {...state, saving: false}
  }

let computeInitialState = () => {
  loading: false,
  saving: false,
}

let timer = ref(Js.Nullable.null)

let setTimeout = (work, seconds) => {
  Js.Nullable.iter(timer.contents, (. timer) => Js.Global.clearTimeout(timer))
  timer := Js.Nullable.return(Js.Global.setTimeout(work, seconds * 1000))
}

@react.component
let make = (~prompt, ~updateGroupCB) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())
  Js.log(prompt)
  React.useEffect0(() => {
    switch Prompt.action(prompt) {
    | LoadDataFromLink(link) => setTimeout(_ => updateGroupCB("default"), 1)
    | ShowArticleLink(link) => setTimeout(_ => updateGroupCB("default"), 1)
    | ChangeFilterGroup(group) => setTimeout(_ => updateGroupCB(group), 1)
    | NoAction => setTimeout(_ => updateGroupCB("default"), 1)
    }

    None
  })

  {
    switch Prompt.action(prompt) {
    | LoadDataFromLink(slug) => <Chat__LoadDataFromUrl slug={slug} />
    | ShowArticleLink(link) =>
      <div
        className="t-border t-rounded-lg t-shadow t-inline-flex t-px-4 t-py-1 t-text-md t-text-white t-bg-blue-700">
        {str(Prompt.title(prompt))}
      </div>
    | ChangeFilterGroup(string) =>
      <div
        className="t-border t-rounded-lg t-shadow t-inline-flex t-px-4 t-py-1 t-text-md t-text-white t-bg-blue-700">
        {str(Prompt.title(prompt))}
      </div>
    | NoAction =>
      <div
        className="t-border t-rounded-lg t-shadow t-inline-flex t-px-4 t-py-1 t-text-md t-text-white t-bg-blue-700">
        {str(Prompt.title(prompt))}
      </div>
    }
  }
}
