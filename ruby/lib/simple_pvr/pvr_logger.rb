require 'logger'

module SimplePvr
  class PvrLogger
    @@logger = Logger.new(STDOUT)
    @@logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} #{msg}\n"
    end
  
    def self.info(message)
      @@logger.info(message)
    end
  end
end