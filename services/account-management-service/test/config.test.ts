// SCAFFOLD-SVC-001 / T002 + AC-1: environment-only configuration loading.
import { describe, expect, it } from 'vitest';
import { ConfigError, loadConfig } from '../src/config';

const validEnv = {
  PORT: '3000',
  DB_HOST: 'db.internal',
  DB_NAME: 'accounts',
  DB_USER: 'svc',
  DB_PASSWORD: 's3cr3t-value',
};

describe('T002 loadConfig', () => {
  it('builds config from environment variables with non-sensitive defaults', () => {
    const config = loadConfig(validEnv);
    expect(config.port).toBe(3000);
    expect(config.nodeEnv).toBe('development');
    expect(config.db).toEqual({
      host: 'db.internal',
      port: 5432,
      database: 'accounts',
      user: 'svc',
      password: 's3cr3t-value',
      ssl: false,
      poolMax: 10,
      connectionTimeoutMs: 5000,
    });
  });

  it('has no hardcoded secrets or endpoints: required keys fail when absent', () => {
    expect(() => loadConfig({})).toThrow(ConfigError);
    try {
      loadConfig({});
    } catch (err) {
      expect((err as ConfigError).invalidKeys).toEqual([
        'DB_HOST',
        'DB_NAME',
        'DB_PASSWORD',
        'DB_USER',
        'PORT',
      ]);
    }
  });

  it('never includes values (e.g. passwords) in error messages', () => {
    const env = { ...validEnv, PORT: 'not-a-port' };
    expect(() => loadConfig(env)).toThrow(/PORT/);
    try {
      loadConfig(env);
    } catch (err) {
      expect((err as Error).message).not.toContain('s3cr3t-value');
    }
  });

  it('parses DB_SSL strictly', () => {
    expect(loadConfig({ ...validEnv, DB_SSL: 'true' }).db.ssl).toBe(true);
    expect(() => loadConfig({ ...validEnv, DB_SSL: 'yes' })).toThrow(/DB_SSL/);
  });
});
