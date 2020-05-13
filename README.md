# DashBot

TODO: Write a description here

## Installation

Install ``postgresql``, ``crystal``, and ``crystal-shards``

```sh
# Clone
git clone https://github.com/Meoowww/DashBot
cd DashBot
# Install the libs
shards install
# Build the project
crystal b -s --release src/DashBot.cr
# Configure the database
psql -U postgres postgres -c "CREATE USER root WITH PASSWORD 'toor' SUPERUSER;"
psql -U postgres postgres -c "CREATE DATABASE dash_bot"
echo "PG_URL=postgres://root:toor@localhost/dash_bot" > .env
# Update the database
./bin/micrate up
# Run the bot
./DashBot
```

## Usage



TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/Meoowww/DashBot/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [pouleta](https://github.com/Nephos) Arthur Poulet - creator, maintainer
- [Lucie](https://github.com/Lucie-Dispot) Lucie Dispot - developer
