require('dotenv').config();
const fastify = require('fastify')({ logger: true });

// Register Plugins
fastify.register(require('@fastify/postgres'), {
  connectionString: process.env.DATABASE_URL
});

fastify.register(require('@fastify/redis'), {
  url: process.env.REDIS_URL
});

fastify.register(require('@fastify/jwt'), {
  secret: process.env.JWT_SECRET
});

fastify.decorate("authenticate", async function(request, reply) {
  try {
    await request.jwtVerify();
  } catch (err) {
    reply.send(err);
  }
});

// Register Routes
fastify.register(require('./routes/auth'), { prefix: '/api/auth' });
fastify.register(require('./routes/sessions'), { prefix: '/api/sessions' });
fastify.get('/health', async (request, reply) => {
  return { status: 'ok', timestamp: new Date().toISOString() };
});

// Run the server
const start = async () => {
  try {
    const port = process.env.PORT || 3000;
    await fastify.listen({ port, host: '0.0.0.0' });
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
