# frozen_string_literal: true

module ActionMessageTexter
  # 分派工作
  class MessageDelivery < Delegator
    def initialize(texter_class, action, *args)
      @texter_class = texter_class
      @action = action
      @args = args
    end

    def deliver_now
      processed_messenger.handle_exceptions do
        message.deliver
      end
    end

    def deliver_later(options = {})
      enqueue_delivery :deliver_now, options
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
      @processed_messenger ||= @texter_class.new.tap do |messenger|
        messenger.process @action, *@args
      end
    end

    def enqueue_delivery(delivery_method, options = {})
      args = @texter_class.name, @action.to_s, delivery_method.to_s, *@args
      ::ActionMessageTexter::DeliveryJob.set(options).perform_later(*args)
    end
  end
end
