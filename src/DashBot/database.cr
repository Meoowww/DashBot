require "dotenv"
require "pg"

# Load env
Dotenv.load

module DashBot::Database
  DB = PG.connect(ENV["PG_URL"])
  extend self

  def user_exists?(name)
    n = DB.query_one("SELECT COUNT(*) AS count FROM users WHERE name=$1", [name], as: {Int64})
    raise "User \"#{name}\" registered #{n} times !!" if n > 1
    n == 1
  end
end
