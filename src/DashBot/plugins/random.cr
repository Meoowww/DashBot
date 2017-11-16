module DashBot::Plugins::Random
  extend self

  def bind(bot)
    bot.on("PRIVMSG", message: /^!random +([[:alnum:]]+(, ?[[:alnum:]]+))+/) do |msg, match|
      match = match.as(Regex::MatchData)
      list = match[1]
      values = list.split(/(, )|([^,] )/)
      bot.reply msg, "Values: #{values}"
      bot.reply msg, values.sample
    end
  end
end
