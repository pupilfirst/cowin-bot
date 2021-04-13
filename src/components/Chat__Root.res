let config = %bs.raw(`require("../data/config.yaml")`)
let data = config->Prompt.makeFromArrayOfObjects

let str = React.string

type state = {
  loading: bool,
  showChat: bool,
  saving: bool,
  userActions: array<Prompt.t>,
  selectedGroup: string,
  messages: array<Message.t>,
}

type action =
  | SetSaving
  | SetLoading
  | ClearSaving
  | ClearLoading
  | ShowChat
  | HideChat
  | ToggleShowChat
  | AppendUserAction(Prompt.t)
  | SetSelectedGroup(string)
  | AppendMessages(Message.t)

let reducer = (state, action) =>
  switch action {
  | SetSaving => {...state, saving: true}
  | ClearLoading => {...state, loading: false}
  | ClearSaving => {...state, saving: false}
  | SetLoading => {...state, loading: true}
  | ShowChat => {...state, showChat: true}
  | HideChat => {...state, showChat: false}
  | ToggleShowChat => {...state, showChat: !state.showChat}
  | AppendUserAction(action) => {
      ...state,
      userActions: Js.Array.concat(state.userActions, [action]),
      messages: Js.Array.concat([Message.addUserInput(Prompt.title(action))], state.messages),
      loading: true,
    }
  | SetSelectedGroup(group) => {...state, selectedGroup: group, loading: false}
  | AppendMessages(message) => {
      ...state,
      messages: Js.Array.concat([message], state.messages),
    }
  }

let computeInitialState = () => {
  loading: false,
  showChat: true,
  saving: false,
  userActions: [],
  selectedGroup: "default",
  messages: [],
}

let handleGithubresponseCB = (send, json) => {
  let data = Json.Decode.field("content", Json.Decode.string, json)
  let base64DecodedData = Webapi.Base64.atob(data)
  let dataArray = Js.Array.filter(f => f !== "", ParseMD.parse(base64DecodedData))

  Js.Array.forEach(d => send(AppendMessages(Message.addBotInput(d))), dataArray)
  send(SetSelectedGroup("default"))
}

let importDataFromGithub = (slug, send) => {
  let url = "https://api.github.com/repos/pupilfirst/cowinindia.org/contents/" ++ slug
  send(SetLoading)
  let errorCB = d => Js.log(d)
  Api.get(url, handleGithubresponseCB(send), errorCB)
}

let filteredActions = (actions, group) => {
  Js.Array.filter(f => Prompt.group(f) == group, actions)
}

let toggleButton = (state, send) => {
  <div className="flex justify-end">
    <button
      onClick={_ => send(ToggleShowChat)}
      className={"bg-blue-600 rounded-full w-16 h-16 my-4 mx-2 flex items-center justify-center cursor-pointer shadow-xl text-white " ++ {
        state.showChat ? "" : "animate-bounce "
      }}>
      {state.showChat
        ? <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            fill="currentColor"
            viewBox="0 0 16 16">
            <path
              fill="currentColor"
              fillRule="evenodd"
              d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z"
            />
          </svg>
        : <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            fill="currentColor"
            viewBox="0 0 16 16">
            <path
              fill="currentColor"
              d="M2 0a2 2 0 0 0-2 2v12.793a.5.5 0 0 0 .854.353l2.853-2.853A1 1 0 0 1 4.414 12H14a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"
            />
          </svg>}
    </button>
  </div>
}

let updateGroup = (send, group) => {
  send(SetSelectedGroup(group))
}

let messageClasses = message => {
  switch Message.by(message) {
  | Bot => "border rounded-lg shadow inline-flex px-4 py-1 text-md text-gray-800 bg-white items-start flex-col"
  | User => "border rounded-lg shadow inline-flex px-4 py-1 text-md text-white bg-blue-700 items-end flex-col"
  }
}
@react.component
let make = () => {
  let (state, send) = React.useReducer(reducer, computeInitialState())
  React.useEffect1(() => {
    ArrayUtils.isEmpty(state.userActions)
      ? ()
      : switch Prompt.action(state.userActions[0]) {
        | LoadDataFromLink(slug) => importDataFromGithub(slug, send)
        | ShowArticleLink(link) => TimerUtils.setTimeout(_ => updateGroup(send, "default"), 10)
        | ChangeFilterGroup(group) => TimerUtils.setTimeout(_ => updateGroup(send, group), 10)
        | NoAction => TimerUtils.setTimeout(_ => updateGroup(send, "default"), 10)
        }

    None
  }, [state.userActions])

  <div className="container fixed bottom-0 right-0 flex flex-col max-w-sm px-2 z-40 w-full">
    {state.showChat
      ? <div
          className=" transition duration-700 ease-in-outbg-white shadow-lg rounded-lg relative overflow-hidden w-full custom-height border">
          <div className=" overflow-y-auto p-4 space-y-4 items-end h-full justify-end">
            <div className="flex flex-col z-10 ml-4 text-white w-full">
              <div className="text-3xl mb-2 text-gray-800"> {str("Hi")} </div>
              <div className="w-60 text-gray-800 text-lg mb-1">
                {str("I'm CoWin your virtual assistant, Lets get started! ")}
              </div>
            </div>
            <div className="space-y-2 flex flex-col">
              {Js.Array.mapi(
                (m, i) =>
                  <div
                    dangerouslySetInnerHTML={"__html": ParseMD.convert(Message.text(m))}
                    className={messageClasses(m)}
                  />,
                state.messages,
              )->React.array}
            </div>
            {ReactUtils.nullIf(
              <div className="space-y-3 flex flex-col w-full items-start">
                {Js.Array.mapi(
                  (p, i) =>
                    <div
                      key={string_of_int(i)}
                      onClick={_ => send(AppendUserAction(p))}
                      className="border rounded-lg shadow inline-flex px-4 py-1 text-md">
                      {Prompt.title(p)->str}
                    </div>,
                  filteredActions(data, state.selectedGroup),
                )->React.array}
              </div>,
              state.loading,
            )}
            {ReactUtils.nullUnless(
              <div className=" flex flex-col w-full items-start">
                <div className="border rounded-lg shadow inline-flex px-4 py-1 text-md">
                  {str("Loading...")}
                </div>
              </div>,
              state.loading,
            )}
          </div>
        </div>
      : React.null}
    {toggleButton(state, send)}
  </div>
}
