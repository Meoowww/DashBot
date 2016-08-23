module DashBot
  module Rights
    def authorized?(msg, group = "admin")
      n = DB.exec({Int64}, "SELECT COUNT(*) FROM groups
      INNER JOIN users ON groups.user_name = users.name WHERE groups.name = $1 AND users.name = $2",
      [group, msg.source_id]).to_hash[0]["count"]
      n == 1
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
