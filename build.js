const fs = require("fs");
const outdir = "dist";
const outfile = `${outdir}/index.js`;
const result = require("esbuild").buildSync({
  entryPoints: ["src/Index.bs.js"],
  outfile,
  platform: "node",
  banner: {
    js: '#!/usr/bin/env node\n"use strict";',
  },
  bundle: true,
  minify: true,
  write: false,
});

if (!fs.existsSync(outdir)) {
  fs.mkdirSync(outdir);
}

fs.writeFileSync(
  outfile,
  result.outputFiles[0].text.replace('"use strict";', "")
);
