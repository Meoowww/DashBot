module DashBot::Plugins::Anarchism
  extend self

  def bind(bot)
    bind_new_user bot
  end

  def bind_new_user(bot)
    bot.on("JOIN") do |msg, _|
      chan = Crirc::Protocol::Chan.new msg.message.to_s
      user = Crirc::Protocol::User.new msg.source.source_nick
      bot.mode chan, "+o", user
    end
  end
end
