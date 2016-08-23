require "dotenv"
require "pg"

# Load env
Dotenv.load

module DashBot
  DB = PG.connect(ENV["PG_URL"])

  module Database
    extend self
    def user_exists?(name)
      n = DB.exec({Int64}, "SELECT COUNT(*) AS count FROM users WHERE name=$1", [name]).to_hash[0]["count"]
      raise "User \"#{name}\" registered #{n} times !!" if n > 1
      n == 1
    end
  end
end
