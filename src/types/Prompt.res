type t = {
  title: string,
  group: string,
  action: Action.t,
}

let title = t => t.title
let group = t => t.group
let action = t => t.action

let make = (title, group, action) => {
  title: title,
  group: group,
  action: action,
}

let makeFromArrayOfObjects = json => {
  Js.Array.map(
    key =>
      Belt.Option.mapWithDefault(Js.Dict.get(json, key), [], p =>
        Js.Array.map(j => make(j["title"], key, Action.make(j["action"])), p)
      ),
    Js.Dict.keys(json),
  )->ArrayUtils.flatten
}
