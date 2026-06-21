#!/usr/bin/env node
'use strict';

const fs = require('fs');

const userPath = process.argv[2];
const templatePath = process.argv[3];
const repoPath = process.argv[4];
const hooksDir = process.argv[5];

if (!userPath || !templatePath || !repoPath || !hooksDir) {
  process.stderr.write('[setup] Usage: node merge-settings.js <user-settings.json> <preToolUse-template.json> <repo-settings.json> <hooks-dir>\n');
  process.exit(1);
}

try {
  const safeDir = hooksDir.replace(/\\/g, '/');

  let user = {};
  try {
    user = JSON.parse(fs.readFileSync(userPath, 'utf8'));
  } catch (_) {
    user = {};
  }

  let tplText = '{}';
  try {
    tplText = fs.readFileSync(templatePath, 'utf8');
  } catch (_) {}

  let repoText = '{}';
  try {
    repoText = fs.readFileSync(repoPath, 'utf8');
  } catch (_) {}

  const tplFixed = JSON.parse(tplText.replace(/__UNI_HOOKS_DIR__/g, safeDir));
  const repoFixed = JSON.parse(repoText.replace(/__UNI_HOOKS_DIR__/g, safeDir));

  function isUniEntry(e) {
    if (!e || !Array.isArray(e.hooks)) return false;
    return e.hooks.some((h) => {
      if (!h || typeof h.command !== 'string') return false;
      return h.command.includes('fact-forcing-gate.js') || h.command.includes('/uni:start beginnen');
    });
  }

  user.hooks = user.hooks || {};

  if (Array.isArray(repoFixed.hooks.SessionStart)) {
    const userSession = Array.isArray(user.hooks.SessionStart)
      ? user.hooks.SessionStart.filter((e) => !isUniEntry(e))
      : [];
    user.hooks.SessionStart = userSession.concat(repoFixed.hooks.SessionStart);
  }

  if (Array.isArray(tplFixed.hooks.PreToolUse)) {
    const userPre = Array.isArray(user.hooks.PreToolUse)
      ? user.hooks.PreToolUse.filter((e) => !isUniEntry(e))
      : [];
    user.hooks.PreToolUse = userPre.concat(tplFixed.hooks.PreToolUse);
  }

  fs.writeFileSync(userPath, JSON.stringify(user, null, 2));
} catch (err) {
  process.stderr.write('[setup] Fehler beim Merge von settings.json: ' + err.message + '\n');
  process.exit(1);
}
