#!/usr/bin/env node
// RB-01-Guard — blockt Aktor-/Freigabe-/Sperr-Routen im Code.
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

    // Nur Python-Dateien und API-relevante Dateien prüfen
    if (!/\.(py|md|yaml|yml|json)$/.test(path)) {
      process.exit(0);
    }

    const forbidden = /\b(release|freigabe|sperr|aktor|control)\b/gi;
    if (forbidden.test(content)) {
      console.error(`RB-01 blockiert: Verdächtiger Begriff in ${path}. Das System darf keine Aktor-/Freigabe-/Sperr-Routen enthalten.`);
      process.exit(2);
    }
  } catch {
    // fail-open
  }
  process.exit(0);
});
