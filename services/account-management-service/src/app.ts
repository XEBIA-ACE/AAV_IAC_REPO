import express, { type Express } from 'express';
import { healthRouter, type DependencyCheck } from './routes/health';

export interface AppDependencies {
  checkDatabase: DependencyCheck;
}

export function createApp(deps: AppDependencies): Express {
  const app = express();
  app.disable('x-powered-by');
  app.use(express.json());
  app.use(healthRouter(deps.checkDatabase));
  app.use((_req, res) => {
    res.status(404).json({ error: 'Not Found' });
  });
  return app;
}
