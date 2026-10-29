// SCAFFOLD-SVC-001 / T004: reusable PostgreSQL connection helper (pooled), configured via env-derived config.
import { Pool, type PoolConfig } from 'pg';
import type { Logger } from 'pino';
import type { DatabaseConfig } from '../config';

export function toPoolConfig(db: DatabaseConfig): PoolConfig {
  return {
    host: db.host,
    port: db.port,
    database: db.database,
    user: db.user,
    password: db.password,
    ssl: db.ssl ? { rejectUnauthorized: true } : false,
    max: db.poolMax,
    connectionTimeoutMillis: db.connectionTimeoutMs,
  };
}

export function createPool(db: DatabaseConfig, logger?: Logger): Pool {
  const pool = new Pool(toPoolConfig(db));
  pool.on('error', (err) => {
    // Log only the error message/code; never the connection config.
    logger?.error(
      { code: (err as { code?: string }).code, msg: err.message },
      'idle database client error',
    );
  });
  return pool;
}

export async function checkDatabase(pool: Pool): Promise<boolean> {
  try {
    await pool.query('SELECT 1');
    return true;
  } catch {
    return false;
  }
}
