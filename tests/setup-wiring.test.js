#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { describe, test } = require('node:test');

const REPO_ROOT = path.resolve(__dirname, '..');
const SETUP_SH = path.join(REPO_ROOT, 'setup.sh');
const SETUP_PS1 = path.join(REPO_ROOT, 'setup.ps1');

function tmpHome(prefix) {
  return fs.mkdtempSync(path.join(os.tmpdir(), prefix));
}

function readSettings(home) {
  const settingsPath = path.join(home, '.claude', 'settings.json');
  const text = fs.readFileSync(settingsPath, 'utf8');
  return { text, parsed: JSON.parse(text) };
}

function assertCommonWiring(home) {
  const { text, parsed } = readSettings(home);

  // 1) Valides JSON ohne unescaped Windows-Backslashes
  assert.ok(text.includes('"hooks"'), 'settings.json sollte einen hooks-Block enthalten');
  assert.ok(!text.includes('\\\\'), 'settings.json sollte keine doppelten Backslashes enthalten');
  // Einzelne Backslashes in Pfaden wuerden JSON invalidieren; parse() ist oben bereits geglueckt.

  // 2) Hook-Skript wurde deployed
  const gatePath = path.join(home, '.claude', 'hooks', 'fact-forcing-gate.js');
  assert.ok(fs.existsSync(gatePath), 'fact-forcing-gate.js sollte nach ~/.claude/hooks kopiert sein');

  // 3) SessionStart-Hinweis aus der repo-lokalen settings.json
  assert.ok(Array.isArray(parsed.hooks?.SessionStart), 'SessionStart sollte existieren');
  const hasStartHint = parsed.hooks.SessionStart.some(entry =>
    entry?.hooks?.some(h =>
      typeof h.command === 'string' && h.command.includes('/uni:start beginnen')
    )
  );
  assert.ok(hasStartHint, 'SessionStart sollte den /uni:start Hinweis enthalten');

  // 4) PreToolUse aus dem Template mit korrektem Pfad
  assert.ok(Array.isArray(parsed.hooks?.PreToolUse), 'PreToolUse sollte existieren');
  const matchers = parsed.hooks.PreToolUse.map(entry => entry.matcher).sort();
  assert.deepStrictEqual(matchers, ['Bash', 'Edit|Write|MultiEdit'], 'PreToolUse Matcher muessen Bash und Edit|Write|MultiEdit sein');

  for (const entry of parsed.hooks.PreToolUse) {
    assert.ok(Array.isArray(entry.hooks), 'Jeder PreToolUse-Eintrag braucht hooks');
    for (const h of entry.hooks) {
      assert.ok(
        typeof h.command === 'string' && h.command.includes('fact-forcing-gate.js'),
        'Jeder Hook muss auf fact-forcing-gate.js verweisen'
      );
      assert.ok(
        h.command.includes('"') && h.command.includes('/'),
        'Der Hook-Pfad sollte mit Forward-Slashes und in Anfuehrungszeichen sein'
      );
    }
  }
}

describe('Setup-Skripte verdrahten Gate korrekt', () => {
  test('setup.sh erzeugt valide settings.json mit SessionStart + PreToolUse', { skip: process.platform === 'win32' }, () => {
    const home = tmpHome('uni-setup-sh-');
    try {
      const result = spawnSync('bash', [SETUP_SH], {
        cwd: REPO_ROOT,
        encoding: 'utf8',
        env: { ...process.env, HOME: home },
      });
      assert.strictEqual(result.status, 0, `setup.sh fehlgeschlagen:\n${result.stderr}${result.stdout}`);
      assertCommonWiring(home);
    } finally {
      fs.rmSync(home, { recursive: true, force: true });
    }
  });

  test('setup.ps1 erzeugt valide settings.json mit SessionStart + PreToolUse', () => {
    const home = tmpHome('uni-setup-ps1-');
    try {
      const result = spawnSync('powershell', [
        '-ExecutionPolicy', 'Bypass',
        '-File', SETUP_PS1,
      ], {
        cwd: REPO_ROOT,
        encoding: 'utf8',
        env: { ...process.env, USERPROFILE: home },
      });
      assert.strictEqual(result.status, 0, `setup.ps1 fehlgeschlagen:\n${result.stderr}${result.stdout}`);
      assertCommonWiring(home);
    } finally {
      fs.rmSync(home, { recursive: true, force: true });
    }
  });
});
