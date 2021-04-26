let config = %bs.raw(`require("../data/config.yaml")`)
let data = config->Prompt.makeFromArrayOfObjects
@bs.module external graduateIcon: string = "../assets/cowin-virtual-assistant-cover.png"
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
      className="t-bg-blue-600 t-relative t-rounded-full t-transition t-w-14 t-h-14 md:t-w-16 md:t-h-16 t-my-2 md:t-my-3 t-mx-2 t-flex t-items-center t-justify-center t-cursor-pointer t-shadow-xl t-text-white ">
      <span
        className={"t-absolute t-inline-flex t-h-full t-w-full t-rounded-full t-bg-blue-400 " ++ {
          state.showChat ? "t-opacity-0" : "t-animate-ping t-opacity-20 md:t-opacity-50 t-z-10 "
        }}
      />
      {state.showChat
        ? <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            fill="currentColor"
            fillRule="evenodd"
            className="t-relative t-z-10 t-w-8 t-h-8"
            viewBox="0 0 16 16">
            <path
              d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"
            />
          </svg>
        : <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            fill="currentColor"
            fillRule="evenodd"
            className="t-relative t-z-10 t-w-6 t-h-6"
            viewBox="0 0 16 16">
            <path
              d="M8 15c4.418 0 8-3.134 8-7s-3.582-7-8-7-8 3.134-8 7c0 1.76.743 3.37 1.97 4.6-.097 1.016-.417 2.13-.771 2.966-.079.186.074.394.273.362 2.256-.37 3.597-.938 4.18-1.234A9.06 9.06 0 0 0 8 15z"
            />
          </svg>}
    </button>
  </div>
}

let updateGroup = (send, group) => {
  send(SetSelectedGroup(group))
}

let messageClasses = message => {
  let d = "t-inline-flex t-text-md "
  switch Message.by(message) {
  | Bot => d ++ "t-text-gray-800 t-bg-white t-items-start t-flex-col"
  | User => d ++ "t-text-white t-border t-px-4 t-py-3 t-rounded-lg t-bg-blue-700"
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
          className="t-h-[30rem] md:t-h-[32rem] t-bg-white t-shadow-xl t-rounded-lg t-border t-relative t-w-full">
          <div className="t-flex t-flex-col t-h-full t-justify-end">
            <div className="t-overflow-y-auto t-flex t-h-full t-flex-col">
              <div className="t-flex t-items-start t-z-10 t-text-white t-w-full t-h-full">
                <img
                  src=graduateIcon
                  className="w-18 md:w-24 mx-auto"
                  alt="I'm CoWin, your virtual assistant. Lets get started!"
                />
              </div>
              <div className="t-space-y-3 t-flex t-flex-col t-px-5">
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
                <div className="t-space-y-4 t-flex t-flex-col t-pb-4 t-w-full t-items-start t-p-5">
                  {Js.Array.mapi(
                    (p, i) =>
                      <div
                        key={string_of_int(i)}
                        onClick={_ => send(AppendUserAction(p))}
                        className="t-border t-border-blue-500 t-rounded-lg t-shadow t-inline-flex t-w-full t-justify-center t-text-blue-700 t-px-4 t-py-3 t-text-md t-cursor-pointer hover:t-text-blue-700 hover:t-bg-blue-50 hover:t-shadow-xl t-transition">
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
                    className="t-bg-gray-50 t-flex t-w-full t-justify-center t-items-center t-p-4 t-text-md">
                    <svg
                      className="t-animate-spin -t-ml-1 t-mr-3 t-h-5 t-w-5 t-text-blue-500"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24">
                      <circle
                        className="t-opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        strokeWidth="4"
                      />
                      <path
                        className="t-opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                      />
                    </svg>
                    {str("Loading...")}
                  </div>
                </div>,
                state.loading,
              )}
            </div>
          </div>
        </div>
      : React.null}
    {toggleButton(state, send)}
  </div>
}
