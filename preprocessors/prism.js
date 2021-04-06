const fs = require('fs');
const Prism = require('prismjs');
require('prismjs/components/prism-ocaml');

async function read(stream) {
  const chunks = [];
  for await (const chunk of stream) chunks.push(chunk);
  return Buffer.concat(chunks).toString('utf8');
}

(async () => {
  const code = await read(process.stdin);
  process.stdout.write(Prism.highlight(code, Prism.languages.ocaml, 'ocaml'));
})();