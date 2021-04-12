import matter from "gray-matter";

function parse(md) {
  const { _data, content } = matter(md);
  return content.split("\n");
}

export default parse;
