module DashBot
  module UserCommands
    def bind(bot)
      puts "UserCommands.bind(bot)"
      bot.on("PRIVMSG", message: /^!register/) do |msg|
        id = msg.source.to_s.source_id
        puts "!register spot #{id}"
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
