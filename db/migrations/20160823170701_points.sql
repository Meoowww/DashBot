-- +micrate Up
CREATE TABLE points (
  id SERIAL PRIMARY KEY,
  assigned_to TEXT NOT NULL,
  assigned_by TEXT NOT NULL,
  type TEXT NOT NULL,
  created_at TIMESTAMP
);

-- +micrate Down
DROP TABLE messages;
