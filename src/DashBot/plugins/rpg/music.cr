module DashBot::Plugins::Rpg::Music
  extend self
  include Rights

  def bind(bot)
    bind_add_music bot
    bind_del_music bot
    bind_list_music bot
    bind_link_music bot
  end

  def bind_add_music(bot)
    bot.on("PRIVMSG", message: /^!music add ([[:graph:]]+) ([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      next if msg_match.nil?

      DB.exec("INSERT INTO musics (owner, category, url, created_at)
      VALUES ($1, $2, $3, NOW())", [msg.source_id, msg_match[1], msg_match[2]])

      msg.reply "Music successfully added."
    end
  end

  def bind_del_music(bot)
    bot.on("PRIVMSG", message: /^!music delete (.+) (.+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      next if msg_match.nil?

      musics = DB.exec({String}, "SELECT url FROM musics WHERE category = $1",
        [msg_match[1]]).to_hash

      if msg_match[2].to_i > musics.size
        msg.reply "This music doesn't exist."
        next
      end

      DB.exec("DELETE FROM musics WHERE url = $1",
        [musics[msg_match[2].to_i - 1]["url"]])
      msg.reply "Music successfully deleted."
    end
  end

  def bind_list_music(bot)
    bot.on("PRIVMSG", message: /^!music list/) do |msg|
      # Do not trigger if the user was asking for a specific category
      msg_match = msg.message.to_s.match(/^!music list (.+)/)
      next if !msg_match.nil?

      res = DB.exec({String}, "SELECT DISTINCT category FROM musics").to_hash
      msg.reply "The following music categories exist: " + res.map { |music| "#{music["category"]}" }.join(", ")
    end

    bot.on("PRIVMSG", message: /^!music list (.+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      next if msg_match.nil?

      res = DB.exec({String}, "SELECT url FROM musics WHERE category = $1 LIMIT 5",
        [msg_match[1]]).to_hash
      msg.reply "The following musics are present in the category #{msg_match[1]}: " + res.map { |music| "#{music["url"]}" }.join(", ")
    end
  end

  def bind_link_music(bot)
    bot.on("PRIVMSG", message: /^!music play (.+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      next if msg_match.nil?
      match_test = msg.message.to_s.match(/^!music play ([[:graph:]]+) ([[:graph:]]+)/)
      next if !match_test.nil?

      # Select a random music
      musics = DB.exec({String}, "SELECT url FROM musics WHERE category = $1",
        [msg_match[1]]).to_hash

      msg.reply "#{musics.sample["url"]}"
    end

    bot.on("PRIVMSG", message: /^!music play ([[:graph:]]+) ([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      next if msg_match.nil?

      # Select a specific music
      musics = DB.exec({String}, "SELECT url FROM musics WHERE category = $1",
        [msg_match[1]]).to_hash

      if msg_match[2].to_i > musics.size
        msg.reply "Error: this track doesn't exist (yet)."
        next
      end

      msg.reply "#{musics[msg_match[2].to_i - 1]["url"]}"
    end
  end
end
