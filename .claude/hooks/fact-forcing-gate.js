#!/usr/bin/env node
/**
 * PreToolUse Hook: Fact-Forcing Gate (vendored standalone port)
 *
 * Port of ECC's gateguard-fact-force to a self-contained Node script.
 * No external dependencies; uses only Node built-ins (crypto, fs, path).
 *
 * Namespace: UNI_GATE_* (isolated from ECC's GATEGUARD_* / ECC_* env vars).
 * State directory: ~/.uni-gate/ (isolated from ECC's ~/.gateguard/).
 *
 * Hook IDs:
 *   - uni:pre:bash:fact-force
 *   - uni:pre:edit-write:fact-force
 */

'use strict';

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// Session state — scoped per session to avoid cross-session races.
const STATE_DIR = process.env.UNI_GATE_STATE_DIR || path.join(process.env.HOME || process.env.USERPROFILE || '/tmp', '.uni-gate');
let activeStateFile = null;

// State expires after 30 minutes of inactivity
const SESSION_TIMEOUT_MS = 30 * 60 * 1000;
const READ_HEARTBEAT_MS = 60 * 1000;

// Maximum checked entries to prevent unbounded growth
const MAX_CHECKED_ENTRIES = 500;
const MAX_SESSION_KEYS = 50;
const ROUTINE_BASH_SESSION_KEY = '__bash_session__';
const EDIT_WRITE_HOOK_ID = 'uni:pre:edit-write:fact-force';
const BASH_HOOK_ID = 'uni:pre:bash:fact-force';
const UNI_DISABLE_VALUES = new Set(['0', 'false', 'off', 'disabled', 'disable']);
const UNI_ENABLE_VALUES = new Set(['1', 'true', 'on', 'enabled', 'enable', 'yes']);

// SQL-keyword + dd patterns stay as a single regex — they are stable
// phrases without shell-flag ordering concerns. Quoted strings are
// stripped before this regex runs so a commit message mentioning
// "drop table" no longer triggers a false positive.
const DESTRUCTIVE_SQL_DD = /\b(drop\s+table|delete\s+from|truncate|dd\s+if=)\b/i;

// Operator-supplied additional destructive patterns. Lazily compiled from
// `UNI_GATE_BASH_EXTRA_DESTRUCTIVE` (regex source) on first use, then
// memoized keyed by the env-var value so a test or long-running process
// that flips the env between calls re-reads it without paying for a
// recompile on every invocation. A malformed regex is treated as
// "not configured" (the gate falls back to the built-in patterns) and
// the parse failure is logged once via `[fact-forcing-gate]` to
// stderr — hooks must never crash tool execution because of operator
// config errors.
let extraDestructiveCacheKey = null;
let extraDestructiveCacheRegex = null;
let extraDestructiveWarnLogged = false;
function getExtraDestructiveRegex() {
  const raw = process.env.UNI_GATE_BASH_EXTRA_DESTRUCTIVE || '';
  if (!raw) {
    extraDestructiveCacheKey = '';
    extraDestructiveCacheRegex = null;
    return null;
  }
  if (raw === extraDestructiveCacheKey) {
    return extraDestructiveCacheRegex;
  }
  // The env value just changed; reset the once-per-pattern warning gate
  // so a subsequent *different* invalid regex is also reported once. The
  // previous shape kept the flag sticky and silently swallowed the
  // second bad pattern in a long-running process.
  extraDestructiveCacheKey = raw;
  extraDestructiveWarnLogged = false;
  try {
    extraDestructiveCacheRegex = new RegExp(raw, 'i');
  } catch (err) {
    extraDestructiveCacheRegex = null;
    if (!extraDestructiveWarnLogged) {
      try {
        process.stderr.write(
          `[fact-forcing-gate] ignoring invalid UNI_GATE_BASH_EXTRA_DESTRUCTIVE regex: ${err.message}\n`
        );
      } catch (_) { /* stderr write failure is non-fatal */ }
      extraDestructiveWarnLogged = true;
    }
  }
  return extraDestructiveCacheRegex;
}

function isRoutineBashGateDisabled() {
  return UNI_ENABLE_VALUES.has(normalizeEnvValue(process.env.UNI_GATE_BASH_ROUTINE_DISABLED));
}

function isHookProfileSilent() {
  return normalizeEnvValue(process.env.UNI_HOOK_PROFILE) === 'minimal';
}

function isHookDisabled(hookId) {
  const disabled = String(process.env.UNI_DISABLED_HOOKS || '')
    .split(',')
    .map(s => s.trim())
    .filter(Boolean);
  return disabled.includes(hookId);
}

// =============================================================================
// Shell-substitution helpers (inlined from ECC's shell-substitution.js)
// =============================================================================

