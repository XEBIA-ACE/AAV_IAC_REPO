// SCAFFOLD-SVC-001 / T003 + AC-1: health-check endpoints.
import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { createApp } from '../src/app';

describe('T003 health endpoints', () => {
  it('GET /health returns 200 with static, non-sensitive status', async () => {
    const app = createApp({ checkDatabase: async () => false });
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok', service: 'account-management-service' });
    expect(res.headers['x-powered-by']).toBeUndefined();
  });

  it('GET /health/ready returns 200 when the database is reachable', async () => {
    const app = createApp({ checkDatabase: async () => true });
    const res = await request(app).get('/health/ready');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok', checks: { database: 'up' } });
  });

  it('GET /health/ready returns 503 when the database is unreachable', async () => {
    const app = createApp({ checkDatabase: async () => false });
    const res = await request(app).get('/health/ready');
    expect(res.status).toBe(503);
    expect(res.body).toEqual({ status: 'unavailable', checks: { database: 'down' } });
  });

  it('unknown routes return JSON 404', async () => {
    const app = createApp({ checkDatabase: async () => true });
    const res = await request(app).get('/nope');
    expect(res.status).toBe(404);
    expect(res.body).toEqual({ error: 'Not Found' });
  });
});
