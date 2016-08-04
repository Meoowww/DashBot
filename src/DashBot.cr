require "CrystalIrc"
require "rollable"
require "./DashBot/*"

module DashBot
  def start
    bot = CrystalIrc::Bot.new ip: "irc.mozilla.org", nick: "Dasshy2", read_timeout: 300_u16

    BasicCommands.bind(bot)
    UserCommands.bind(bot)

    bot.connect
    sleep 1.5
    bot.join([CrystalIrc::Chan.new("#equilibre2")])

    loop do
      begin
        bot.gets do |m|
          break if m.nil?
          STDERR.puts "[#{Time.now}] #{m}"
          spawn { bot.handle(m.as(String)) }
        end
      rescue IO::Timeout
        puts "Nothing happened..."
      end
    end
  end

  extend self
end

DashBot.start
