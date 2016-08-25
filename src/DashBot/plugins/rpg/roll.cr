module DashBot::Plugins::Rpg::Roll
  extend self
  include Rights

  def bind(bot)
    bind_add_roll bot
    bind_del_roll bot
    bind_list_roll bot
    bind_launch_roll bot
  end

  def bind_add_roll(bot)
    bot.on("PRIVMSG", message: /^!rroll ([[:graph:]]+) ([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData

      # Check for roll correctness
      begin
        r = Rollable::Roll.parse(msg_match[2]).compact!.order!
      rescue
        msg.reply "#{msg_match[2]} is not a correct roll."
        next
      end

      # check if name already exists
      n = DB.exec({Int64}, "SELECT COUNT(*) FROM dies WHERE name = $1 AND owner = $2",
        [msg_match[1], msg.source_id]).to_hash[0]["count"]

      if n > 0
        msg.reply "Error: #{msg_match[1]} already exists. Remove it or use another name."
      else
        DB.exec "INSERT INTO dies (owner, name, roll, created_at)
        VALUES ($1, $2, $3, NOW())", [msg.source_id, msg_match[1], msg_match[2]]
        msg.reply "Roll #{msg_match[1]} successfully created for user #{msg.source_id}."
      end
    end
  end

  def bind_launch_roll(bot)
    bot.on("PRIVMSG", message: /^!rroll ([[:graph:]]+) *$/) do |msg, match|
      # Do not trigger if the user was registering a roll
      msg_match = match.as Regex::MatchData
      begin
        roll = DB.exec({String}, "SELECT roll FROM dies WHERE name = $1 AND owner = $2",
          [msg_match[1], msg.source_id]).to_hash[0]["roll"]
      rescue
        msg.reply "Roll #{msg_match[1]} does not exist."
        next
      end

      r = Rollable::Roll.parse(roll).compact!.order!
      result = r.test_details
      msg.reply "#{msg.hl}: #{result.sum} (#{r.to_s} = #{result.join(", ")})"
    end
  end

  def bind_del_roll(bot)
    bot.on("PRIVMSG", message: /^!droll ([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      # Check if roll is in database
      n = DB.exec({Int64}, "SELECT COUNT(*) FROM dies WHERE name = $1 AND owner = $2",
        [msg_match[1], msg.source_id]).to_hash[0]["count"]

      if n == 0
        msg.reply "Error: #{msg_match[1]} doesn't exist."
      else
        DB.exec("DELETE FROM dies WHERE name = $1 AND owner = $2",
          [msg_match[1], msg.source_id])
        msg.reply "Roll #{msg_match[1]} successfully deleted."
      end
    end
  end

  def bind_list_roll(bot)
    bot.on("PRIVMSG", message: /^!lroll ([[:graph:]]+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      res = DB.exec({String}, "SELECT roll FROM dies WHERE name = $1 AND owner = $2",
        [msg_match[1], msg.source_id]).to_hash[0]["roll"]

      if res.nil?
        msg.reply "Roll #{msg_match[1]} does not exist."
      else
        msg.reply "#{msg_match[1]} is registered as #{res}."
      end
    end

    bot.on("PRIVMSG", message: /^!lroll *$/) do |msg|
      # Do not trigger if the user was asking for a specific dice
      rolls = DB.exec({String, String}, "SELECT name, roll FROM dies WHERE owner = $1",
        [msg.source_id]).to_hash.map { |dies| "#{dies["name"]}: #{dies["roll"]}" }.join(", ")
      msg.reply "#{msg.source_id} has registered the following dies: #{rolls}"
    end
  end
end
