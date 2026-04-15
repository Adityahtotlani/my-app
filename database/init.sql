-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    course_code VARCHAR(50),
    is_verified BOOLEAN DEFAULT FALSE,
    current_streak INT DEFAULT 0,
    max_streak INT DEFAULT 0,
    total_xp INT DEFAULT 0,
    level INT DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL, -- 'full' or 'short'
    duration_seconds INT NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    hrv_delta INT,
    mood_score INT -- 1-5 scale
);

-- Streaks table (log of practice days)
CREATE TABLE IF NOT EXISTS streaks (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    practice_date DATE NOT NULL,
    is_grace_day BOOLEAN DEFAULT FALSE,
    UNIQUE(user_id, practice_date)
);

-- Indices
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_streaks_user_id ON streaks(user_id);
