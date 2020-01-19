class DashBot::Plugin
  @configuration : Hash(String, String)

  # def bind(bot)

  def initialize(config : Hash(String, String))
    @configuration = { "enabled" => "false" }
    config.each { |k, v| @configuration[k] = v }
  end

  def initialize
    @configuration = { "enabled" => "false" }
  end

  def enable
    @configuration["enabled"] = "true"
  end

  def disable
    @configuration["enabled"] = "false"
  end

  def enabled?
    @configuration["enabled"] == "true"
  end

  def disabled?
    !enabled?
  end

  def configure(key : String, value : String)
    @configuration[key] = value
  end

  def configuration(key : String)
    @configuration[key]? || ""
  end
end
