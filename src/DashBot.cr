#!/usr/bin/env crystal

require "CrystalIrc"
require "rollable"
require "./DashBot/*"
require "./DashBot/plugins/*"

module Irc
  include CrystalIrc
end

module DashBot
  def start
    Arguments.new.use
    bot = CrystalIrc::Bot.new ip: "irc.mozilla.org", nick: "Dasshy", read_timeout: 300_u16

    Plugins::BasicCommands.bind(bot)
    Plugins::UserCommands.bind(bot)
    Plugins::AdminCommands.bind(bot)
    Plugins::Points.bind(bot)
    Plugins::Messages.bind(bot)
    Plugins::Rpg.bind(bot)
    Plugins::Random.bind(bot)

    bot.connect.on_ready do
      bot.join (ARGV.empty? ? ["#equilibre"] : ARGV).map { |chan| Irc::Chan.new(chan) }
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

loop do
  begin
    DashBot.start
  rescue err
    STDERR.puts err
    STDOUT.puts err
    sleep 1
  end
end
