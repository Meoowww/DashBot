require "option_parser"
require "daemonize"

class DashBot::Arguments
  @daemonize = false
  @err = "/var/log/dash_bot/errors.log"
  @out = "/var/log/dash_bot/chans.log"

  def use
    OptionParser.parse! do |parser|
      parser.banner = "Usage: DashBot [arguments]"
      parser.on("-e error", "--errors=PATH", "Specifies the path of the error log") { |path| @err = path }
      parser.on("-o output", "--output=PATH", "Specifies the path of the output log") { |path| @out = path }
      parser.on("-h", "--help", "Show this help") { puts parser; exit }
      parser.on("-d", "--daemonize", "Run in background as daemon") { @daemonize = true }
    end
    Daemonize.daemonize(stdout: @out, stderr: @err, stdin: "/dev/null") if @daemonize
  end
end
