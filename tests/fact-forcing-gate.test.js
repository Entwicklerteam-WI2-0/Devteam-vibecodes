#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { afterEach, beforeEach, describe, test } = require('node:test');

const GATE = path.resolve(__dirname, '..', '.claude', 'hooks', 'fact-forcing-gate.js');
const SESSION_ID = 'test-session-42';

function run(input, env = {}) {
  const result = spawnSync(process.execPath, [GATE], {
    input: typeof input === 'string' ? input : JSON.stringify(input),
    encoding: 'utf8',
    env: {
      ...process.env,
      UNI_GATE_STATE_DIR: env.stateDir,
      UNI_GATE_OFF: env.uniGateOff,
      UNI_GATE_DISABLED: env.uniGateDisabled,
      UNI_DISABLED_HOOKS: env.uniDisabledHooks,
      UNI_HOOK_PROFILE: env.uniHookProfile,
      UNI_GATE_BASH_ROUTINE_DISABLED: env.uniGateBashRoutineDisabled,
      UNI_GATE_BASH_EXTRA_DESTRUCTIVE: env.uniGateBashExtraDestructive,
      // Clear legacy ECC env vars to avoid cross-talk in dev environments.
      ECC_GATEGUARD: undefined,
      GATEGUARD_DISABLED: undefined,
      ECC_DISABLED_HOOKS: undefined,
      ECC_HOOK_PROFILE: undefined,
      GATEGUARD_BASH_ROUTINE_DISABLED: undefined,
      GATEGUARD_STATE_DIR: undefined,
      GATEGUARD_BASH_EXTRA_DESTRUCTIVE: undefined,
    },
  });
  let parsed = null;
  if (result.stdout) {
    try {
      parsed = JSON.parse(result.stdout);
    } catch (_) {
      parsed = null;
    }
  }
  return {
    exitCode: result.status,
    stdout: result.stdout,
    stderr: result.stderr,
    parsed,
  };
}

function editPayload(filePath) {
  return {
    tool_name: 'Edit',
    session_id: SESSION_ID,
    tool_input: {
      file_path: filePath,
      old_string: 'foo',
      new_string: 'bar',
    },
  };
}

function writePayload(filePath) {
  return {
    tool_name: 'Write',
    session_id: SESSION_ID,
    tool_input: {
      file_path: filePath,
      content: '// hello',
    },
  };
}

function bashPayload(command) {
  return {
    tool_name: 'Bash',
    session_id: SESSION_ID,
    tool_input: { command },
  };
}

function multiEditPayload(filePaths) {
  return {
    tool_name: 'MultiEdit',
    session_id: SESSION_ID,
    tool_input: {
      edits: filePaths.map(fp => ({
        file_path: fp,
        old_string: 'a',
        new_string: 'b',
      })),
    },
  };
}

function denyReason(result) {
  return result.parsed?.hookSpecificOutput?.permissionDecisionReason || '';
}

function isDenied(result) {
  return result.parsed?.hookSpecificOutput?.permissionDecision === 'deny';
}

function stateFile(stateDir) {
  return path.join(stateDir, `state-${SESSION_ID}.json`);
}

function primeBashSession(stateDir) {
  fs.mkdirSync(stateDir, { recursive: true });
  fs.writeFileSync(stateFile(stateDir), JSON.stringify({
    checked: ['__bash_session__'],
    last_active: Date.now(),
  }), 'utf8');
}

