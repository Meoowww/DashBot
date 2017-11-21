module DashBot::Plugins::BasicCommands
  extend self

  WHAT = %w(ce que tu dis n'a aucun sens)

  def bind(bot)
    bot.on("JOIN") do |msg|
      if msg.source == bot.nick.to_s
        bot.reply msg, "Welcome everypony, what's up ? :)"
      else
        STDERR.puts "[#{Time.now}] #{msg.source.source_id} joined the chan"
      end
    end.on("PING") do |msg|
      STDERR.puts "[#{Time.now}] PONG :#{msg.message}"
      bot.pong(msg.message)
    end.on("PRIVMSG", message: /^!ping/) do |msg|
      bot.reply msg, "pong #{msg.source.source_id}"
    end.on("PRIVMSG", message: /^!roll +([^:]+)( *: *(.+))?/) do |msg, match|
      match = match.as Regex::MatchData
      r = Rollable::Roll.parse(match[1]).compact!.order!
      result = r.test_details
      bot.reply msg, "#{msg.source.source_id}: [#{match[3]?}] #{result.sum} (#{r.to_s} = #{result.join(", ")})"
    end.on("PRIVMSG", message: /^!call +(.+)/) do |msg, match|
      match = match.as Regex::MatchData
      bot.reply msg, "I'm calling #{match[1]} right now"
    end.on("PRIVMSG", message: /(^| )what($| )/i) do |msg, match|
      bot.reply msg, WHAT.shuffle.join(" ")
    end.on("PRIVMSG", message: /(^|\W)AH($|\W)/) do |msg, match|
      bot.reply msg, "AH"
    end.on("PRIVMSG", message: /^oulah?$/i) do |msg, match|
      bot.reply msg, "Vous êtes con"
    end
  end
end
