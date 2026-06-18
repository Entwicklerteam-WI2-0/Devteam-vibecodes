#!/usr/bin/env node
// Test-Gate — prüft vor Turn-Ende, ob Tests grün sind.
import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

let input = '';
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const payload = JSON.parse(input);
    if (payload.hook_event_name !== 'Stop') {
      process.exit(0);
    }

    const cwd = payload.cwd ?? process.cwd();
    if (!cwd.toLowerCase().includes('alarmsystem-dev')) {
      process.exit(0);
    }

    if (!existsSync(resolve(cwd, 'pyproject.toml')) && !existsSync(resolve(cwd, 'uv.lock'))) {
      process.exit(0);
    }

    const result = spawnSync('uv', ['run', 'pytest', '-q'], { cwd, encoding: 'utf8' });
    if (result.status !== 0) {
      console.error('Test-Gate blockiert: pytest ist nicht grün. Bitte Tests beheben, bevor die Runde endet.');
      process.exit(2);
    }
  } catch {
    // fail-open
  }
  process.exit(0);
});
