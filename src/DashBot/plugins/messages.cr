# TODO: Send private message to the sender

module DashBot::Plugins::Messages
  extend self
  include Rights
  include Database

  def bind(bot)
    bind_write bot
    bind_read bot
    bind_signal bot
  end

  def bind_write(bot)
    bot.on("PRIVMSG", message: /^!write (\w+) (.+)$/) do |msg, match|
      id = match.as(Regex::MatchData)[1]
      message = match.as(Regex::MatchData)[2]
      DB.exec "INSERT INTO messages (author, dest, content, created_at)
      VALUES ($1, $2, $3, NOW())", [msg.source_id, id, message]
      # bot.privmsg User.new(msg.source_id), "Message sent to \"#{id}\""
      msg.reply "Message sent to \"#{id}\""
    end
  end

  def bind_read(bot)
    bot.on("PRIVMSG", message: /^!read$/) do |msg, match|
      l = DB.exec("SELECT * FROM messages WHERE read_at IS NULL AND dest = $1 ORDER BY created_at ASC LIMIT 1", [msg.source_id]).to_hash
      # user = User.new(msg.source_id)
      if l.size == 1
        l = l[0]
        date = l["created_at"].as Time
        if Time.now.to_s("%j") == date.to_s("%j")
          date = date.to_s("%H:%M:%S")
        else
          date = date.to_s("%B, %d at %H:%M:%S")
        end
        DB.exec "UPDATE messages SET read_at = NOW() WHERE id = $1", [l["id"].as Int32]
        msg.reply "#{date} -- #{l["author"]} -- #{l["content"]}"
      else
        msg.reply "No message in the mailbox"
      end
    end
  end

  def bind_signal(bot)
    bot.on("JOIN") do |msg, _|
      count = DB.exec({Int64}, "SELECT COUNT(*) FROM messages WHERE read_at IS NULL and DEST = $1", [msg.source_id]).to_hash[0]["count"]
      msg.reply "#{msg.source_id}, you have #{count} messages" if count > 0
    end
  end
  #
end