function extractCommandSubstitutions(input) {
  const source = String(input || '');
  const substitutions = [];
  let inSingle = false;
  let inDouble = false;

  for (let i = 0; i < source.length; i++) {
    const ch = source[i];
    const prev = source[i - 1];

    if (ch === '\\' && !inSingle) {
      i += 1;
      continue;
    }

    if (ch === "'" && !inDouble && prev !== '\\') {
      inSingle = !inSingle;
      continue;
    }

    if (ch === '"' && !inSingle && prev !== '\\') {
      inDouble = !inDouble;
      continue;
    }

    if (inSingle) {
      continue;
    }

    if (ch === '`') {
      let body = '';
      i += 1;
      while (i < source.length) {
        const inner = source[i];
        if (inner === '\\') {
          body += inner;
          if (i + 1 < source.length) {
            body += source[i + 1];
            i += 2;
            continue;
          }
        }
        if (inner === '`') {
          break;
        }
        body += inner;
        i += 1;
      }
      if (body.trim()) {
        substitutions.push(body);
        substitutions.push(...extractCommandSubstitutions(body));
      }
      continue;
    }

    if (ch === '$' && source[i + 1] === '(') {
      let depth = 1;
      let body = '';
      let bodyInSingle = false;
      let bodyInDouble = false;
      i += 2;
      while (i < source.length && depth > 0) {
        const inner = source[i];
        const innerPrev = source[i - 1];
        if (inner === '\\' && !bodyInSingle) {
          body += inner;
          if (i + 1 < source.length) {
            body += source[i + 1];
            i += 2;
            continue;
          }
        }
        if (inner === "'" && !bodyInDouble && innerPrev !== '\\') {
          bodyInSingle = !bodyInSingle;
        } else if (inner === '"' && !bodyInSingle && innerPrev !== '\\') {
          bodyInDouble = !bodyInDouble;
        } else if (!bodyInSingle && !bodyInDouble) {
          if (inner === '(') {
            depth += 1;
          } else if (inner === ')') {
            depth -= 1;
            if (depth === 0) {
              break;
            }
          }
        }
        body += inner;
        i += 1;
      }
      if (body.trim()) {
        substitutions.push(body);
        substitutions.push(...extractCommandSubstitutions(body));
      }
    }
  }

  return substitutions;
}

function extractSubshellGroups(input) {
  const source = String(input || '');
  const groups = [];
  let inSingle = false;
  let inDouble = false;

  for (let i = 0; i < source.length; i++) {
    const ch = source[i];
    const prev = source[i - 1];

    if (ch === '\\' && !inSingle) {
      i += 1;
      continue;
    }

    if (ch === "'" && !inDouble && prev !== '\\') {
      inSingle = !inSingle;
      continue;
    }

    if (ch === '"' && !inSingle && prev !== '\\') {
      inDouble = !inDouble;
      continue;
    }

    if (inSingle || inDouble) {
      continue;
    }

    if (ch === '$' && source[i + 1] === '(') {
      let depth = 1;
      let skipInSingle = false;
      let skipInDouble = false;
      i += 2;
      while (i < source.length && depth > 0) {
        const inner = source[i];
        const innerPrev = source[i - 1];
        if (inner === '\\' && !skipInSingle) {
          i += 2;
          continue;
        }
        if (inner === "'" && !skipInDouble && innerPrev !== '\\') {
          skipInSingle = !skipInSingle;
        } else if (inner === '"' && !skipInSingle && innerPrev !== '\\') {
          skipInDouble = !skipInDouble;
        } else if (!skipInSingle && !skipInDouble) {
          if (inner === '(') depth += 1;
          else if (inner === ')') depth -= 1;
        }
        i += 1;
      }
      i -= 1;
      continue;
    }

    if (ch === '`') {
      i += 1;
      while (i < source.length && source[i] !== '`') {
        if (source[i] === '\\' && i + 1 < source.length) {
          i += 2;
          continue;
        }
        i += 1;
      }
      continue;
    }

    if (ch === '(') {
      let depth = 1;
      let body = '';
      let bodyInSingle = false;
      let bodyInDouble = false;
      i += 1;
      while (i < source.length && depth > 0) {
        const inner = source[i];
        const innerPrev = source[i - 1];
        if (inner === '\\' && !bodyInSingle) {
          body += inner;
          if (i + 1 < source.length) {
            body += source[i + 1];
            i += 2;
            continue;
          }
        }
        if (inner === "'" && !bodyInDouble && innerPrev !== '\\') {
          bodyInSingle = !bodyInSingle;
        } else if (inner === '"' && !bodyInSingle && innerPrev !== '\\') {
          bodyInDouble = !bodyInDouble;
        } else if (!bodyInSingle && !bodyInDouble) {
          if (inner === '(') {
            depth += 1;
          } else if (inner === ')') {
            depth -= 1;
            if (depth === 0) {
              break;
            }
          }
        }
        body += inner;
        i += 1;
      }
      if (body.trim()) {
        groups.push(body);
        groups.push(...extractSubshellGroups(body));
      }
    }
  }

  return groups;
}

