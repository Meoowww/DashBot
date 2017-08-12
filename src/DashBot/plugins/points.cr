module DashBot::Plugins::Points
  extend self
  include Rights

  def bind(bot)
    bind_add(bot)
    bind_list(bot)
  end

  def bind_add(bot)
    bot.on("PRIVMSG", message: /^!p ([[:graph:]]+) ([[:graph:]]+)/) do |msg, match|
      match = match.as Regex::MatchData
      DB.exec "INSERT INTO points (assigned_to, assigned_by, type, created_at)
      VALUES ($1, $2, $3, NOW())", [match[2], msg.source_id, match[1].downcase]
      n = DB.query_one("SELECT COUNT(*) FROM points WHERE assigned_to = $1 AND type = $2",
        [match[2], match[1].downcase], as: {Int64})
      msg.reply "#{match[2]} has now #{n} point#{n > 1 ? "s" : ""} #{match[1]}"
    end
  end

  def bind_list(bot)
    bot.on("PRIVMSG", message: /^!pl ([[:graph:]]+)/) do |msg, match|
      match = match.as Regex::MatchData
      points = DB.query_all("SELECT assigned_to, COUNT(*) FROM points WHERE type = $1 GROUP BY assigned_to ORDER BY COUNT(*) DESC LIMIT 5;", [match[1]], as: {String, Int64})
      msg.reply "#{match[1]}: " + points.map { |point| "#{point[0]}: #{point[1]}" }.join(", ")
    end
    bot.on("PRIVMSG", message: /^!plu ([[:graph:]]+)/) do |msg, match|
      match = match.as Regex::MatchData
      points = DB.query_all("SELECT type, COUNT(*) FROM points WHERE assigned_to = $1 GROUP BY type ORDER BY COUNT(*) DESC LIMIT 5;", [match[1]], as: {String, Int64})
      msg.reply "#{match[1]}: " + points.map { |point| "#{point[0]}: #{point[1]}" }.join(", ")
    end
  end
end
