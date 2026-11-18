const fs = require('node:fs');
const path = require('node:path');
const { instance } = require('@viz-js/viz');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
(async () => {
  const viz = await instance();
  const source = fs.readFileSync(path.join(root, 'model/library-er.dot'), 'utf8');
  let svg = viz.renderString(source, { format: 'svg', engine: 'dot' });
  // Розміщуємо назви зв'язків праворуч від середини прямої лінії.
  svg = svg.replace(/<g id="edge\d+" class="edge">[\s\S]*?<\/g>/g, group => {
    const d = group.match(/<path[^>]* d="([^"]+)"/);
    if (!d) return group;
    const points = d[1].match(/-?\d+(?:\.\d+)?/g).map(Number);
    const x = (points[0] + points[points.length - 2]) / 2 + 16;
    const y = (points[1] + points[points.length - 1]) / 2;
    return group.replace(/<text([^>]*)>/, (_, attrs) => '<text' + attrs
      .replace(/text-anchor="[^"]+"/, 'text-anchor="start"')
      .replace(/ x="[^"]+"/, ` x="${x.toFixed(2)}"`)
      .replace(/ y="[^"]+"/, ` y="${y.toFixed(2)}"`) + '>');
  });
  fs.writeFileSync(path.join(root, 'model/library-er.svg'), svg);
  await sharp(Buffer.from(svg), { density: 150 }).flatten({ background: '#ffffff' }).png().toFile(path.join(root, 'model/library-er.png'));
  console.log('Створено model/library-er.svg та model/library-er.png');
})().catch(error => { console.error(error); process.exitCode = 1; });
