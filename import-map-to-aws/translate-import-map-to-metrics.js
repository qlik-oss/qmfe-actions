const fs = require('fs');

if (process.argv.length != 3) {
  console.error("Usage: ./translate-import-map-to-metrics <path-to-file>")
  process.exit(1)
}

const rawdata = fs.readFileSync(process.argv[2]);
const {imports} = JSON.parse(rawdata);

console.log(`# TYPE qmfe_deployment gauge`)
for (const name in imports) {
    let version = imports[name]
    version = version.replace("https://cdn.qlik-stage.com/qmfe/", "")
    version = version.replace("https://cdn.qlikcloud.com/qmfe/", "")
    version = version.replace(/[^\/]+\//, "")
    version = version.replace(/\/[^\/]+.js$/, "")
    console.log(`qmfe_deployment{component="${name}", version="${version}"} 1`)
}
