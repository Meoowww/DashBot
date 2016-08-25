-- +micrate Up
CREATE TABLE musics (
  id SERIAL PRIMARY KEY,
  owner TEXT NOT NULL,
  category TEXT NOT NULL,
  url TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL
);

-- +micrate Down
DROP TABLE musics;
