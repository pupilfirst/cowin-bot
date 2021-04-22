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
  send(SetSelectedGroup("greet"))
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
  <div className="t-flex t-justify-end">
    <button
      onClick={_ => send(ToggleShowChat)}
      className={"t-bg-blue-600 t-rounded-full t-w-16 t-h-16 t-my-4 t-mx-2 t-flex t-items-center t-justify-center t-cursor-pointer t-shadow-xl t-text-white " ++ {
        state.showChat ? "" : "t-animate-bounce "
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
  let d = "t-border t-rounded-lg t-shadow t-inline-flex t-px-4 t-py-1 t-text-md "
  switch Message.by(message) {
  | Bot => d ++ "t-text-gray-800  t-bg-white t-items-start t-flex-col"
  | User => d ++ "t-text-white t-bg-blue-700 t-items-end t-flex-col"
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

  <div
    className="t-container t-fixed t-bottom-0 t-right-0 t-flex t-flex-col t-max-w-sm t-px-2 t-z-40 t-w-full">
    {state.showChat
      ? <div
          className=" t-transition t-duration-700 t-ease-in-out   t-bg-white t-shadow-lg t-rounded-lg t-relative t-overflow-hidden t-w-full custom-height t-border">
          <div className=" t-overflow-y-auto t-p-4 t-space-y-4 t-items-end t-h-full t-justify-end">
            <div className="t-flex t-flex-col t-z-10 t-ml-4 t-text-white t-w-full">
              <div className="t-text-3xl t-mb-2 t-text-gray-800"> {str("Hi")} </div>
              <div className="t-w-60 t-text-gray-800 t-text-lg t-mb-1">
                {str("I'm CoWin your virtual assistant, Lets get started! ")}
              </div>
            </div>
            <div className="t-space-y-2 t-flex t-flex-col">
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
              <div className="t-space-y-3 t-flex t-flex-col t-w-full t-items-start">
                {Js.Array.mapi(
                  (p, i) =>
                    <div
                      key={string_of_int(i)}
                      onClick={_ => send(AppendUserAction(p))}
                      className="t-border t-rounded-lg t-shadow t-inline-flex t-px-4 t-py-1 t-text-md">
                      {Prompt.title(p)->str}
                    </div>,
                  filteredActions(data, state.selectedGroup),
                )->React.array}
              </div>,
              state.loading,
            )}
            {ReactUtils.nullUnless(
              <div className="t-flex t-flex-col t-w-full t-items-start">
                <div
                  className="t-border t-rounded-lg t-shadow t-inline-flex t-px-4 t-py-1 t-text-md">
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
