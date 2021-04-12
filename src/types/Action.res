type link = string
type t = LoadDataFromLink(link) | ShowArticleLink(link) | ChangeFilterGroup(string) | NoAction

let make = json => {
  switch json["actionType"] {
  | "LoadDataFromLink" => LoadDataFromLink(json["link"])
  | "ShowArticleLink" => ShowArticleLink(json["link"])
  | "ChangeFilterGroup" => ChangeFilterGroup(json["group_name"])
  | "NoAction" => NoAction
  | _ => NoAction
  }
}