function extractBraceGroups(input) {
  const source = String(input || '');
  const groups = [];
  let inSingle = false;
  let inDouble = false;

  for (let i = 0; i < source.length; i++) {
    const ch = source[i];
    const prev = source[i - 1];

    if (ch === '\\' && !inSingle) {
      i += 1;
      continue;
    }

    if (ch === "'" && !inDouble && prev !== '\\') {
      inSingle = !inSingle;
      continue;
    }

    if (ch === '"' && !inSingle && prev !== '\\') {
      inDouble = !inDouble;
      continue;
    }

    if (inSingle || inDouble) {
      continue;
    }

    if (ch === '$' && source[i + 1] === '(') {
      let depth = 1;
      let skipInSingle = false;
      let skipInDouble = false;
      i += 2;
      while (i < source.length && depth > 0) {
        const inner = source[i];
        const innerPrev = source[i - 1];
        if (inner === '\\' && !skipInSingle) {
          i += 2;
          continue;
        }
        if (inner === "'" && !skipInDouble && innerPrev !== '\\') {
          skipInSingle = !skipInSingle;
        } else if (inner === '"' && !skipInSingle && innerPrev !== '\\') {
          skipInDouble = !skipInDouble;
        } else if (!skipInSingle && !skipInDouble) {
          if (inner === '(') depth += 1;
          else if (inner === ')') depth -= 1;
        }
        i += 1;
      }
      i -= 1;
      continue;
    }

    if (ch === '`') {
      i += 1;
      while (i < source.length && source[i] !== '`') {
        if (source[i] === '\\' && i + 1 < source.length) {
          i += 2;
          continue;
        }
        i += 1;
      }
      continue;
    }

    if (ch === '(') {
      let depth = 1;
      let skipInSingle = false;
      let skipInDouble = false;
      i += 1;
      while (i < source.length && depth > 0) {
        const inner = source[i];
        const innerPrev = source[i - 1];
        if (inner === '\\' && !skipInSingle) {
          i += 2;
          continue;
        }
        if (inner === "'" && !skipInDouble && innerPrev !== '\\') {
          skipInSingle = !skipInSingle;
        } else if (inner === '"' && !skipInSingle && innerPrev !== '\\') {
          skipInDouble = !skipInDouble;
        } else if (!skipInSingle && !skipInDouble) {
          if (inner === '(') depth += 1;
          else if (inner === ')') depth -= 1;
        }
        i += 1;
      }
      i -= 1;
      continue;
    }

    if (ch === '{' && /\s/.test(source[i + 1] || '')) {
      const prevIsBoundary = i === 0 || /[\s;|&(]/.test(prev);
      if (!prevIsBoundary) continue;

      let depth = 1;
      let body = '';
      let bodyInSingle = false;
      let bodyInDouble = false;
      i += 1;
      while (i < source.length && depth > 0) {
        const inner = source[i];
        const innerPrev = source[i - 1];
        if (inner === '\\' && !bodyInSingle) {
          body += inner;
          if (i + 1 < source.length) {
            body += source[i + 1];
            i += 2;
            continue;
          }
        }
        if (inner === "'" && !bodyInDouble && innerPrev !== '\\') {
          bodyInSingle = !bodyInSingle;
          body += inner;
          i += 1;
          continue;
        }
        if (inner === '"' && !bodyInSingle && innerPrev !== '\\') {
          bodyInDouble = !bodyInDouble;
          body += inner;
          i += 1;
          continue;
        }
        if (bodyInSingle || bodyInDouble) {
          body += inner;
          i += 1;
          continue;
        }
        // Skip $(...) spans — a quoted `}` or `}`-as-text inside a
        // substitution body must not close the enclosing brace group.
        if (inner === '$' && source[i + 1] === '(') {
          body += inner + source[i + 1];
          let subDepth = 1;
          let subInSingle = false;
          let subInDouble = false;
          i += 2;
          while (i < source.length && subDepth > 0) {
            const c = source[i];
            const p = source[i - 1];
            body += c;
            if (c === '\\' && !subInSingle && i + 1 < source.length) {
              body += source[i + 1];
              i += 2;
              continue;
            }
            if (c === "'" && !subInDouble && p !== '\\') subInSingle = !subInSingle;
            else if (c === '"' && !subInSingle && p !== '\\') subInDouble = !subInDouble;
            else if (!subInSingle && !subInDouble) {
              if (c === '(') subDepth += 1;
              else if (c === ')') subDepth -= 1;
            }
            i += 1;
          }
          continue;
        }
        // Skip backtick spans for the same reason.
        if (inner === '`') {
          body += inner;
          i += 1;
          while (i < source.length && source[i] !== '`') {
            if (source[i] === '\\' && i + 1 < source.length) {
              body += source[i] + source[i + 1];
              i += 2;
              continue;
            }
            body += source[i];
            i += 1;
          }
          if (i < source.length) {
            body += source[i];
            i += 1;
          }
          continue;
        }
        // Skip plain (...) subshell spans for the same reason.
        if (inner === '(') {
          body += inner;
          let subDepth = 1;
          let subInSingle = false;
          let subInDouble = false;
          i += 1;
          while (i < source.length && subDepth > 0) {
            const c = source[i];
            const p = source[i - 1];
            body += c;
            if (c === '\\' && !subInSingle && i + 1 < source.length) {
              body += source[i + 1];
              i += 2;
              continue;
            }
            if (c === "'" && !subInDouble && p !== '\\') subInSingle = !subInSingle;
            else if (c === '"' && !subInSingle && p !== '\\') subInDouble = !subInDouble;
            else if (!subInSingle && !subInDouble) {
              if (c === '(') subDepth += 1;
              else if (c === ')') subDepth -= 1;
            }
            i += 1;
          }
          continue;
        }
        if (inner === '{' && /\s/.test(source[i + 1] || '')) {
          // Match the outer-scan boundary rule for nested `{` so
          // tokens like `foo{` (no boundary, but followed by space
          // via `foo{ bar`) cannot bump nested depth.
          const nestedPrevIsBoundary = /[\s;|&(]/.test(innerPrev);
          if (nestedPrevIsBoundary) depth += 1;
        } else if (inner === '}' && (innerPrev === ';' || /\s/.test(innerPrev))) {
          depth -= 1;
          if (depth === 0) {
            break;
          }
        }
        body += inner;
        i += 1;
      }
      if (body.trim()) {
        groups.push(body);
        groups.push(...extractBraceGroups(body));
      }
    }
  }

  return groups;
}

// =============================================================================
// Bash destructive detection
// =============================================================================

/**
 * Strip the contents of single- and double-quoted strings so phrases
 * mentioned inside a commit message or echoed argument do not trigger
 * the destructive detector. Command substitutions are scanned separately
 * before this runs because they execute even inside double quotes.
 *
 * @param {string} input
 * @returns {string}
 */
function stripQuotedStrings(input) {
  return input
    .replace(/'(?:[^'\\]|\\.)*'/g, "''")
    .replace(/"(?:[^"\\]|\\.)*"/g, '""');
}

