const bcrypt = require('bcrypt');
const User = require('../models/user');

async function authRoutes(fastify, options) {
  const userModel = User(fastify.pg);

  // Register
  fastify.post('/register', async (request, reply) => {
    const { email, password, courseCode } = request.body;
    
    const existingUser = await userModel.findByEmail(email);
    if (existingUser) {
      return reply.code(400).send({ error: 'User already exists' });
    }

    const user = await userModel.create({ email, password, courseCode });
    const token = fastify.jwt.sign({ id: user.id, email: user.email });
    
    return { user, token };
  });

  // Login
  fastify.post('/login', async (request, reply) => {
    const { email, password } = request.body;
    
    const user = await userModel.findByEmail(email);
    if (!user) {
      return reply.code(401).send({ error: 'Invalid credentials' });
    }

    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return reply.code(401).send({ error: 'Invalid credentials' });
    }

    const token = fastify.jwt.sign({ id: user.id, email: user.email });
    
    return {
      user: {
        id: user.id,
        email: user.email,
        is_verified: user.is_verified,
        current_streak: user.current_streak,
        total_xp: user.total_xp,
        level: user.level
      },
      token
    };
  });

  // Get current user
  fastify.get('/me', {
    onRequest: [fastify.authenticate]
  }, async (request, reply) => {
    const userId = request.user.id;
    const { rows } = await fastify.pg.query(
      'SELECT id, email, is_verified, current_streak, max_streak, total_xp, level FROM users WHERE id = $1',
      [userId]
    );
    if (!rows[0]) {
      return reply.code(404).send({ error: 'User not found' });
    }
    return rows[0];
  });

  // Verify Course Code
  fastify.post('/verify-course', {
    onRequest: [fastify.authenticate]
  }, async (request, reply) => {
    const { code } = request.body;
    const userId = request.user.id;
    
    const isValid = await userModel.verifyCourse(userId, code);
    if (!isValid) {
      return reply.code(400).send({ error: 'Invalid course code' });
    }
    
    return { success: true };
  });
}

module.exports = authRoutes;
