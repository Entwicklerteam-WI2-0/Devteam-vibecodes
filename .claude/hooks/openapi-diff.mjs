#!/usr/bin/env node
// OpenAPI-Diff — meldet Änderungen am eingefrorenen OpenAPI-Contract.

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

    // Hinweis ausgeben, dass Contract-Änderungen geprüft werden müssen
    console.log('OpenAPI-Diff-Hinweis: Falls Routen/Schemas geändert wurden, bitte OpenAPI-Diff und Architekt-Freigabe prüfen.');
  } catch {
    // fail-open
  }
  process.exit(0);
});
