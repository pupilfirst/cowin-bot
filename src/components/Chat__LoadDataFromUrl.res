let str = React.string

type state = {
  loading: bool,
  data: array<string>,
  hasErrors: bool,
}

type action =
  | SetLoading
  | SetData(array<string>)
  | SetError

let reducer = (state, action) =>
  switch action {
  | SetLoading => {...state, loading: true}
  | SetError => {...state, hasErrors: true, loading: false}
  | SetData(data) => {...state, data: data, loading: false}
  }

let responseCB = (send, json) => {
  let data = Json.Decode.field("content", Json.Decode.string, json)
  let base64DecodedData = Webapi.Base64.atob(data)
  let dataArray = Js.Array.filter(f => f !== "", ParseMD.parse(base64DecodedData))
  send(SetData(dataArray))
}

let importData = (slug, send) => {
  let url = "https://api.github.com/repos/pupilfirst/cowinindia.org/contents/" ++ slug
  send(SetLoading)
  let errorCB = _d => send(SetError)
  Api.get(url, responseCB(send), errorCB)
}

let initialState = () => {
  data: [],
  loading: false,
  hasErrors: false,
}

@react.component
let make = (~slug) => {
  let (state, send) = React.useReducer(reducer, initialState())
  React.useEffect0(() => {
    importData(slug, send)
    None
  })

  {
    Js.Array.mapi(
      (d, i) =>
        <div
          className="t-border t-rounded-lg t-shadow t-inline-flex t-px-4 t-py-1 t-text-md t-text-white t-bg-blue-700">
          {str(d)}
        </div>,
      state.data,
    )->React.array
  }
}
