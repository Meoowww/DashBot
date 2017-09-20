module DashBot::Plugins::BasicCommands
  extend self

  WHAT = %w(ce que tu dis n'a aucun sens)

  def bind(bot)
    bot.on("JOIN") do |msg|
      if msg.hl == bot.nick.to_s
        msg.reply "Welcome everypony, what's up ? :)"
      else
        STDERR.puts "[#{Time.now}] #{msg.hl} joined the chan"
      end
    end.on("PING") do |msg|
      STDERR.puts "[#{Time.now}] PONG :#{msg.message}"
      bot.pong(msg.message)
    end.on("PRIVMSG", message: /^!ping/) do |msg|
      msg.reply "pong #{msg.hl}"
    end.on("PRIVMSG", message: /^!roll *([^:]+)( *: *(.+))?/) do |msg, match|
      match = match.as Regex::MatchData
      r = Rollable::Roll.parse(match[1]).compact!.order!
      result = r.test_details
      msg.reply "#{msg.hl}: [#{match[3]?}] #{result.sum} (#{r.to_s} = #{result.join(", ")})"
    end.on("PRIVMSG", message: /^!call *(.+)/) do |msg, match|
      match = match.as Regex::MatchData
      msg.reply "I'm calling #{match[1]} right now"
    end.on("PRIVMSG", message: /(^| )what($| )/i) do |msg, match|
      msg.reply WHAT.shuffle.join(" ")
    end
  end
end
