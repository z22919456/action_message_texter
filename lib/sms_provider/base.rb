module SMSProvider
  class Base
    def initialize(*setting)
      puts setting
    end

    def deliver!(message)
      puts message
    end
  end
end
