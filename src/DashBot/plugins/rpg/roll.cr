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
      next if msg_match.nil?

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
        next
      end

      # Insert new roll
      DB.exec "INSERT INTO dies (owner, name, roll, created_at)
      VALUES ($1, $2, $3, NOW())", [msg.source_id, msg_match[1], msg_match[2]]

      msg.reply "Roll #{msg_match[1]} successfully created for user #{msg.source_id}."
    end
  end

  def bind_del_roll(bot)
    bot.on("PRIVMSG", message: /^!droll (.+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      next if msg_match.nil?

      # Check if roll is in database
      n = DB.exec({Int64}, "SELECT COUNT(*) FROM dies WHERE name = $1 AND owner = $2",
        [msg_match[1], msg.source_id]).to_hash[0]["count"]

      if n == 0
        msg.reply "Error: #{msg_match[1]} doesn't exist."
        next
      end

      # Delete it
      DB.exec("DELETE FROM dies WHERE name = $1 AND owner = $2",
        [msg_match[1], msg.source_id])

      msg.reply "Roll #{msg_match[1]} successfully deleted."
    end
  end

  def bind_list_roll(bot)
    bot.on("PRIVMSG", message: /^!lroll (.+)/) do |msg, match|
      msg_match = match.as Regex::MatchData
      next if msg_match.nil?

      res = DB.exec({String}, "SELECT roll FROM dies WHERE name = $1 AND owner = $2",
        [msg_match[1], msg.source_id]).to_hash[0]["roll"]

      if res.nil?
        msg.reply "Roll #{msg_match[1]} does not exist."
        next
      end

      msg.reply "#{msg_match[1]} is registered as #{res}."
    end

    bot.on("PRIVMSG", message: /^!lroll/) do |msg|
      # Do not trigger if the user was asking for a specific dice
      msg_match = msg.message.to_s.match(/^!lroll (.+)/)
      next if !msg_match.nil?

      res = DB.exec({String, String}, "SELECT name, roll FROM dies WHERE owner = $1",
        [msg.source_id]).to_hash

      msg.reply "#{msg.source_id} has registered the following dies: " + res.map { |dies| "#{dies["name"]}: #{dies["roll"]}" }.join(", ")
    end
  end

  def bind_launch_roll(bot)
    bot.on("PRIVMSG", message: /^!rroll ([[:graph:]]+)/) do |msg, match|
      # Do not trigger if the user was registering a roll
      msg_match = match.as Regex::MatchData
      next if msg_match.nil?
      match_test = msg.message.to_s.match(/^!rroll ([[:graph:]]+) ([[:graph:]]+)/)
      next if !match_test.nil?

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
end