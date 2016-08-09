require "./mongo"

module DashBot
  CLIENT = Mongo::Client.new(ENV["MONGODB_URL"]? || "mongodb://localhost")
  DB = CLIENT["dash_bot"]
end
