require "./rpg/*"

module DashBot::Plugins::Rpg
  extend self
  include Rights

  def bind(bot)
    Music.bind(bot)
    Roll.bind(bot)
  end
end
