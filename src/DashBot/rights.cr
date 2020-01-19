module DashBot::Rights
  def authorized?(msg, group = "admin")
    n = DB.query_one("SELECT COUNT(*) FROM groups
    INNER JOIN users ON groups.user_name = users.name WHERE groups.name = $1 AND users.name = $2",
      [group, msg.source.source_id], as: {Int64})
    n == 1
  end

  def authorized?(msg, groups : Array(String))
    groups.any? { |group| authorized? msg, group }
  end

  def authorize!(bot, msg : Crirc::Protocol::Message, group = "admin", reply = "Unauthorized")
    return true if authorized? msg, group
    bot.reply msg, reply
    false
  end

  extend self
end
