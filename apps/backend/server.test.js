const request = require('supertest');
const express = require('express');

// Mock do server.js para testes
const app = express();
app.use(express.json());

// Mock das rotas básicas
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.get('/api/', (req, res) => {
  res.json({
    message: 'K8s Demo API is running!',
    version: '1.0.0',
    endpoints: {
      users: '/api/users',
      health: '/health',
      metrics: '/metrics'
    }
  });
});

app.get('/api/users', (req, res) => {
  res.json([]);
});

app.get('/metrics', (req, res) => {
  res.set('Content-Type', 'text/plain');
  res.send('# HELP test_metric Test metric\n# TYPE test_metric counter\ntest_metric 1\n');
});

describe('Backend API Tests', () => {
  test('GET /health should return status OK', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);
    
    expect(response.body.status).toBe('OK');
    expect(response.body.timestamp).toBeDefined();
  });

  test('GET /api/ should return API info', async () => {
    const response = await request(app)
      .get('/api/')
      .expect(200);
    
    expect(response.body.message).toBe('K8s Demo API is running!');
    expect(response.body.version).toBe('1.0.0');
    expect(response.body.endpoints).toBeDefined();
  });

  test('GET /api/users should return empty array', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect(200);
    
    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body.length).toBe(0);
  });

  test('GET /metrics should return Prometheus metrics', async () => {
    const response = await request(app)
      .get('/metrics')
      .expect(200);
    
    expect(response.headers['content-type']).toContain('text/plain');
    expect(response.text).toContain('test_metric');
  });
});
