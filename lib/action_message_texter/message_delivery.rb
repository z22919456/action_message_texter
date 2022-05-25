module ActionMessageTexter
  # 分派工作
  class MessageDelivery < Delegator
    def initialize(messenger_class, action, *args)
      @messenger_class = messenger_class
      @action = action
      @args = args
    end

    def deliver_now
      processed_messenger.handle_exceptions do
        message.deliver
      end
    end

    def __getobj__
      @message ||= processed_messenger.message
    end

    def __setobj__(message)
      @message = message
    end

    def message
      __getobj__
    end

    # 是否送出
    def processed?
      @processed_messenger || @message
    end

    private

    def processed_messenger
      @processed_messenger ||= @messenger_class.new.tap do |messenger|
        messenger.process @action, *@args
      end
    end
  end
end
