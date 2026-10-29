import pino, { type Logger } from 'pino';

// Redact credential-like fields so secrets are never written to logs (SCAFFOLD-SVC-001 security obligation).
export const REDACT_PATHS = [
  'password',
  '*.password',
  'db.password',
  'config.db.password',
  'req.headers.authorization',
  'req.headers.cookie',
];

export function createLogger(level: string = process.env.LOG_LEVEL ?? 'info'): Logger {
  return pino({
    name: 'account-management-service',
    level,
    redact: { paths: REDACT_PATHS, censor: '[REDACTED]' },
  });
}
