module DashBot::Plugins::BasicCommands
  extend self

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
    end.on("PRIVMSG", message: /^!roll .+/) do |msg|
      msg_match = msg.message.to_s.match(/^!roll (.+)/)
      next if msg_match.nil?
      r = Rollable::Roll.parse(msg_match[1]).compact!.order!
      result = r.test_details
      msg.reply "#{msg.hl}: #{result.sum} (#{r.to_s} = #{result.join(", ")})"
    end
  end
end
