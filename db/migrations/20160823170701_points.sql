-- +micrate Up
CREATE TABLE points (
  id SERIAL PRIMARY KEY,
  assigned_to INTEGER NOT NULL,
  assigned_by INTEGER NOT NULL,
  type TEXT NOT NULL,
  created_at TIMESTAMP
);

-- +micrate Down
DROP TABLE messages;
