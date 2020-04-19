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
    bot.on("PRIVMSG", message: /^!write +(\w+) +(.+)$/, doc: {"!write", "!write someone message"}) do |msg, match|
      id = match.as(Regex::MatchData)[1]
      message = match.as(Regex::MatchData)[2]
      DB.exec "INSERT INTO messages (author, dest, content, created_at)
      VALUES ($1, $2, $3, NOW())", [msg.source.source_id, id, message]
      # bot.privmsg User.new(msg.source.source_id), "Message sent to \"#{id}\""
      bot.reply msg, "Message sent to \"#{id}\""
    end
  end

  def bind_read(bot)
    bot.on("PRIVMSG", message: /^!read$/, doc: {"!read", "!read    read the inbox"}) do |msg, match|
      m = DB.query_one(
        "SELECT id, author, dest, content, created_at, read_at FROM messages WHERE read_at IS NULL AND dest = $1
         ORDER BY created_at ASC LIMIT 1", [msg.source.source_id], as: {Int32, String, String, String, Time, Time?}) rescue nil
      if m
        message = {id: m[0], author: m[1], dest: m[2], content: m[3], created_at: m[4], read_at: m[5]}
        # user = User.new(msg.source.source_id)
        date = message[:created_at]
        if Time.utc.to_s("%j") == date.to_s("%j")
          date = date.to_s("%H:%M:%S")
        else
          date = date.to_s("%B, %d at %H:%M:%S")
        end
        bot.reply msg, "#{date} -- #{message[:author]} -- #{message[:content]}"
        DB.exec "UPDATE messages SET read_at = NOW() WHERE id = $1", [message[:id]]
      else
        bot.reply msg, "No message in the mailbox"
      end
    end
  end

  def bind_signal(bot)
    bot.on("JOIN") do |msg, _|
      count = DB.query_one("SELECT COUNT(*) FROM messages WHERE read_at IS NULL and DEST = $1", [msg.source.source_id], as: {Int64})
      bot.reply msg, "#{msg.source.source_id}, you have #{count} messages" if count > 0
    end
  end
end