/**
 * Promote subshell delimiters to top-level segment separators so the
 * destructive check applies inside `$(...)` and backtick subshells.
 * Without this, `echo y | $(rm -rf /tmp)` and ``echo y | `rm -rf /tmp` ``
 * slip past the segment splitter because the destructive command lives
 * inside a sub-expression. Run iteratively to handle a layer of nesting.
 *
 * @param {string} input
 * @returns {string}
 */
function explodeSubshells(input) {
  let out = input;
  for (let i = 0; i < 4; i += 1) {
    const before = out;
    out = out.replace(/\$\(([^()`]*)\)/g, ';$1;');
    out = out.replace(/`([^`]*)`/g, ';$1;');
    if (out === before) break;
  }
  return out;
}

/**
 * Split a command line into top-level segments at unquoted shell
 * separators (`;`, `|`, `&`, `&&`, `||`) and across subshells
 * (`$(...)` / backticks). Quoted strings are stripped first so
 * separators inside quotes are not split on. Per-segment comments
 * are also stripped.
 *
 * @param {string} input
 * @returns {string[]}
 */
function splitCommandSegments(input) {
  const stripped = explodeSubshells(stripQuotedStrings(input));
  return stripped
    .split(/[;|&]+/)
    .map(segment => segment.replace(/(^|\s)#.*/, '$1').trim())
    .filter(Boolean);
}

/**
 * Tokenize a single command segment by whitespace. Quoted strings
 * are already collapsed to empty quotes by `stripQuotedStrings`, so
 * naive whitespace splitting is sufficient.
 *
 * @param {string} segment
 * @returns {string[]}
 */
function tokenize(segment) {
  return segment.split(/\s+/).filter(Boolean);
}


/**
 * Tokenize a short allowlisted shell command while preserving quoted
 * arguments. This is intentionally smaller than a full shell parser: the
 * caller rejects shell control characters before invoking it, so this only
 * needs to keep spaces inside quotes together for read-only git commands.
 *
 * @param {string} input
 * @returns {string[] | null}
 */
function tokenizeAllowlistedShellWords(input) {
  const tokens = [];
  let current = '';
  let quote = null;
  let escaped = false;

  for (const char of String(input || '')) {
    if (escaped) {
      current += char;
      escaped = false;
      continue;
    }

    if (char === '\\') {
      escaped = true;
      continue;
    }

    if (quote) {
      if (char === quote) {
        quote = null;
      } else {
        current += char;
      }
      continue;
    }

    if (char === '"' || char === "'") {
      quote = char;
      continue;
    }

    if (/\s/.test(char)) {
      if (current) {
        tokens.push(current);
        current = '';
      }
      continue;
    }

    current += char;
  }

  if (escaped) current += '\\';
  if (quote) return null;
  if (current) tokens.push(current);
  return tokens;
}

/**
 * Strip a leading path and trailing `.exe` from a command token so
 * `/usr/bin/git`, `git.exe`, and `GIT` all normalize to `git`.
 *
 * @param {string} token
 * @returns {string}
 */
function commandBasename(token) {
  if (!token) return '';
  return token.replace(/^.*[\\/]/, '').replace(/\.exe$/i, '').toLowerCase();
}

/**
 * Detect `rm` invocations that recursively force-delete files. Handles
 * combined (`-rf`, `-fr`, `-Rf`) and split (`-r -f`) flag forms.
 *
 * @param {string[]} tokens
 * @returns {boolean}
 */
function isDestructiveRm(tokens) {
  if (tokens.length === 0 || commandBasename(tokens[0]) !== 'rm') return false;
  let hasR = false;
  let hasF = false;
  for (const t of tokens.slice(1)) {
    if (t === '--recursive') {
      hasR = true;
      continue;
    }
    if (t === '--force') {
      hasF = true;
      continue;
    }
    if (!t.startsWith('-') || t.startsWith('--')) continue;
    const body = t.slice(1);
    if (/[rR]/.test(body)) hasR = true;
    if (/f/.test(body)) hasF = true;
  }
  return hasR && hasF;
}

/**
 * Locate the git subcommand within a token list, skipping over git's
 * global options like `-c key=value`, `-C <path>`, `--git-dir=...`,
 * `--work-tree=...`, `--namespace=...`, `--super-prefix=...`.
 *
 * @param {string[]} tokens
 * @returns {{ command: string, rest: string[] } | null}
 */
function findGitSubcommand(tokens) {
  if (tokens.length === 0 || commandBasename(tokens[0]) !== 'git') return null;
  const valueConsumingShort = new Set(['-c', '-C']);
  const valueConsumingLong = new Set(['--git-dir', '--work-tree', '--namespace', '--super-prefix']);
  let i = 1;
  while (i < tokens.length) {
    const t = tokens[i];
    if (valueConsumingShort.has(t) || valueConsumingLong.has(t)) {
      i += 2;
      continue;
    }
    if (t.startsWith('--git-dir=') || t.startsWith('--work-tree=') || t.startsWith('--namespace=') || t.startsWith('--super-prefix=')) {
      i += 1;
      continue;
    }
    if (t.startsWith('-')) {
      // Unknown global option — skip without consuming a value.
      i += 1;
      continue;
    }
    return { command: t.toLowerCase(), rest: tokens.slice(i + 1) };
  }
  return null;
}

/**
 * Detect destructive `git` invocations: `reset --hard`, `checkout --`,
 * `clean -f...`, `push --force` (but not `--force-with-lease`),
 * `commit --amend`, `rm -rf`.
 *
 * @param {string[]} tokens
 * @returns {boolean}
 */
function isDestructiveGit(tokens) {
  const sub = findGitSubcommand(tokens);
  if (!sub) return false;
  const { command, rest } = sub;

  if (command === 'reset') {
    return rest.includes('--hard');
  }

  if (command === 'checkout') {
    // `git checkout -- <path>`, `git checkout .`, and the force forms
    // (`--force` / `-f`) all discard uncommitted working-tree changes,
    // mirroring the `switch` handler below.
    return rest.some(t => {
      if (t === '--' || t === '.' || t === '--force') return true;
      if (!t.startsWith('-') || t.startsWith('--')) return false;
      return t.slice(1).includes('f');
    });
  }

  if (command === 'clean') {
    // `git clean -f`, `-fd`, `-fdx`, `-df`, `--force`
    return rest.some(t => {
      if (t === '--force') return true;
      if (!t.startsWith('-') || t.startsWith('--')) return false;
      return t.slice(1).includes('f');
    });
  }

  if (command === 'push') {
    // Only `--force-with-lease` qualifies as a safety-checked force.
    // `--force-if-includes` is a no-op when used WITHOUT
    // `--force-with-lease` (per git-scm.com/docs/git-push), and when
    // combined with a bare `--force` the bare force is still in effect.
    // So `--force --force-if-includes` must be treated as destructive.
    //
    // A `+` refspec prefix (e.g. `git push origin +main`,
    // `+refs/heads/main:refs/heads/main`) also forces a non-fast-forward
    // update of that ref and is destructive on its own.
    let withLease = false;
    let bareForce = false;
    let plusRefspecForce = false;
    for (const t of rest) {
      if (t === '--force-with-lease' || t.startsWith('--force-with-lease=')) {
        withLease = true;
        continue;
      }
      if (t === '--force' || t.startsWith('--force=')) {
        bareForce = true;
        continue;
      }
      if (t.startsWith('-') && !t.startsWith('--') && t.slice(1).includes('f')) {
        bareForce = true;
        continue;
      }
      // Refspec prefix: `+<src>[:<dst>]`. Match tokens like `+main`,
      // `+refs/heads/main`, `+HEAD:branch`, `+:branch`. Exclude bare
      // `+` and numeric-only `+123` which are not refspecs.
      if (t.startsWith('+') && t.length > 1 && /^\+(?:[a-zA-Z_/.:]|HEAD)/.test(t)) {
        plusRefspecForce = true;
      }
    }
    return bareForce || (plusRefspecForce && !withLease);
  }

  if (command === 'commit') {
    return rest.includes('--amend');
  }

  if (command === 'rm') {
    // `git rm -r` / `-rf` / `-r -f` — destructive within the index too.
    let hasR = false;
    for (const t of rest) {
      if (!t.startsWith('-') || t.startsWith('--')) continue;
      if (/[rR]/.test(t.slice(1))) hasR = true;
    }
    return hasR;
  }

  if (command === 'switch') {
    // `git switch` can discard local working-tree changes in three forms:
    //   --discard-changes           explicit discard
    //   --force / -f                ignore conflicts and overwrite
    //   -C <branch>                 force-create (overwrites existing branch)
    return rest.some(t => {
      if (t === '--discard-changes' || t === '--force') return true;
      if (!t.startsWith('-') || t.startsWith('--')) return false;
      // Short combined form: -f, -fC, -Cf, -C
      const body = t.slice(1);
      return /[fC]/.test(body);
    });
  }

  return false;
}

/**
 * Walk every executable body reachable from a raw command line and
 * return them as a flat list. Bodies that bash will execute live in
 * three different syntactic constructs:
 *   - `$(...)` and backticks via `extractCommandSubstitutions`
 *   - plain `(...)` subshells   via `extractSubshellGroups`
 *   - `{ ...; }` brace groups   via `extractBraceGroups`
 *
 * Each extractor recurses into its own syntax. The BFS here adds
 * cross-syntax discovery — e.g. a `(...)` inside a `$(...)` body, or
 * a `{ ...; }` inside a `(...)` body — by feeding every harvested
 * body back through all three extractors. A `seen` set bounds the
 * cost to O(unique bodies).
 *
 * @param {string} raw
 * @returns {string[]}
 */
function collectExecutableBodies(raw) {
  const bodies = [raw];
  const queue = [raw];
  const seen = new Set();

  while (queue.length) {
    const current = queue.shift();
    if (seen.has(current)) continue;
    seen.add(current);

    for (const body of extractCommandSubstitutions(current)) {
      if (seen.has(body)) continue;
      bodies.push(body);
      queue.push(body);
    }
    for (const body of extractSubshellGroups(current)) {
      if (seen.has(body)) continue;
      bodies.push(body);
      queue.push(body);
    }
    for (const body of extractBraceGroups(current)) {
      if (seen.has(body)) continue;
      bodies.push(body);
      queue.push(body);
    }
  }

  return bodies;
}

function isDestructiveBash(command) {
  // The SQL/dd phrases live in command bodies, not as flag-bearing
  // arguments, so we still match them by regex — but on the input
  // after quoting AND subshell delimiters are normalized so phrases
  // inside `$(...)` or backticks are also caught.
  const raw = String(command || '');
  const flattened = explodeSubshells(stripQuotedStrings(raw));
  if (DESTRUCTIVE_SQL_DD.test(flattened)) return true;

  // Operator-supplied additional destructive patterns. Same scope as the
  // built-in SQL/dd regex: matched against the quote-stripped, subshell-
  // exploded command so a phrase inside `$(...)` or backticks is caught.
  const extra = getExtraDestructiveRegex();
  if (extra && extra.test(flattened)) return true;

  const segments = collectExecutableBodies(raw).flatMap(splitCommandSegments);
  for (const segment of segments) {
    const stripped = stripQuotedStrings(segment);
    if (DESTRUCTIVE_SQL_DD.test(stripped)) return true;
    if (extra && extra.test(stripped)) return true;
    const tokens = tokenize(segment);
    if (isDestructiveRm(tokens)) return true;
    if (isDestructiveGit(tokens)) return true;
  }
  return false;
}

// --- State management (per-session, atomic writes, bounded) ---

function normalizeEnvValue(value) {
  return String(value || '').trim().toLowerCase();
}

function isGateGuardDisabled() {
  if (normalizeEnvValue(process.env.UNI_GATE_DISABLED) === '1') {
    return true;
  }

  return UNI_DISABLE_VALUES.has(normalizeEnvValue(process.env.UNI_GATE_OFF));
}

function sanitizeSessionKey(value) {
  const raw = String(value || '').trim();
  if (!raw) {
    return '';
  }

  const sanitized = raw.replace(/[^a-zA-Z0-9_-]/g, '_');
  if (sanitized && sanitized.length <= 64) {
    return sanitized;
  }

  return hashSessionKey('sid', raw);
}

function hashSessionKey(prefix, value) {
  return `${prefix}-${crypto.createHash('sha256').update(String(value)).digest('hex').slice(0, 24)}`;
}

function resolveSessionKey(data) {
  const directCandidates = [data && data.session_id, data && data.sessionId, data && data.session && data.session.id, process.env.CLAUDE_SESSION_ID];

  for (const candidate of directCandidates) {
    const sanitized = sanitizeSessionKey(candidate);
    if (sanitized) {
      return sanitized;
    }
  }

  const transcriptPath = (data && (data.transcript_path || data.transcriptPath)) || process.env.CLAUDE_TRANSCRIPT_PATH;
  if (transcriptPath && String(transcriptPath).trim()) {
    return hashSessionKey('tx', path.resolve(String(transcriptPath).trim()));
  }

  const projectFingerprint = process.env.CLAUDE_PROJECT_DIR || process.cwd();
  return hashSessionKey('proj', path.resolve(projectFingerprint));
}

function getStateFile(data) {
  if (!activeStateFile) {
    const sessionKey = resolveSessionKey(data);
    activeStateFile = path.join(STATE_DIR, `state-${sessionKey}.json`);
  }
  return activeStateFile;
}

function loadState() {
  const stateFile = getStateFile();
  try {
    if (fs.existsSync(stateFile)) {
      const state = JSON.parse(fs.readFileSync(stateFile, 'utf8'));
      const lastActive = state.last_active || 0;
      if (Date.now() - lastActive > SESSION_TIMEOUT_MS) {
        try {
          fs.unlinkSync(stateFile);
        } catch (_) {
          /* ignore */
        }
        return { checked: [], last_active: Date.now() };
      }
      return state;
    }
  } catch (_) {
    /* ignore */
  }
  return { checked: [], last_active: Date.now() };
}

function pruneCheckedEntries(checked) {
  if (checked.length <= MAX_CHECKED_ENTRIES) {
    return checked;
  }

  const preserved = checked.includes(ROUTINE_BASH_SESSION_KEY) ? [ROUTINE_BASH_SESSION_KEY] : [];
  const sessionKeys = checked.filter(k => k.startsWith('__') && k !== ROUTINE_BASH_SESSION_KEY);
  const fileKeys = checked.filter(k => !k.startsWith('__'));
  const remainingSessionSlots = Math.max(MAX_SESSION_KEYS - preserved.length, 0);
  const cappedSession = sessionKeys.slice(-remainingSessionSlots);
  const remainingFileSlots = Math.max(MAX_CHECKED_ENTRIES - preserved.length - cappedSession.length, 0);
  const cappedFiles = fileKeys.slice(-remainingFileSlots);
  return [...preserved, ...cappedSession, ...cappedFiles];
}

function saveState(state) {
  const stateFile = getStateFile();
  let tmpFile = null;
  try {
    fs.mkdirSync(STATE_DIR, { recursive: true });

    let mergedChecked = Array.isArray(state.checked) ? state.checked : [];
    let mergedLastActive = typeof state.last_active === 'number' ? state.last_active : 0;

    try {
      if (fs.existsSync(stateFile)) {
        const diskState = JSON.parse(fs.readFileSync(stateFile, 'utf8'));
        if (Array.isArray(diskState.checked)) {
          mergedChecked = Array.from(new Set([...diskState.checked, ...mergedChecked]));
        }
        if (typeof diskState.last_active === 'number') {
          mergedLastActive = Math.max(mergedLastActive, diskState.last_active);
        }
      }
    } catch (_) {
      /* ignore malformed or transient disk state */
    }

    const finalState = {
      checked: pruneCheckedEntries(mergedChecked),
      last_active: Math.max(mergedLastActive, Date.now())
    };

    // Atomic write: temp file + rename prevents partial reads
    tmpFile = `${stateFile}.tmp.${process.pid}.${crypto.randomBytes(4).toString('hex')}`;
    fs.writeFileSync(tmpFile, JSON.stringify(finalState, null, 2), 'utf8');
    try {
      fs.renameSync(tmpFile, stateFile);
    } catch (error) {
      if (error && (error.code === 'EEXIST' || error.code === 'EPERM')) {
        try {
          fs.unlinkSync(stateFile);
        } catch (_) {
          /* ignore */
        }
        fs.renameSync(tmpFile, stateFile);
      } else {
        throw error;
      }
    }
    tmpFile = null;
    return true;
  } catch (_) {
    if (tmpFile) {
      try {
        fs.unlinkSync(tmpFile);
      } catch (_) {
        /* ignore */
      }
    }
    return false;
  }
}

function markChecked(key) {
  const state = loadState();
  if (!state.checked.includes(key)) {
    state.checked.push(key);
    return saveState(state);
  }
  return true;
}

function isChecked(key) {
  const state = loadState();
  const found = state.checked.includes(key);
  if (found && Date.now() - (state.last_active || 0) > READ_HEARTBEAT_MS) {
    saveState(state);
  }
  return found;
}

// Prune stale session files older than 1 hour
(function pruneStaleFiles() {
  try {
    const files = fs.readdirSync(STATE_DIR);
    const now = Date.now();
    for (const f of files) {
      const isStateFile = f.startsWith('state-') && (f.endsWith('.json') || f.includes('.json.tmp.'));
      if (!isStateFile) continue;
      const fp = path.join(STATE_DIR, f);
      try {
        const stat = fs.statSync(fp);
        if (now - stat.mtimeMs > SESSION_TIMEOUT_MS * 2) {
          fs.unlinkSync(fp);
        }
      } catch (_) {
        // Ignore files that disappear between readdir/stat/unlink.
      }
    }
  } catch (_) {
    /* ignore */
  }
})();

// --- Sanitize file path against injection ---

function sanitizePath(filePath) {
  // Strip control chars (including null), bidi overrides, and newlines
  let sanitized = '';
  for (const char of String(filePath || '')) {
    const code = char.codePointAt(0);
    const isAsciiControl = code <= 0x1f || code === 0x7f;
    const isBidiOverride = (code >= 0x200e && code <= 0x200f) || (code >= 0x202a && code <= 0x202e) || (code >= 0x2066 && code <= 0x2069);
    sanitized += isAsciiControl || isBidiOverride ? ' ' : char;
  }
  return sanitized.trim().slice(0, 500);
}

function normalizeForMatch(value) {
  return String(value || '')
    .replace(/\\/g, '/')
    .toLowerCase();
}

function isClaudeSettingsPath(filePath) {
  const normalized = normalizeForMatch(filePath);
  return /(^|\/)\.claude\/settings(?:\.[^/]+)?\.json$/.test(normalized);
}

function isReadOnlyGitIntrospection(command) {
  const trimmed = String(command || '').trim();
  if (!trimmed || /[\r\n;&|><`$()]/.test(trimmed)) {
    return false;
  }

  const segments = splitCommandSegments(trimmed);
  if (segments.length !== 1) {
    return false;
  }

  const tokens = tokenizeAllowlistedShellWords(trimmed);
  if (!tokens) {
    return false;
  }
  if (commandBasename(tokens[0]) !== 'git' || tokens.length < 2) {
    return false;
  }

  const subcommand = tokens[1].toLowerCase();
  const args = tokens.slice(2);

  if (subcommand === 'status') {
    return args.every(arg => ['--porcelain', '--short', '--branch'].includes(arg));
  }

  if (subcommand === 'diff') {
    return args.length <= 1 && args.every(arg => ['--name-only', '--name-status'].includes(arg));
  }

  if (subcommand === 'log') {
    return args.every(arg => arg === '--oneline' || /^--max-count=\d+$/.test(arg));
  }

  if (subcommand === 'show') {
    return args.length === 1 && !args[0].startsWith('--') && /^[a-zA-Z0-9._:/ -]+$/.test(args[0]);
  }

  if (subcommand === 'branch') {
    return args.length === 1 && args[0] === '--show-current';
  }

  if (subcommand === 'rev-parse') {
    return args.length === 2 && args[0] === '--abbrev-ref' && /^head$/i.test(args[1]);
  }

  return false;
}

// --- Gate messages ---

function editGateMsg(filePath) {
  const safe = sanitizePath(filePath);
  return [
    '[Fact-Forcing Gate]',
    '',
    `Before editing ${safe}, present these facts:`,
    '',
    '1. List ALL files that import/require this file (use Grep)',
    '2. List the public functions/classes affected by this change',
    '3. If this file reads/writes data files, show field names, structure, and date format (use redacted or synthetic values, not raw production data)',
    "4. Quote the user's current instruction verbatim",
    '',
    'Present the facts, then retry the same operation.'
  ].join('\n');
}

function writeGateMsg(filePath) {
  const safe = sanitizePath(filePath);
  return [
    '[Fact-Forcing Gate]',
    '',
    `Before creating ${safe}, present these facts:`,
    '',
    '1. Name the file(s) and line(s) that will call this new file',
    '2. Confirm no existing file serves the same purpose (use Glob)',
    '3. If this file reads/writes data files, show field names, structure, and date format (use redacted or synthetic values, not raw production data)',
    "4. Quote the user's current instruction verbatim",
    '',
    'Present the facts, then retry the same operation.'
  ].join('\n');
}

function destructiveBashMsg() {
  return [
    '[Fact-Forcing Gate]',
    '',
    'Destructive command detected. Before running, present:',
    '',
    '1. List all files/data this command will modify or delete',
    '2. Write a one-line rollback procedure',
    "3. Quote the user's current instruction verbatim",
    '',
    'Present the facts, then retry the same operation.'
  ].join('\n');
}

function routineBashMsg() {
  return [
    '[Fact-Forcing Gate]',
    '',
    'Before the first Bash command this session, present these facts:',
    '',
    '1. The current user request in one sentence',
    '2. What this specific command verifies or produces',
    '',
    'Present the facts, then retry the same operation.'
  ].join('\n');
}

function withRecoveryHint(message, hookIds = [EDIT_WRITE_HOOK_ID]) {
  const disableTargets = hookIds.map(hookId => `\`${hookId}\``).join(' or ');
  return [
    message,
    '',
    `Recovery: if the gate is blocking setup or repair work, run this session with \`UNI_GATE_OFF=off\` or add ${disableTargets} to \`UNI_DISABLED_HOOKS\`.`
  ].join('\n');
}

function isSubagentInvocation(data) {
  if (!data || typeof data !== 'object') {
    return false;
  }

  const candidates = [
    data.agent_id,
    data.agentId,
    data.parent_tool_use_id,
    data.parentToolUseId
  ];

  return candidates.some(candidate => typeof candidate === 'string' && candidate.trim());
}

// --- Deny helper ---

function denyResult(reason, options = {}) {
  const includeRecoveryHint = options.includeRecoveryHint !== false;
  const hookIds = Array.isArray(options.hookIds) && options.hookIds.length > 0 ? options.hookIds : [EDIT_WRITE_HOOK_ID];
  return {
    stdout: JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'deny',
        permissionDecisionReason: includeRecoveryHint ? withRecoveryHint(reason, hookIds) : reason
      }
    }),
    exitCode: 0
  };
}

function allowWithStateWarning() {
  return {
    stderr: '[Fact-Forcing Gate] GateGuard state could not be persisted; allowing this operation to avoid a permanent retry loop. Check UNI_GATE_STATE_DIR or filesystem permissions.',
    exitCode: 0
  };
}

// --- Core logic ---

function run(rawInput) {
  let data;
  try {
    data = typeof rawInput === 'string' ? JSON.parse(rawInput) : rawInput;
  } catch (_) {
    return rawInput; // allow on parse error
  }

  if (isGateGuardDisabled() || isHookProfileSilent()) {
    return rawInput;
  }

  activeStateFile = null;
  getStateFile(data);

  const rawToolName = data.tool_name || '';
  const toolInput = data.tool_input || {};
  // Normalize: case-insensitive matching via lookup map
  const TOOL_MAP = { edit: 'Edit', write: 'Write', multiedit: 'MultiEdit', bash: 'Bash' };
  const toolName = TOOL_MAP[rawToolName.toLowerCase()] || rawToolName;
  const inSubagent = isSubagentInvocation(data);

  if (toolName === 'Edit' || toolName === 'Write') {
    const filePath = toolInput.file_path || '';
    if (!filePath || isClaudeSettingsPath(filePath)) {
      return rawInput; // allow
    }

    if (inSubagent) {
      return rawInput; // parent session already passed the first-touch file gate
    }

    if (isHookDisabled(EDIT_WRITE_HOOK_ID)) {
      return rawInput; // allow
    }

    if (!isChecked(filePath)) {
      if (!markChecked(filePath)) {
        return allowWithStateWarning();
      }
      return denyResult(toolName === 'Edit' ? editGateMsg(filePath) : writeGateMsg(filePath));
    }

    return rawInput; // allow
  }

  if (toolName === 'MultiEdit') {
    if (inSubagent) {
      return rawInput; // parent session already passed the first-touch file gate
    }

    if (isHookDisabled(EDIT_WRITE_HOOK_ID)) {
      return rawInput; // allow
    }

    const edits = toolInput.edits || [];
    for (const edit of edits) {
      const filePath = edit.file_path || '';
      if (filePath && !isClaudeSettingsPath(filePath) && !isChecked(filePath)) {
        if (!markChecked(filePath)) {
          return allowWithStateWarning();
        }
        return denyResult(editGateMsg(filePath));
      }
    }
    return rawInput; // allow
  }

  if (toolName === 'Bash') {
    if (isHookDisabled(BASH_HOOK_ID)) {
      return rawInput; // allow
    }

    const command = toolInput.command || '';
    if (isReadOnlyGitIntrospection(command)) {
      return rawInput;
    }

    if (isDestructiveBash(command)) {
      // Gate destructive commands on first attempt; allow retry after facts presented
      const key = '__destructive__' + crypto.createHash('sha256').update(command).digest('hex').slice(0, 16);
      if (!isChecked(key)) {
        if (!markChecked(key)) {
          return allowWithStateWarning();
        }
        return denyResult(destructiveBashMsg(), { includeRecoveryHint: false });
      }
      return rawInput; // allow retry after facts presented
    }

    // Operator opt-out: skip the routine-bash gate entirely. The destructive
    // gate above still fires. This is the documented escape hatch for hosts
    // where the once-per-session routine gate is friction without signal.
    if (isRoutineBashGateDisabled()) {
      return rawInput; // routine gate opted out via env
    }

    if (!isChecked(ROUTINE_BASH_SESSION_KEY)) {
      if (!markChecked(ROUTINE_BASH_SESSION_KEY)) {
        return allowWithStateWarning();
      }
      return denyResult(routineBashMsg(), { hookIds: [BASH_HOOK_ID] });
    }

    return rawInput; // allow
  }

  return rawInput; // allow
}

// Standalone entry point (replaces ECC's module.exports / run-with-flags.js)
let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => raw += c);
process.stdin.on('end', () => {
  const result = run(raw);
  if (result && typeof result === 'object') {
    if (result.stderr) process.stderr.write(result.stderr);
    if (typeof result.stdout === 'string') process.stdout.write(result.stdout);
    else process.stdout.write(typeof raw === 'string' ? raw : '');
    process.exitCode = Number.isInteger(result.exitCode) ? result.exitCode : 0;
  } else {
    process.stdout.write(typeof result === 'string' ? result : raw);
  }
});
