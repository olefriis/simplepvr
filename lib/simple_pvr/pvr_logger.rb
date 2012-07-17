require 'logger'

module SimplePvr
  class PvrLogger
    @@logger = Logger.new(STDOUT)
  
    def self.info(message)
      @@logger.info(message)
    end
  end
end