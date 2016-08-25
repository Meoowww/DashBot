-- +micrate Up
CREATE TABLE dies (
  id SERIAL PRIMARY KEY,
  owner TEXT NOT NULL,
  name TEXT NOT NULL,
  roll TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL
);

-- +micrate Down
DROP TABLE dies;
