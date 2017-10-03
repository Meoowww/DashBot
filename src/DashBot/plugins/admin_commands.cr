module DashBot::Plugins::AdminCommands
  extend self
  include Rights

  def bind(bot)
    bot.on("PRIVMSG", message: /^!kick +([[:graph:]]+)(?: (.+))?/) do |msg, match|
      next if !authorize! msg, %w(admin modo), "You cannot kick, you are not an \"admin\" nor a \"modo\""
      chan = CrystalIrc::Chan.new msg.arguments.first
      user = CrystalIrc::User.new match.as(Regex::MatchData)[1]
      bot.kick([chan], [user], match.as(Regex::MatchData)[2]?)
    end.on("PRIVMSG", message: /^!(join|part) +([[:graph:]]+)/) do |msg, match|
      match = match.as(Regex::MatchData)
      command = match[1]
      next if !authorize! msg, "admin", "You cannot #{command}, you are not an \"admin\""
      chan = CrystalIrc::Chan.new match[2]
      bot.join([chan]) if command == "join"
      bot.part([chan]) if command == "part"
    end.on("PRIVMSG", message: /^!privmsg +([[:graph:]]+) +(.+)/) do |msg, match|
      match = match.as(Regex::MatchData)
      command = match[1]
      next if !authorize! msg, "admin", "You cannot #{command}, you are not an \"admin\""
      target_type = match[1].starts_with?("#") ? CrystalIrc::Chan : CrystalIrc::User
      bot.privmsg target_type.new(match[1]), match[2]
    end
  end
end
