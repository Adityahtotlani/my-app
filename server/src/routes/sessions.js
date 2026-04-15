const Session = require('../models/session');

async function sessionRoutes(fastify, options) {
  const sessionModel = Session(fastify.pg);

  // Log a session
  fastify.post('/log', {
    onRequest: [fastify.authenticate]
  }, async (request, reply) => {
    const { type, durationSeconds, hrvDelta, moodScore } = request.body;
    const userId = request.user.id;
    
    const session = await sessionModel.create({
      userId,
      type,
      durationSeconds,
      hrvDelta,
      moodScore
    });

    // Update streak and XP asynchronously
    await sessionModel.updateStreak(userId);
    
    return { success: true, session };
  });

  // Get user sessions
  fastify.get('/history', {
    onRequest: [fastify.authenticate]
  }, async (request, reply) => {
    const userId = request.user.id;
    const history = await sessionModel.getUserSessions(userId);
    return history;
  });

  // Get streak calendar (last 70 days of practiced dates)
  fastify.get('/streak-calendar', {
    onRequest: [fastify.authenticate]
  }, async (request, reply) => {
    const userId = request.user.id;
    const result = await fastify.pg.query(
      `SELECT practice_date FROM streaks
       WHERE user_id = $1
         AND practice_date >= CURRENT_DATE - INTERVAL '70 days'
       ORDER BY practice_date DESC`,
      [userId]
    );
    const dates = result.rows.map((row) => {
      const d = new Date(row.practice_date);
      return d.toISOString().slice(0, 10);
    });
    return { dates };
  });

  // Get mood trend (last 14 sessions with a mood score)
  fastify.get('/mood-trend', {
    onRequest: [fastify.authenticate]
  }, async (request, reply) => {
    const userId = request.user.id;
    const result = await fastify.pg.query(
      `SELECT mood_score, completed_at FROM sessions
       WHERE user_id = $1 AND mood_score IS NOT NULL
       ORDER BY completed_at DESC
       LIMIT 14`,
      [userId]
    );
    const rows = result.rows.reverse();
    return rows.map((row, index) => ({ day: index + 1, mood: row.mood_score }));
  });
}

module.exports = sessionRoutes;
