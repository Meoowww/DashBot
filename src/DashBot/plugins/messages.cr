module DashBot
  module Plugins
    module Messages
      extend self
      include Rights
      include Database

      def bind(bot)
        bind_write bot
        bind_read bot
      end

      def bind_write(bot)
        bot.on("PRIVMSG", message: /^!write (\w+) (.+)$/) do |msg, match|
          id = match.as(Regex::MatchData)[1]
          message = match.as(Regex::MatchData)[2]
        end
      end

      def bind_read(bot)
        bot.on("PRIVMSG", message: /^!read$/) do |msg, match|
        end
      end
    end
  end
end
