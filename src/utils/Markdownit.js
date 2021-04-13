var md = require("markdown-it")();

const convert = (markdown) => {
  return md.render(markdown);
};

export default convert;
