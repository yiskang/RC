#!/usr/bin/env node
'use strict';

const fs = require('fs');

const DEFAULT_FROM = 'https://npm.autodesk.com/artifactory/api/npm/npm-remote/';
const DEFAULT_TO = 'https://registry.npmjs.org/';

function parseArgs(argv) {
  let lockfilePath = 'package-lock.json';
  let from = DEFAULT_FROM;
  let to = DEFAULT_TO;

  for (const arg of argv) {
    if (arg.startsWith('--from=')) {
      from = arg.slice('--from='.length);
    } else if (arg.startsWith('--to=')) {
      to = arg.slice('--to='.length);
    } else {
      lockfilePath = arg;
    }
  }

  return { lockfilePath, from, to };
}

function countOccurrences(haystack, needle) {
  if (!needle) return 0;
  let count = 0;
  let index = 0;
  while ((index = haystack.indexOf(needle, index)) !== -1) {
    count += 1;
    index += needle.length;
  }
  return count;
}

function main() {
  const { lockfilePath, from, to } = parseArgs(process.argv.slice(2));

  const original = fs.readFileSync(lockfilePath, 'utf8');
  const occurrences = countOccurrences(original, from);

  if (occurrences === 0) {
    console.log(`${lockfilePath}: clean (no "${from}" URLs found)`);
    return;
  }

  const rewritten = original.split(from).join(to);
  fs.writeFileSync(lockfilePath, rewritten);
  console.log(`${lockfilePath}: rewrote ${occurrences} URL(s) from "${from}" to "${to}"`);
}

main();
