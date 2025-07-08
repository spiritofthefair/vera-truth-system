const fs = require('fs');
const path = require('path');

const basePath = 'E:/LocalClone/Vera/vera-truth-system/';
const categories = ['Services', 'Scripts', 'UI', 'Truth'];
const output = {};

categories.forEach(folder => {
  const dir = path.join(basePath, folder);
  if (!fs.existsSync(dir)) return;

  const files = fs.readdirSync(dir).filter(f => fs.statSync(path.join(dir, f)).isFile());
  output[folder] = files;
});

fs.writeFileSync(path.join(basePath, 'logs', 'service_index.json'), JSON.stringify(output, null, 2));
console.log('✅ Services mapped.');