#!/usr/bin/env node
// Size-Guard — warnt bei zu großen Dateien oder Funktionen.

let input = '';
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const payload = JSON.parse(input);
    const tool = payload.tool_name ?? '';
    if (tool !== 'Write') {
      process.exit(0);
    }

    const path = payload.tool_input?.path ?? '';
    const content = payload.tool_input?.content ?? '';

    if (!path.endsWith('.py')) {
      process.exit(0);
    }

    const lines = content.split(/\r?\n/);
    if (lines.length > 800) {
      console.error(`Size-Guard blockiert: ${path} hat ${lines.length} Zeilen (Limit: 800). Bitte in kleinere Module aufteilen.`);
      process.exit(2);
    }

    // Grobe Funktionslängen-Prüfung
    const funcRegex = /^(\s*)def\s+\w+\s*\([^)]*\)\s*->?.*?:/gm;
    let match;
    while ((match = funcRegex.exec(content)) !== null) {
      const indent = match[1].length;
      const startLine = content.substring(0, match.index).split(/\r?\n/).length;
      const nextLines = lines.slice(startLine);
      let endLine = startLine;
      for (let i = 0; i < nextLines.length; i++) {
        const line = nextLines[i];
        if (line.trim() === '') continue;
        const lineIndent = line.match(/^(\s*)/)[1].length;
        if (lineIndent <= indent && !line.trim().startsWith('#')) {
          break;
        }
        endLine++;
      }
      const funcLen = endLine - startLine + 1;
      if (funcLen > 50) {
        console.error(`Size-Guard blockiert: Funktion in ${path} ab Zeile ${startLine} ist ~${funcLen} Zeilen lang (Limit: 50).`);
        process.exit(2);
      }
    }
  } catch {
    // fail-open
  }
  process.exit(0);
});
