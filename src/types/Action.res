type link = string
type t = LoadDataFromLink(link) | ShowArticleLink(link) | ChangeFilterGroup(string) | NoAction

let make = json => {
  switch json["actionType"] {
  | "LoadDataFromLink" => LoadDataFromLink(json["meta"]["link"])
  | "ShowArticleLink" => LoadDataFromLink(json["meta"]["link"])
  | "ChangeFilterGroup" => LoadDataFromLink(json["meta"]["link"])
  | "NoAction" => NoAction
  | _ => NoAction
  }
}