describe('Fact-Forcing Gate', () => {
  let stateDir;

  beforeEach(() => {
    stateDir = fs.mkdtempSync(path.join(os.tmpdir(), 'uni-gate-test-'));
  });

  afterEach(() => {
    try {
      fs.rmSync(stateDir, { recursive: true, force: true });
    } catch (_) {
      /* ignore */
    }
  });

  test('1: Edit on fresh state is denied with file path and import/require', () => {
    const result = run(editPayload('/src/app.js'), { stateDir });
    assert.equal(result.exitCode, 0, 'exit code 0');
    assert.equal(isDenied(result), true, 'denied');
    const reason = denyReason(result);
    assert.match(reason, /\[Fact-Forcing Gate\]/);
    assert.match(reason, /Before editing \/src\/app\.js/);
    assert.match(reason, /import\/require/);
  });

  test('2: Same Edit again is allowed (checked state)', () => {
    run(editPayload('/src/app.js'), { stateDir });
    const result = run(editPayload('/src/app.js'), { stateDir });
    assert.equal(result.exitCode, 0);
    assert.equal(isDenied(result), false, 'allowed on retry');
    assert.equal(result.stdout.trim(), JSON.stringify(editPayload('/src/app.js')));
  });

  test('3: Write on fresh state is denied with creating + call this new file', () => {
    const result = run(writePayload('/src/new.js'), { stateDir });
    assert.equal(result.exitCode, 0);
    assert.equal(isDenied(result), true);
    const reason = denyReason(result);
    assert.match(reason, /Before creating \/src\/new\.js/);
    assert.match(reason, /creating/);
    assert.match(reason, /call this new file/);
  });

  test('3b: UNI_GATE_STATE_DIR pointing to a file fails open with warning', () => {
    const fileState = path.join(stateDir, 'not-a-dir');
    fs.writeFileSync(fileState, '{}', 'utf8');
    const result = run(writePayload('/src/new.js'), { stateDir: fileState });
    assert.equal(result.exitCode, 0);
    assert.equal(isDenied(result), false, 'allowed when state cannot be persisted');
    assert.match(result.stderr, /GateGuard state could not be persisted/);
  });

  test('4: Destructive Bash first denied, then allowed', () => {
    const payload = bashPayload('rm -rf /important/data');
    const r1 = run(payload, { stateDir });
    assert.equal(isDenied(r1), true, 'first destructive denied');
    assert.match(denyReason(r1), /Destructive command detected/);
    assert.match(denyReason(r1), /rollback/);

    const r2 = run(payload, { stateDir });
    assert.equal(isDenied(r2), false, 'second destructive allowed');
  });

  test('6: git commit --amend is destructive', () => {
    const result = run(bashPayload('git commit --amend --no-edit'), { stateDir });
    assert.equal(isDenied(result), true);
    assert.match(denyReason(result), /Destructive command detected/);
  });

  test('7: git push --force is destructive', () => {
    const result = run(bashPayload('git push --force origin feature'), { stateDir });
    assert.equal(isDenied(result), true);
    assert.match(denyReason(result), /Destructive command detected/);
  });

  test('8: Routine Bash first denied with hook id, then allowed', () => {
    const payload = bashPayload('ls -la');
    const r1 = run(payload, { stateDir });
    assert.equal(isDenied(r1), true, 'first routine bash denied');
    const reason = denyReason(r1);
    assert.match(reason, /current user request/);
    assert.match(reason, /uni:pre:bash:fact-force/);
    assert.doesNotMatch(reason, /uni:pre:edit-write:fact-force/);

    const r2 = run(payload, { stateDir });
    assert.equal(isDenied(r2), false, 'second routine bash allowed');
  });

  test('9: State timeout resets checked entries', () => {
    const sf = stateFile(stateDir);
    fs.mkdirSync(stateDir, { recursive: true });
    fs.writeFileSync(sf, JSON.stringify({
      checked: ['some.js', '__bash_session__'],
      last_active: Date.now() - 31 * 60 * 1000,
    }), 'utf8');

    const result = run(editPayload('some.js'), { stateDir });
    assert.equal(isDenied(result), true, 'denied after timeout reset');
  });

  test('10: Read tool passes through', () => {
    const payload = {
      tool_name: 'Read',
      session_id: SESSION_ID,
      tool_input: { file_path: '/src/app.js' },
    };
    const result = run(payload, { stateDir });
    assert.equal(result.exitCode, 0);
    assert.equal(isDenied(result), false);
    assert.equal(result.stdout.trim(), JSON.stringify(payload));
  });

  test('11: file_path with newline is sanitized', () => {
    const result = run(editPayload('/src/app.js\ninjected'), { stateDir });
    assert.equal(isDenied(result), true);
    const reason = denyReason(result);
    // Newline/bidi chars are replaced by spaces; the visible path must not
    // carry the raw injection or the "injected" suffix as part of the filename.
    assert.match(reason, /Before editing \/src\/app\.js[\s,]/);
    assert.doesNotMatch(reason, /app\.js\n/);
    assert.doesNotMatch(reason, /app\.jsinjected/);
  });

  test('12: UNI_DISABLED_HOOKS disables edit-write gate', () => {
    const result = run(editPayload('/src/app.js'), {
      stateDir,
      uniDisabledHooks: 'uni:pre:edit-write:fact-force',
    });
    assert.equal(isDenied(result), false);
    assert.equal(result.parsed?.hookSpecificOutput, undefined, 'no hookSpecificOutput');
  });

  test('13: UNI_GATE_OFF=off passes through and leaves no state file', () => {
    const result = run(writePayload('/src/new.js'), { stateDir, uniGateOff: 'off' });
    assert.equal(isDenied(result), false);
    assert.equal(fs.existsSync(stateFile(stateDir)), false, 'no state file created');
  });

  test('14: UNI_GATE_DISABLED="1" passes through and leaves no state file', () => {
    const result = run(bashPayload('ls -la'), { stateDir, uniGateDisabled: '1' });
    assert.equal(isDenied(result), false);
    assert.equal(fs.existsSync(stateFile(stateDir)), false, 'no state file created');
  });

  test('15: UNI_GATE_DISABLED="true" does NOT disable (only exact "1")', () => {
    const result = run(bashPayload('ls -la'), { stateDir, uniGateDisabled: 'true' });
    assert.equal(isDenied(result), true, 'routine bash still denied');
  });

  test('16: Write denial contains UNI_GATE_OFF and UNI_DISABLED_HOOKS recovery', () => {
    const result = run(writePayload('/src/new.js'), { stateDir });
    const reason = denyReason(result);
    assert.match(reason, /UNI_GATE_OFF/);
    assert.match(reason, /UNI_DISABLED_HOOKS/);
  });

  test('17: Routine Bash denial names only bash hook id', () => {
    const result = run(bashPayload('ls -la'), { stateDir });
    const reason = denyReason(result);
    assert.match(reason, /uni:pre:bash:fact-force/);
    assert.doesNotMatch(reason, /uni:pre:edit-write:fact-force/);
  });

  test('18: Destructive Bash denial has no escape hatch', () => {
    const result = run(bashPayload('rm -rf /important/data'), { stateDir });
    const reason = denyReason(result);
    assert.match(reason, /Destructive command detected/);
    assert.doesNotMatch(reason, /UNI_GATE_OFF/);
    assert.doesNotMatch(reason, /UNI_DISABLED_HOOKS/);
  });

  test('19/20: MultiEdit gates each new file then allows full payload', () => {
    const payload = multiEditPayload(['multi-a.js', 'multi-b.js']);
    const r1 = run(payload, { stateDir });
    assert.equal(isDenied(r1), true);
    assert.match(denyReason(r1), /multi-a\.js/);

    const r2 = run(payload, { stateDir });
    assert.equal(isDenied(r2), true);
    assert.match(denyReason(r2), /multi-b\.js/);

    const r3 = run(payload, { stateDir });
    assert.equal(isDenied(r3), false);
    assert.equal(r3.stdout.trim(), JSON.stringify(payload));
  });

  test('25: Edit on .claude/settings.json passes through', () => {
    const result = run(editPayload('/foo/.claude/settings.json'), { stateDir });
    assert.equal(isDenied(result), false);
  });

  test('26: git status --short is read-only allowed', () => {
    const result = run(bashPayload('git status --short'), { stateDir });
    assert.equal(isDenied(result), false);
  });

  test('27: git status && rm -rf is destructive in chain', () => {
    const result = run(bashPayload('git status && rm -rf /tmp/demo'), { stateDir });
    assert.equal(isDenied(result), true);
    assert.match(denyReason(result), /Destructive command detected/);
  });

  test('29: malformed JSON is echoed unchanged', () => {
    const input = '{ not valid json';
    const result = run(input, { stateDir });
    assert.equal(result.exitCode, 0);
    assert.equal(result.stdout, input);
  });

  test('40: Edit with agent_id passes through; without agent_id is denied', () => {
    const withAgent = {
      ...editPayload('/src/agented.js'),
      agent_id: 'a-1',
    };
    const r1 = run(withAgent, { stateDir });
    assert.equal(isDenied(r1), false, 'subagent edit allowed');

    const r2 = run(editPayload('/src/agented.js'), { stateDir });
    assert.equal(isDenied(r2), true, 'non-subagent edit denied');
  });

  test('43: Routine Bash with agent_id stays gated', () => {
    const payload = {
      ...bashPayload('ls -la'),
      agent_id: 'a-1',
    };
    const result = run(payload, { stateDir });
    assert.equal(isDenied(result), true, 'bash remains gated in subagent');
  });

  test('45: various destructive git/rm forms are denied', () => {
    const commands = [
      'git push -f',
      'rm -fr /tmp/x',
      'rm -r -f /tmp/x',
      'rm --recursive --force /tmp/x',
      'git reset HEAD --hard',
      'git clean -fd',
    ];
    for (const command of commands) {
      const result = run(bashPayload(command), { stateDir });
      assert.equal(isDenied(result), true, `expected destructive: ${command}`);
      assert.match(denyReason(result), /Destructive command detected/, `reason for ${command}`);
    }
  });

  test('47: git commit -m with quoted rm -rf is allowed', () => {
    primeBashSession(stateDir);
    const result = run(bashPayload("git commit -m 'fix: rm -rf race'"), { stateDir });
    assert.equal(isDenied(result), false, 'quoted literal should not trigger');
  });

  test('48: git push --force-with-lease --force-if-includes is allowed', () => {
    primeBashSession(stateDir);
    const result = run(bashPayload('git push --force-with-lease --force-if-includes origin main'), { stateDir });
    assert.equal(isDenied(result), false, 'force-with-lease is safe');
  });

  test('49: git push --force --force-if-includes is denied', () => {
    const result = run(bashPayload('git push --force --force-if-includes origin main'), { stateDir });
    assert.equal(isDenied(result), true, 'bare force with includes is still destructive');
  });

  test('57: UNI_GATE_BASH_ROUTINE_DISABLED=1 allows routine bash', () => {
    const result = run(bashPayload('ls -la'), { stateDir, uniGateBashRoutineDisabled: '1' });
    assert.equal(isDenied(result), false, 'routine bash allowed when disabled');
  });

  test('58: UNI_GATE_BASH_ROUTINE_DISABLED=1 still denies destructive bash', () => {
    const result = run(bashPayload('rm -rf /x'), { stateDir, uniGateBashRoutineDisabled: '1' });
    assert.equal(isDenied(result), true, 'destructive still denied');
  });

  test('60: UNI_GATE_BASH_EXTRA_DESTRUCTIVE catches custom pattern', () => {
    const result = run(bashPayload('supabase db reset --linked'), {
      stateDir,
      uniGateBashExtraDestructive: 'supabase\\s+db\\s+reset',
    });
    assert.equal(isDenied(result), true);
    assert.match(denyReason(result), /Destructive command detected/);
  });
});
