require "CrystalIrc"
require "rollable"
require "./DashBot/rights"
require "./DashBot/*"

module DashBot
  def start
    bot = CrystalIrc::Bot.new ip: "irc.mozilla.org", nick: "Dasshy", read_timeout: 300_u16

    BasicCommands.bind(bot)
    UserCommands.bind(bot)
    AdminCommands.bind(bot)

    bot.connect.on_ready do
      bot.join([CrystalIrc::Chan.new("#equilibre")])
    end

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
