const fs = require('fs');
const Prism = require('prismjs');
require('prismjs/components/prism-ocaml');
require('prismjs/components/prism-reason');
require('prismjs/components/prism-javascript');

async function read(stream) {
  const chunks = [];
  for await (const chunk of stream) chunks.push(chunk);
  return Buffer.concat(chunks).toString('utf8');
}

let lang = process.argv.slice(2)[0];

let syntax = Prism.languages.ocaml;
switch (lang) {
  case 'reason':
    syntax = Prism.languages.reason;
    break;
  case 'javascript':
    syntax = Prism.languages.javascript;
    break;
  default:
    lang = 'ocaml';
    syntax = Prism.languages.ocaml;
}

(async () => {
  const code = await read(process.stdin);
  process.stdout.write(Prism.highlight(code, syntax, lang));
})();