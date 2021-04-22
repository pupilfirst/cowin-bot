%bs.raw(`require("./tailwind.css")`)
DomUtils.create()

switch ReactDOM.querySelector("#cowin-chat-bot") {
| Some(root) => ReactDOM.render(<Home />, root)
| None => ()
}
