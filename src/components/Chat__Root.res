let config = %bs.raw(`require("../data/config.yaml")`)

let str = React.string

type state = {
  loading: bool,
  showChat: bool,
  saving: bool,
}

type action =
  | SetSaving
  | ClearSaving
  | ShowChat
  | HideChat
  | ToggleShowChat

let reducer = (state, action) =>
  switch action {
  | SetSaving => {...state, saving: true}
  | ClearSaving => {...state, saving: false}
  | ShowChat => {...state, showChat: true}
  | HideChat => {...state, showChat: false}
  | ToggleShowChat => {...state, showChat: !state.showChat}
  }

let computeInitialState = () => {
  loading: false,
  showChat: true,
  saving: false,
}

@react.component
let make = () => {
  let (state, send) = React.useReducer(reducer, computeInitialState())

  let data = config->Prompt.makeFromArrayOfObjects

  let _p = Js.Array.map(d => {
    Js.log(Prompt.title(d))
  }, data)

  <div className="container fixed bottom-0 right-0 flex flex-col max-w-sm px-2 z-40 w-full">
    {state.showChat
      ? <div
          className=" transition duration-700 ease-in-outbg-white shadow-xl rounded-lg relative overflow-hidden w-full ">
          <div className="bg-blue-700 h-64 rounded-t-lg absolute w-full z-0 " />
          <div className="flex flex-col overflow-y-auto h-full p-4 space-y-4">
            <div className="flex flex-col z-10 ml-4 text-white">
              <div className="text-3xl mb-2"> {str("Hi")} </div>
              <div className="w-60 text-gray-200 text-sm mb-1">
                {str("I'm COWIn the cowin virtual assistant ")}
              </div>
            </div>
            <div className="bg-white border rounded flex items-center justify-center p-8 z-10">
              {str("this is a card")}
            </div>
            <div className="bg-white border rounded flex items-center justify-center p-8 z-10">
              {str("this is a card")}
            </div>
          </div>
        </div>
      : React.null}
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
  </div>
}
