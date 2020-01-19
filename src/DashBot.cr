#!/usr/bin/env crystal

require "crirc"
require "rollable"
require "yaml"
require "json"

class DashBot
end

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

module Loader
  def fetch_configuration(file)
    configuration = File.read(file)
    if file.ends_with?(".yml") || file.ends_with?(".yaml")
      YAML.parse(configuration)
    else
      JSON.parse(configuration)
    end
  end

  macro bind_plugins(config, *plugins)
    {% for plugin in plugins %}
      plugin = Plugins::{{plugin.id}}
      plugin_config = Hash(String, String).new
      config[{{plugin}}].each { |k, v| plugin_config[k.to_s] = v.to_s }
      plugin_instance = plugin.new(plugin_config)
      plugin_instance.bind(bot) if plugin_instance.enabled?
    {% end %}
  end

  extend self
end

require "./DashBot/*"
require "./DashBot/plugins/*"

class DashBot
  def initialize
    @config = Hash(String, Hash(String, String)).new
  end

  def start
    Arguments.new.use
    client = Crirc::Network::Client.new(ip: "irc.mozilla.org", port: 6667_u16, ssl: false, nick: "Dasshyx#{rand(1..9)}", read_timeout: 300_u16)
    client.connect
    client.start do |bot|
      config = Loader.fetch_configuration("config.json")
      Loader.bind_plugins(config, "BasicCommands", "UserCommands", "AdminCommands", "Points", "Messages", "Reminder", "Rpg", "Random", "Anarchism"

      bot.on_ready do
        bot.join (ARGV.empty? ? ["#equilibre"] : ARGV).map { |chan| Crirc::Protocol::Chan.new(chan) }
      end

      loop do
        begin
          m = bot.gets
          break if m.nil?
          STDERR.puts "[#{Time.now}] #{m}"
          spawn { bot.handle(m.as(String)) }
        rescue IO::Timeout
          puts "Nothing happened..."
        end
      end
    end
  end
end

loop do
  begin
    DashBot.new.start
  rescue err
    STDERR.puts err
    STDOUT.puts err
    sleep 1
  end
end
