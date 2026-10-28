// SCAFFOLD-SVC-001 / T003: health-check endpoints. Responses contain no configuration or sensitive data.
import { Router } from 'express';

export type DependencyCheck = () => Promise<boolean>;

export function healthRouter(checkDatabase: DependencyCheck): Router {
  const router = Router();

  // Liveness: the process is up and serving HTTP.
  router.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok', service: 'account-management-service' });
  });

  // Readiness: the process can reach its PostgreSQL datastore.
  router.get('/health/ready', async (_req, res) => {
    const databaseUp = await checkDatabase();
    res.status(databaseUp ? 200 : 503).json({
      status: databaseUp ? 'ok' : 'unavailable',
      checks: { database: databaseUp ? 'up' : 'down' },
    });
  });

  return router;
}
