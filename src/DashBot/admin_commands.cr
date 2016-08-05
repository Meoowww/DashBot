module DashBot
  module AdminCommands
    include Rights

    def bind(bot)
      bot.on("PRIVMSG", message: /^!kick (\w+)(?: (.+))?/) do |msg, match|
        unless authorized? msg, %w(admin modo)
          msg.reply "You cannot kick, you are not an \"admin\" nor a \"modo\""
          next
        end
        chan = CrystalIrc::Chan.new msg.arguments.first
        user = CrystalIrc::User.new match.as(Regex::MatchData)[1]
        bot.kick([chan], [user], match.as(Regex::MatchData)[2]?)
      end
    end
    extend self
  end
end
