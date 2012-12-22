require 'logger'

class LoggerFactory

  @@log_path = "log.txt"
  @@log = Logger.new (@@log_path);

  def self.get_default_logger

    @@log

  end


end