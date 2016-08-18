module DashBot
  module Plugins
    module Points
      include Rights

      def bind(bot)
        bot.on("PRIVMSG", message: /^!p ([[:graph:]]+) ([[:graph:]]+)/) do |msg, match|
          match = match.as Regex::MatchData
          hash = {"nick" => match[2], "type" => match[1]} of String => String | Int32
          STDERR.puts hash.inspect
          n = DB["points"].count(hash)
          if n > 0
            DB["points"].find(hash) do |e|
              count = e["count"].as(Int32)
              DB["points"].update(hash, {"$set" => { "count" => count + 1}})
              msg.reply "#{match[2]} has now #{count + 1} points #{match[1]}"
            end
          else
            hash["count"] = 1
            DB["points"].insert(hash)
            msg.reply "#{match[2]} has now 1 point #{match[1]}"
          end
        end
      end

      extend self
    end
  end
end
