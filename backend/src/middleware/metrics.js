const { httpRequestDuration, httpRequestTotal, activeConnections } = require('../config/metrics');

// Middleware to track HTTP metrics
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  // Increment active connections
  activeConnections.inc();

  // On response finish, record metrics
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    // Record request duration
    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);

    // Increment request counter
    httpRequestTotal
      .labels(req.method, route, res.statusCode)
      .inc();

    // Decrement active connections
    activeConnections.dec();
  });

  next();
};

module.exports = { metricsMiddleware };
