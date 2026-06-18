#!/usr/bin/env node
// Secret-Scan — blockt bekannte Secret-Muster im Code.
import { readFileSync } from 'node:fs';

let input = '';
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const payload = JSON.parse(input);
    const tool = payload.tool_name ?? '';
    if (!['Write', 'Edit'].includes(tool)) {
      process.exit(0);
    }

    const path = payload.tool_input?.path ?? '';
    const content = payload.tool_input?.content ?? payload.tool_input?.new_string ?? '';

    // Heuristiken für Secrets
    const patterns = [
      /api[_-]?key\s*[:=]\s*['"][a-zA-Z0-9_\-]{16,}['"]/i,
      /token\s*[:=]\s*['"][a-zA-Z0-9_\-]{20,}['"]/i,
      /password\s*[:=]\s*['"][^'"]{4,}['"]/i,
      /secret\s*[:=]\s*['"][a-zA-Z0-9_\-]{8,}['"]/i,
      /sk-[a-zA-Z0-9]{20,}/,
      /ghp_[a-zA-Z0-9]{20,}/,
    ];

    for (const p of patterns) {
      if (p.test(content)) {
        console.error(`Secret-Scan blockiert: Mögliches Secret in ${path}. Bitte Platzhalter + Umgebungsvariable verwenden.`);
        process.exit(2);
      }
    }
  } catch {
    // fail-open
  }
  process.exit(0);
});
