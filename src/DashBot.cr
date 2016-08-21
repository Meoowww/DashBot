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
    bot = CrystalIrc::Bot.new ip: "irc.mozilla.org", nick: "Dasshy", read_timeout: 300_u16

    Plugins::BasicCommands.bind(bot)
    Plugins::UserCommands.bind(bot)
    Plugins::AdminCommands.bind(bot)
    Plugins::Points.bind(bot)

    bot.connect.on_ready do
      bot.join([Irc::Chan.new("#equilibre")])
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
