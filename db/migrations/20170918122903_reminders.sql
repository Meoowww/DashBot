-- +micrate Up
CREATE TABLE reminders (
  id SERIAL PRIMARY KEY,
  author TEXT NOT NULL,
  remind_time TIMESTAMP NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL,
  checked_at TIMESTAMP,
  read_at TIMESTAMP
);

-- +micrate Down
DROP TABLE reminders;
