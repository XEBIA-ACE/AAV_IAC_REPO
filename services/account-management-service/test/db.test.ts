// SCAFFOLD-SVC-001 / T004 + AC-1: PostgreSQL connection helper.
// The integration case runs only when TEST_DB_* variables point at a real PostgreSQL instance.
import { describe, expect, it } from 'vitest';
import { loadConfig } from '../src/config';
import { checkDatabase, createPool, toPoolConfig } from '../src/db';

const baseEnv = {
  PORT: '3000',
  DB_HOST: 'db.internal',
  DB_PORT: '6543',
  DB_NAME: 'accounts',
  DB_USER: 'svc',
  DB_PASSWORD: 'pw',
  DB_SSL: 'true',
  DB_POOL_MAX: '4',
  DB_CONNECTION_TIMEOUT_MS: '250',
};

describe('T004 database helper', () => {
  it('maps env-derived config to a pg pool config', () => {
    const { db } = loadConfig(baseEnv);
    expect(toPoolConfig(db)).toEqual({
      host: 'db.internal',
      port: 6543,
      database: 'accounts',
      user: 'svc',
      password: 'pw',
      ssl: { rejectUnauthorized: true },
      max: 4,
      connectionTimeoutMillis: 250,
    });
  });

  it('checkDatabase resolves false (does not throw) when the database is unreachable', async () => {
    const { db } = loadConfig({ ...baseEnv, DB_HOST: '127.0.0.1', DB_PORT: '1', DB_SSL: 'false' });
    const pool = createPool(db);
    await expect(checkDatabase(pool)).resolves.toBe(false);
    await pool.end();
  });

  const hasTestDb = Boolean(process.env.TEST_DB_HOST);
  it.skipIf(!hasTestDb)('checkDatabase resolves true against a real PostgreSQL', async () => {
    const { db } = loadConfig({
      PORT: '3000',
      DB_HOST: process.env.TEST_DB_HOST,
      DB_PORT: process.env.TEST_DB_PORT,
      DB_NAME: process.env.TEST_DB_NAME,
      DB_USER: process.env.TEST_DB_USER,
      DB_PASSWORD: process.env.TEST_DB_PASSWORD,
    });
    const pool = createPool(db);
    await expect(checkDatabase(pool)).resolves.toBe(true);
    await pool.end();
  });
});
