// SCAFFOLD-SVC-001 / T005: verifies AC-1 quality obligation - the service starts using only
// environment-based configuration and its health-check endpoint responds.
import { spawn, type ChildProcess } from 'node:child_process';
import { once } from 'node:events';
import path from 'node:path';
import { afterEach, describe, expect, it } from 'vitest';

const root = path.resolve(__dirname, '..');
const tsxBin = path.join(root, 'node_modules', '.bin', 'tsx');
const entry = path.join(root, 'src', 'index.ts');
const children: ChildProcess[] = [];

function start(env: NodeJS.ProcessEnv): { child: ChildProcess; output: () => string } {
  const child = spawn(tsxBin, [entry], {
    cwd: root,
    env: { PATH: process.env.PATH, ...env },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  let out = '';
  child.stdout?.on('data', (d) => (out += d));
  child.stderr?.on('data', (d) => (out += d));
  children.push(child);
  return { child, output: () => out };
}

async function waitForHealth(port: number, timeoutMs = 15000): Promise<Response> {
  const deadline = Date.now() + timeoutMs;
  for (;;) {
    try {
      return await fetch(`http://127.0.0.1:${port}/health`);
    } catch (err) {
      if (Date.now() > deadline) throw err;
      await new Promise((r) => setTimeout(r, 200));
    }
  }
}

afterEach(() => {
  for (const c of children.splice(0)) c.kill('SIGTERM');
});

const hasTestDb = Boolean(process.env.TEST_DB_HOST);
const dbEnv = hasTestDb
  ? {
      DB_HOST: process.env.TEST_DB_HOST,
      DB_PORT: process.env.TEST_DB_PORT,
      DB_NAME: process.env.TEST_DB_NAME,
      DB_USER: process.env.TEST_DB_USER,
      DB_PASSWORD: process.env.TEST_DB_PASSWORD,
    }
  : {
      DB_HOST: '127.0.0.1',
      DB_PORT: '1',
      DB_NAME: 'unused',
      DB_USER: 'unused',
      DB_PASSWORD: 'unused-placeholder',
      DB_CONNECTION_TIMEOUT_MS: '250',
    };

describe('T005 AC-1 service startup', () => {
  it('starts from env vars only and serves /health and /health/ready', async () => {
    const port = 39000 + Math.floor(Math.random() * 1000);
    const { output } = start({ PORT: String(port), LOG_LEVEL: 'info', ...dbEnv });
    const res = await waitForHealth(port);
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ status: 'ok', service: 'account-management-service' });

    const ready = await fetch(`http://127.0.0.1:${port}/health/ready`);
    expect(ready.status).toBe(hasTestDb ? 200 : 503);
    expect(output()).not.toContain(String(dbEnv.DB_PASSWORD));
  }, 30000);

  it('exits non-zero on missing configuration without logging secret values', async () => {
    const { child, output } = start({ DB_PASSWORD: 'should-not-appear' });
    const [code] = await once(child, 'exit');
    expect(code).toBe(1);
    expect(output()).toContain('invalid configuration');
    expect(output()).toContain('PORT');
    expect(output()).not.toContain('should-not-appear');
  }, 30000);
});
