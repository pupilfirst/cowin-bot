type by = Bot | User
type t = {
  text: string,
  by: by,
}

let text = t => t.text
let by = t => t.by

let make = (text, by) => {
  text: text,
  by: by,
}

let addUserInput = text => make(text, User)
let addBotInput = text => make(text, Bot)
