module DashBot
  module Plugins
    module Points
      extend self
      include Rights

      def bind(bot)
        bot.on("PRIVMSG", message: /^!p ([[:graph:]]+) ([[:graph:]]+)/) do |msg, match|
          match = match.as Regex::MatchData
          DB.exec "INSERT INTO points (assigned_to, assigned_by, type, created_at)
          VALUES ($1, $2, $3, NOW())", [match[2], msg.source_id, match[1].downcase]
          n = DB.exec({Int64}, "SELECT COUNT(*) FROM points WHERE assigned_to = $1 AND type = $2", [match[2], match[1].downcase]).to_hash[0]["count"]
          msg.reply "#{match[2]} has now #{n} point#{n > 1 ? "s" : ""} #{match[1]}"
        end
      end
    end
  end
end
