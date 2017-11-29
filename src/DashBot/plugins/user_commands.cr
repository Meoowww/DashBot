module DashBot::Plugins::UserCommands
  extend self
  include Rights
  include Database

  def bind(bot)
    bind_register bot
    bind_group bot
  end

  def bind_group(bot)
    bind_group_add bot
    bind_group_ls bot
    bind_group_rm bot
  end

  def bind_group_rm(bot)
    bot.on("PRIVMSG", message: /^!group +rm +(\w+) +(\w+)/, doc: {"!group rm", "!group rm user group"}) do |msg, match|
      next if !authorize! bot, msg
      match = match.as Regex::MatchData
      if user_exists? match[1]
        groups = DB.query_all("SELECT groups.id AS id, groups.name AS name FROM groups
        INNER JOIN users ON groups.user_name = users.name WHERE users.name = $1", [match[1]], as: {Int32, String})
        if idx = groups.index { |e| e[1] == match[2] }
          DB.exec "DELETE FROM groups WHERE id = $1", [groups[idx][0]]
          bot.reply msg, "The user \"#{match[1]}\" has lost the group \"#{match[2]}\""
        else
          bot.reply msg, "The user \"#{match[1]}\" does not belongs to the group \"#{match[2]}\""
        end
      else
        bot.reply msg, "User \"#{match[1]}\" not registered"
      end
    end
  end

  def bind_group_ls(bot)
    bot.on("PRIVMSG", message: /^!group +(?:list|ls) (\w+)/, doc: {"!group ls", "!group ls user"}) do |msg, match|
      match = match.as Regex::MatchData
      if user_exists? match[1]
        groups = DB.query_all("SELECT groups.name AS name FROM groups
        INNER JOIN users ON groups.user_name = users.name WHERE users.name = $1", [match[1]], as: {String})
        groups = groups.join(", ")
        bot.reply msg, "User \"#{match[1]}\" has the groups : #{groups}"
      else
        bot.reply msg, "User \"#{match[1]}\" is not registered"
      end
    end
  end

  def bind_group_add(bot)
    bot.on("PRIVMSG", message: /^!group +add +(\w+) +(\w+)/, doc: {"!group add", "!group add user group"}) do |msg, match|
      next if !authorize! bot, msg
      match = match.as Regex::MatchData
      if user_exists? match[1]
        DB.exec "INSERT INTO groups (user_name, name) VALUES ($1, $2)", [match[1], match[2]]
        bot.reply msg, "The user \"#{match[1]}\" has gained the group \"#{match[2]}\""
      else
        bot.reply msg, "User \"#{match[1]}\" not registered"
      end
    end
  end

  def bind_register(bot)
    bot.on("PRIVMSG", message: /^!register/, doc: {"!register", "!register"}) do |msg|
      if user_exists? msg.source.source_id
        bot.reply msg, "Cannot register \"#{msg.source.source_id}\" twice"
      else
        bot.reply msg, "Register \"#{msg.source.source_id}\""
        is_admin = DB.query_one("SELECT COUNT(*) FROM users", [] of Int64, as: {Int64}) == 0
        DB.exec "INSERT INTO users (name) VALUES ($1)", [msg.source.source_id]
        DB.exec "INSERT INTO groups (user_name, name) VALUES ($1, $2)", [msg.source.source_id, is_admin ? "admin" : "default"]
      end
    end
  end
end
