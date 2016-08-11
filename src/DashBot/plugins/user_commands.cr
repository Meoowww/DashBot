module DashBot
  module Plugins
    module UserCommands
      include Rights

      def bind(bot)
        bind_register bot
        bind_group bot
      end

      def bind_group(bot)
        bot.on("PRIVMSG", message: /^!group add (\w+) (\w+)/) do |msg, match|
          id = msg.source.to_s.source_id
          if !authorized? msg
            msg.reply "Unauthorized"
            next
          end
          match = match.as Regex::MatchData
          n = DB["users"].count({"id" => id})
          if n > 0
            DB["users"].find({"id" => match[1]}) do |e|
              groups = e.value("groups").value.as(BSON).decode.as(Array(BSON::Field)) << match[2]
              DB["users"].update({"id" => match[1]}, {"$set" => { "groups" => groups}})
              msg.reply "The user \"#{match[1]}\" has gained the group \"#{match[2]}\""
            end
          else
            msg.reply "User \"#{match[1]}\" not registered"
          end
        end
      end

      def bind_register(bot)
        bot.on("PRIVMSG", message: /^!register/) do |msg|
          id = msg.source.to_s.source_id
          is_admin = DB["users"].count({} of String => String) == 0
          n = DB["users"].count({"id" => id})
          if n > 0
            msg.reply "Cannot register \"#{id}\" twice"
          else
            msg.reply "Register \"#{id}\""
            DB["users"].insert({"id" => id, "groups" => (is_admin ? ["admin"] : ["default"]) })
          end
        end
      end

      extend self
    end
  end
end
