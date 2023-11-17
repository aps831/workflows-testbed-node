import { argv } from "process";
import { promises as fs } from "node:fs";
import * as path from "path";
import { URL } from "url";

const __dirname = new URL(".", import.meta.url).pathname;

main();

function main() {
  const mode = argv[2] || "dev";
  run(mode);
}

async function run(mode) {
  await fs.mkdir(path.join(__dirname, "outputs", "integration-tests"), { recursive: true });
  const fd = await fs.open(
    path.join(__dirname, "outputs", "integration-tests", "integration.txt"),
    "w",
  );
  await fd.write(mode);
}
