-- +micrate Up
CREATE TABLE groups (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  user_name TEXT NOT NULL
);

-- +micrate Down
DROP TABLE groups;
