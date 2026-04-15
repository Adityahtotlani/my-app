const bcrypt = require('bcrypt');

const User = (pg) => ({
  async findByEmail(email) {
    const { rows } = await pg.query('SELECT * FROM users WHERE email = $1', [email]);
    return rows[0];
  },

  async create({ email, password, courseCode }) {
    const passwordHash = await bcrypt.hash(password, 10);
    const { rows } = await pg.query(
      'INSERT INTO users (email, password_hash, course_code) VALUES ($1, $2, $3) RETURNING id, email, course_code, is_verified',
      [email, passwordHash, courseCode]
    );
    return rows[0];
  },

  async verifyCourse(userId, code) {
    // For MVP: verify if code is "SKY-2026"
    const isValid = code === 'SKY-2026';
    if (isValid) {
      await pg.query('UPDATE users SET is_verified = TRUE, course_code = $1 WHERE id = $2', [code, userId]);
    }
    return isValid;
  }
});

module.exports = User;
