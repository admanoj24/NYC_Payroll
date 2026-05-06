CREATE TABLE IF NOT EXISTS batch_runs (
    batch_id SERIAL PRIMARY KEY,
    status TEXT NOT NULL CHECK (
        status IN ('pending', 'running', 'success', 'failed')
    ),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    error_message TEXT
);