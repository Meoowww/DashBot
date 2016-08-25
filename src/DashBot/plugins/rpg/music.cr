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
      DB.exec("INSERT INTO musics (owner, category, url, created_at)
      VALUES ($1, $2, $3, NOW())", [msg.source_id, msg_match[1], msg_match[2]])
      msg.reply "Music successfully added."
    end
  end

  def bind_del_music(bot)
    bot.on("PRIVMSG", message: /^!music delete ([[:graph:]]+) ([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      musics = DB.exec({String}, "SELECT url FROM musics WHERE category = $1",
        [msg_match[1]]).to_hash

      if msg_match[2].to_i > musics.size
        msg.reply "This music doesn't exist."
      else
        DB.exec("DELETE FROM musics WHERE url = $1", [musics[msg_match[2].to_i - 1]["url"]])
        msg.reply "Music successfully deleted."
      end
    end
  end

  def bind_list_music(bot)
    bot.on("PRIVMSG", message: /^!music (?:list|ls) *$/) do |msg|
      # Do not trigger if the user was asking for a specific category
      categories = DB.exec({String}, "SELECT DISTINCT category FROM musics")
                     .to_hash.map { |music| "#{music["category"]}" }.join(", ")
      msg.reply "The following music categories exist: #{categories}"
    end

    bot.on("PRIVMSG", message: /^!music (?:list|ls) ([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      urls = DB.exec({String}, "SELECT url FROM musics WHERE category = $1 LIMIT 5",
        [msg_match[1]]).to_hash.map { |music| "#{music["url"]}" }.join(", ")
      msg.reply "The following musics are present in the category #{msg_match[1]}: #{urls}"
    end
  end

  def bind_link_music(bot)
    # Select a random music
    bot.on("PRIVMSG", message: /^!music play ([[:graph:]]+) *$/) do |msg, match|
      msg_match = match.as Regex::MatchData
      musics = DB.exec({String}, "SELECT url FROM musics WHERE category = $1", [msg_match[1]]).to_hash
      msg.reply "#{musics.sample["url"]}"
    end

    # Select a specific music
    bot.on("PRIVMSG", message: /^!music play ([[:graph:]]+) ([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      musics = DB.exec({String}, "SELECT url FROM musics WHERE category = $1", [msg_match[1]]).to_hash
      if msg_match[2].to_i > musics.size
        msg.reply "Error: this track doesn't exist (yet)."
      else
        msg.reply "#{musics[msg_match[2].to_i - 1]["url"]}"
      end
    end
  end
end
