module DashBot
  module Plugins
    module Rpg
      extend self
      include Rights

      def bind(bot)
        bind_add_roll bot
        bind_del_roll bot
        bind_launch_roll bot
      end

      def bind_add_roll(bot)
        bot.on("PRIVMSG", message: /^!rroll (.+) (.+)/) do |msg|
          msg_match = msg.message.to_s.match(/^!rroll (.+) (.+)/)
          next if msg_match.nil?

          # Check for roll correctness
          begin
            r = Rollable::Roll.parse(msg_match[2]).compact!.order!
          rescue
            msg.reply "#{msg_match[2]} is not a correct roll."
            next
          end

          # check if name already exists
          n = DB.exec({Int64}, "SELECT COUNT(*) FROM dice WHERE owner = $1 AND name = $2",
          [msg_match[1], msg.source_id]).to_hash[0]["count"]
          if n > 0
            msg.reply "Error: #{msg_match[1]} already exists. Remove it or use another name."
            next
          end

          # Insert new roll
          DB.exec "INSERT INTO dice (owner, name, roll, created_at)
          VALUES ($1, $2, $3, NOW())", [msg_match[1], msg.source_id, msg_match[2]]

          msg.reply "Roll #{msg_match[1]} successfully created for user #{msg.source_id}."
        end
      end

      def bind_del_roll(bot)
      end

      def bind_launch_roll(bot)
      end

    end
  end
end
