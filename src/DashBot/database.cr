require "./mongo"

module DashBot
  CLIENT = Mongo::Client.new "mongodb://localhost"
  DB = CLIENT["dash_bot"]
end
