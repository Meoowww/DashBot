-- +micrate Up
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  CONSTRAINT name_uniq UNIQUE (name)
);

-- +micrate Down
DROP TABLE users;
