# frozen_string_literal: true

module ActionMessageTexter
  class Message
    class << self
      @@delivery_notification_observers = []
      @@delivery_interceptors = []
      def register_observer(observer)
        @@delivery_notification_observers << observer unless @@delivery_notification_observers.include?(observer)
      end

      def unregister_observer(observer)
        @@delivery_notification_observers.delete(observer)
      end

      def register_interceptor(interceptor)
        @@delivery_interceptors << interceptor unless @@delivery_interceptors.include?(interceptor)
      end

      def unregister_interceptor(interceptor)
        @@delivery_interceptors.delete(interceptor)
      end
    end
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
      inform_interceptors
      if delivery_handler
        delivery_handler.deliver_message(self) { do_delivery }
      else
        do_delivery
      end
      inform_observers
      response
    end

    def delivery_method(method_klass = nil, settings = {})
      puts method_klass
      if method_klass
        # TODO: get provider from configuration
        @@delivery_method = method_klass.new(settings)
      else
        @@delivery_method
      end
    end

    private

    def inform_observers
      @@delivery_notification_observers.each do |observer|
        observer.delivered_message(self)
      end
    end

    def inform_interceptors
      @@delivery_interceptors.each do |observer|
        observer.delivering_message(self)
      end
    end

    def do_delivery
      delivery_method.deliver!(self)
    rescue StandardError => e
      raise e if raise_delivery_errors
    end
  end
end
