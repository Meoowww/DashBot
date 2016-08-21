module DashBot
  module Rights
    def authorized?(msg, group = "admin")
      DB["users"].count({"id" => msg.source.to_s.source_id, "groups" => {"$elemMatch" => {"$eq" => group} } }) == 1
    end

    def authorized?(msg, groups : Array(String))
      groups.any?{|group| authorized? msg, group}
    end

    def authorize!(msg : Irc::Message, group = "admin", reply = "Unauthorized")
      return true if authorized? msg, group
      msg.reply reply
      false
    end
  end

  extend self
end
