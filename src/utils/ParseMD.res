@bs.module("./ParseMarkdown") external parse: string => array<string> = "default"

@bs.module("./Markdownit") external convert: string => string = "default"
