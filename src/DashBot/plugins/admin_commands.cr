module DashBot::Plugins::AdminCommands
  extend self
  include Rights

  def bind(bot)
    bot.on("PRIVMSG", message: /^!kick (\w+)(?: (.+))?/) do |msg, match|
      next if !authorize! msg, %w(admin modo), "You cannot kick, you are not an \"admin\" nor a \"modo\""
      chan = CrystalIrc::Chan.new msg.arguments.first
      user = CrystalIrc::User.new match.as(Regex::MatchData)[1]
      bot.kick([chan], [user], match.as(Regex::MatchData)[2]?)
    end
  end
end
