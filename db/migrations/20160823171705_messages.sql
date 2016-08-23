-- +micrate Up
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  author TEXT NOT NULL,
  dest TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL,
  read_at TIMESTAMP
);

-- +micrate Down
DROP TABLE messages;
