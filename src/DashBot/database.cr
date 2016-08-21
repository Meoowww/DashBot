require "./mongo"

module DashBot
  CLIENT = Mongo::Client.new(ENV["MONGODB_URL"]? || "mongodb://localhost")
  DB = CLIENT["dash_bot"]

  module Database
    extend self
    def user_exists?(id)
      n = DB["users"].count({"id" => id})
      raise "User \"#{id}\" registered #{n} times !!" if n > 1
      n == 1
    end
  end
end
