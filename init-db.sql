-- Initialize database schema for OpenAI.fm sharing feature
CREATE TABLE IF NOT EXISTS shares (
    id UUID PRIMARY KEY,
    input TEXT,
    prompt TEXT,
    voice TEXT
);

