-- Run this against an existing database to apply schema additions
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS note VARCHAR(500);
