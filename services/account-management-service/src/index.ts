// SCAFFOLD-SVC-001 / T001: service entrypoint. All configuration comes from environment variables (T002).
import { createApp } from './app';
import { ConfigError, loadConfig } from './config';
import { checkDatabase, createPool } from './db';
import { createLogger } from './logger';

function main(): void {
  const bootstrapLogger = createLogger();
  let config;
  try {
    config = loadConfig();
  } catch (err) {
    if (err instanceof ConfigError) {
      bootstrapLogger.fatal({ invalidKeys: err.invalidKeys }, 'invalid configuration');
      process.exit(1);
    }
    throw err;
  }

  const logger = createLogger(config.logLevel);
  const pool = createPool(config.db, logger);
  const app = createApp({ checkDatabase: () => checkDatabase(pool) });

  const server = app.listen(config.port, () => {
    logger.info(
      { port: config.port, nodeEnv: config.nodeEnv },
      'account-management-service started',
    );
  });

  const shutdown = (signal: string): void => {
    logger.info({ signal }, 'shutting down');
    server.close(() => {
      pool.end().finally(() => process.exit(0));
    });
  };
  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

main();
