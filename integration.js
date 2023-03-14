import { argv } from "process";

main();

function main() {
  const mode = argv[2] || "dev";
  run(mode);
}

async function run(mode) {
  console.log(mode);
}
