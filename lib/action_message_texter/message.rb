module ActionMessageTexter
  class Message
    attr_accessor :content, :to, :deliver_at, :delivery_options, :delivery_handler, :other_options,
                  :raise_delivery_errors, :response

    attr_writer :delivery_method

    attr_reader :uuid

    # TODO: create registred interceptor and observer

    def initialize
      @raise_delivery_errors = true
      @uuid = SecureRandom.uuid
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

    def delivery_method(method_klass = nil, settings = {})
      puts method_klass
      if method_klass
        # TODO: get provider from configuration
        @delivery_method = method_klass.new(settings)
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
