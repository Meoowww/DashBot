#!/usr/bin/env crystal

require "crirc"
require "rollable"
require "./DashBot/*"
require "./DashBot/plugins/*"

# Extention of `String`.
module DashBot::Source
  def source_nick : String
    self.split("!")[0].to_s
  end

  def source_id : String
    self.split("!")[1].to_s.split("@")[0].to_s
  end

  def source_whois : String
    self.split("!")[1].to_s.split("@")[1].to_s
  end
end

class String
  include DashBot::Source
end

module DashBot
  def start
    Arguments.new.use
    client = Crirc::Network::Client.new(ip: "irc.mozilla.org", port: 6667_u16, ssl: false, nick: "Dasshyx#{rand(1..9)}", read_timeout: 300_u16)
    client.connect
    client.start do |bot|
      Plugins::BasicCommands.bind(bot)
      Plugins::UserCommands.bind(bot)
      Plugins::AdminCommands.bind(bot)
      Plugins::Points.bind(bot)
      Plugins::Messages.bind(bot)
      Plugins::Reminder.bind(bot)
      Plugins::Rpg.bind(bot)
      Plugins::Random.bind(bot)
      # Plugins::Anarchism.bind(bot)

      bot.on_ready do
        bot.join (ARGV.empty? ? ["#equilibre"] : ARGV).map { |chan| Crirc::Protocol::Chan.new(chan) }
      end

      loop do
        begin
          m = bot.gets
          break if m.nil?
          STDERR.puts "[#{Time.utc}] #{m}"
          spawn { bot.handle(m.as(String)) }
        rescue IO::TimeoutError
          puts "Nothing happened..."
        end
      end
    end
  end

  extend self
end

loop do
  begin
    DashBot.start
  rescue err
    STDERR.puts err
    STDOUT.puts err
    sleep 1
  end
end
