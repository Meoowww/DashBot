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
    bot.on("PRIVMSG", message: /^!music +add +([[:graph:]]+) +([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      DB.exec("INSERT INTO musics (owner, category, url, created_at)
      VALUES ($1, $2, $3, NOW())", [msg.source.source_id, msg_match[1], msg_match[2]])
      bot.reply msg, "Music successfully added."
    end
  end

  def bind_del_music(bot)
    bot.on("PRIVMSG", message: /^!music +delete +([[:graph:]]+) +([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      musics = DB.query_all("SELECT url FROM musics WHERE category = $1", [msg_match[1]], as: {String})

      if msg_match[2].to_i > musics.size
        bot.reply msg, "This music doesn't exist."
      else
        DB.exec("DELETE FROM musics WHERE url = $1", [musics[msg_match[2].to_i - 1]["url"]])
        bot.reply msg, "Music successfully deleted."
      end
    end
  end

  def bind_list_music(bot)
    bot.on("PRIVMSG", message: /^!music +(?:list|ls) +$/) do |msg|
      # Do not trigger if the user was asking for a specific category
      categories = DB.query_all("SELECT DISTINCT category FROM musics", as: {String}).join(", ")
      bot.reply msg, "The following music categories exist: #{categories}"
    end

    bot.on("PRIVMSG", message: /^!music +(?:list|ls) +([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      urls = DB.query_all("SELECT url FROM musics WHERE category = $1 LIMIT 5", [msg_match[1]], as: {String}).join(", ")
      bot.reply msg, "The following musics are present in the category #{msg_match[1]}: #{urls}"
    end
  end

  def bind_link_music(bot)
    # Select a random music
    bot.on("PRIVMSG", message: /^!music play +([[:graph:]]+) +$/) do |msg, match|
      msg_match = match.as Regex::MatchData
      musics = DB.query_all("SELECT url FROM musics WHERE category = $1", [msg_match[1]], as: {String})
      bot.reply msg, "#{musics.sample}"
    end

    # Select a specific music
    bot.on("PRIVMSG", message: /^!music play +([[:graph:]]+) +([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      musics = DB.query_all("SELECT url FROM musics WHERE category = $1", [msg_match[1]], as: {String})
      if msg_match[2].to_i > musics.size
        bot.reply msg, "Error: this track doesn't exist (yet)."
      else
        bot.reply msg, "#{musics[msg_match[2].to_i - 1]}"
      end
    end
  end
end
