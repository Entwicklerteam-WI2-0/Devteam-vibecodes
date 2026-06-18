#!/usr/bin/env node
// Format-Lint — ruft ruff nach Write/Edit im Arbeitsrepo auf.
import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

let input = '';
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const payload = JSON.parse(input);
    const tool = payload.tool_name ?? '';
    if (!['Write', 'Edit'].includes(tool)) {
      process.exit(0);
    }

    const cwd = payload.cwd ?? process.cwd();
    // Nur im Arbeitsrepo ausführen
    if (!cwd.toLowerCase().includes('alarmsystem-dev')) {
      process.exit(0);
    }

    if (!existsSync(resolve(cwd, 'pyproject.toml')) && !existsSync(resolve(cwd, 'uv.lock'))) {
      process.exit(0);
    }

    const format = spawnSync('uv', ['run', 'ruff', 'format', '.'], { cwd, encoding: 'utf8' });
    const check = spawnSync('uv', ['run', 'ruff', 'check', '--fix', '.'], { cwd, encoding: 'utf8' });

    if (format.status !== 0 || check.status !== 0) {
      console.error('Format-Lint-Hinweis: ruff hat Format- oder Lint-Fehler gefunden. Bitte vor dem Commit beheben.');
      // Observation-only: nicht blockieren, da PostToolUse
    }
  } catch {
    // fail-open
  }
  process.exit(0);
});
