module ActionShortMessage
  class Message
    attr_accessor :content, :to, :send_at, :delivery_options, :delivery_handler,
                  :raise_delivery_errors

    attr_writer :delivery_method

    # TODO: create registred interceptor and observer

    def initialize
      @raise_delivery_errors = true
    end

    def deliver
      # inform_interceptors
      if delivery_handler
        delivery_handler.deliver_message(self) { do_delivery }
      else
        do_delivery
      end
      # inform_observers
      self
    end

    def delivery_method(method = nil, _settings = {})
      if method
        # TODO: get provider from configuration
        @delivery_method = SMSProvider::Base.new
      else
        @delivery_method
      end
    end

    private

    def do_delivery
      delivery_method.deliver!(self)
    rescue StandardError => e
      raise e if raise_delivery_errors
    end
  end
end
