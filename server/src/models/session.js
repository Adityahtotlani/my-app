const Session = (pg) => ({
  async create({ userId, type, durationSeconds, hrvDelta, moodScore }) {
    const { rows } = await pg.query(
      'INSERT INTO sessions (user_id, type, duration_seconds, hrv_delta, mood_score) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [userId, type, durationSeconds, hrvDelta, moodScore]
    );
    return rows[0];
  },

  async getUserSessions(userId) {
    const { rows } = await pg.query(
      'SELECT * FROM sessions WHERE user_id = $1 ORDER BY completed_at DESC LIMIT 50',
      [userId]
    );
    return rows;
  },

  async updateStreak(userId) {
    // 1. Log the practice day in 'streaks' table
    // 2. Update 'current_streak' and 'max_streak' in 'users' table
    // 3. Increment XP based on session type
    
    const today = new Date().toISOString().split('T')[0];
    
    // Check if already practiced today
    const { rows: existingStreak } = await pg.query(
      'SELECT id FROM streaks WHERE user_id = $1 AND practice_date = $2',
      [userId, today]
    );
    
    if (existingStreak.length > 0) return; // Already logged today

    // Log the day
    await pg.query(
      'INSERT INTO streaks (user_id, practice_date) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [userId, today]
    );

    // Update User Streak & XP
    // Logic: if practiced yesterday, streak++, else streak=1
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0];

    const { rows: yesterdayPractice } = await pg.query(
      'SELECT id FROM streaks WHERE user_id = $1 AND practice_date = $2',
      [userId, yesterdayStr]
    );

    if (yesterdayPractice.length > 0) {
      await pg.query(
        'UPDATE users SET current_streak = current_streak + 1, max_streak = GREATEST(max_streak, current_streak + 1), total_xp = total_xp + 100 WHERE id = $1',
        [userId]
      );
    } else {
      await pg.query(
        'UPDATE users SET current_streak = 1, max_streak = GREATEST(max_streak, 1), total_xp = total_xp + 100 WHERE id = $1',
        [userId]
      );
    }
    
    // Non-linear level calculation
    await pg.query(
      `UPDATE users SET level = CASE
         WHEN total_xp >= 12000 THEN 6
         WHEN total_xp >= 7000 THEN 5
         WHEN total_xp >= 3500 THEN 4
         WHEN total_xp >= 1500 THEN 3
         WHEN total_xp >= 500 THEN 2
         ELSE 1 END
       WHERE id = $1`,
      [userId]
    );

    // Streak milestone XP bonuses
    const { rows: streakRows } = await pg.query(
      'SELECT current_streak FROM users WHERE id = $1',
      [userId]
    );

    if (streakRows.length > 0) {
      const { current_streak } = streakRows[0];

      if (current_streak === 7) {
        await pg.query(
          'UPDATE users SET total_xp = total_xp + 200 WHERE id = $1',
          [userId]
        );
        // Re-run level update after bonus XP
        await pg.query(
          `UPDATE users SET level = CASE
             WHEN total_xp >= 12000 THEN 6
             WHEN total_xp >= 7000 THEN 5
             WHEN total_xp >= 3500 THEN 4
             WHEN total_xp >= 1500 THEN 3
             WHEN total_xp >= 500 THEN 2
             ELSE 1 END
           WHERE id = $1`,
          [userId]
        );
      } else if (current_streak === 30) {
        await pg.query(
          'UPDATE users SET total_xp = total_xp + 500 WHERE id = $1',
          [userId]
        );
        // Re-run level update after bonus XP
        await pg.query(
          `UPDATE users SET level = CASE
             WHEN total_xp >= 12000 THEN 6
             WHEN total_xp >= 7000 THEN 5
             WHEN total_xp >= 3500 THEN 4
             WHEN total_xp >= 1500 THEN 3
             WHEN total_xp >= 500 THEN 2
             ELSE 1 END
           WHERE id = $1`,
          [userId]
        );
      }
    }
  }
});

module.exports = Session;
