const { readFile, writeFile } = require('node:fs/promises');
const path = require('node:path');

(async () => {
  const { instance } = await import('@viz-js/viz');
  const sharp = require('sharp');
  const modelDirectory = path.resolve(__dirname, '../model');
  const dot = await readFile(path.join(modelDirectory, 'electronics-er.dot'), 'utf8');
  const viz = await instance();

  const result = viz.render(dot, { format: 'svg' });
  if (result.status !== 'success') {
    throw new Error(result.errors.map(({ message }) => message).join('\n'));
  }
  const svgPath = path.join(modelDirectory, 'electronics-er.svg');
  const pngPath = path.join(modelDirectory, 'electronics-er.png');
  await writeFile(svgPath, result.output);
  await sharp(Buffer.from(result.output), { density: 192 }).png().toFile(pngPath);

  console.log('Created model/electronics-er.svg and model/electronics-er.png');
})().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
