module DashBot::Plugins::Random
  extend self

  def bind(bot)
    bot.on("PRIVMSG", message: /^!random +([[:alnum:]]+(, ?[[:alnum:]]+))+/) do |msg, match|
      match = match.as(Regex::MatchData)
      list = match[1]
      values = list.split(/(, )|([^,] )/)
      msg.reply "Values: #{values}"
      msg.reply values.sample
    end
  end
end
