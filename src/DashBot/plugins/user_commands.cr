module DashBot
  module Plugins
    module UserCommands
      extend self
      include Rights
      include Database

      def bind(bot)
        bind_register bot
        bind_group bot
      end

      def bind_group(bot)
        bind_group_add bot
        bind_group_ls bot
        bind_group_rm bot
      end

      def bind_group_rm(bot)
        bot.on("PRIVMSG", message: /^!group rm (\w+) (\w+)/) do |msg, match|
          next if !authorize!(msg)
          match = match.as Regex::MatchData
          if user_exists? match[1]
            DB["users"].find({"id" => match[1]}) do |e|
              groups = e["groups"].as(BSON).decode.as(Array(BSON::Field))
              if groups.includes? match[2]
                groups.delete match[2]
                DB["users"].update({"id" => match[1]}, {"$set" => { "groups" => groups}})
                msg.reply "The user \"#{match[1]}\" has lost the group \"#{match[2]}\""
              else
                msg.reply "The user \"#{match[1]}\" does not belongs to the group \"#{match[2]}\""
              end
            end
          else
            msg.reply "User \"#{match[1]}\" not registered"
          end
        end
      end

      def bind_group_ls(bot)
        bot.on("PRIVMSG", message: /^!group ls (\w+)/) do |msg, match|
          match = match.as Regex::MatchData
          if user_exists? match[1]
            DB["users"].find({"id" => match[1]}) do |e|
              groups = e["groups"].as(BSON).decode.as(Array(BSON::Field)).join(", ")
              msg.reply "User \"#{match[1]}\" has the groups : #{groups}"
            end
          else
            msg.reply "User \"#{match[1]}\" is not registered"
          end
        end
      end

      def bind_group_add(bot)
        bot.on("PRIVMSG", message: /^!group add (\w+) (\w+)/) do |msg, match|
          next if !authorize!(msg)
          match = match.as Regex::MatchData
          if user_exists? match[1]
            DB["users"].find({"id" => match[1]}) do |e|
              groups = e["groups"].as(BSON).decode.as(Array(BSON::Field)) << match[2]
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
          if user_exists? msg.source_id
            msg.reply "Cannot register \"#{msg.source_id}\" twice"
          else
            msg.reply "Register \"#{msg.source_id}\""
            is_admin = DB["users"].count(Hash(String, String).new) == 0
            DB["users"].insert({"id" => msg.source_id, "groups" => (is_admin ? ["admin"] : ["default"]) })
          end
        end
      end
    end
  end
end
