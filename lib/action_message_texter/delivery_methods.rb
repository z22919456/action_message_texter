module ActionMessageTexter
  module DeliveryMethods
    extend ActiveSupport::Concern

    included do
      cattr_accessor :raise_delivery_errors, default: true

      class_attribute :delivery_methods, default: {}.freeze
      class_attribute :delivery_method, default: :console
    end

    module ClassMethods
      def add_delivery_method(symbol, klass, options = {})
        class_attribute("#{symbol}_settings".to_sym) unless respond_to?("#{symbol}_settings".to_sym)
        send("#{symbol}_settings=".to_sym, options)
        self.delivery_methods = delivery_methods.merge(symbol.to_sym => klass).freeze
      end

      def wrap_delivery_behavior(message, method = nil, options = {})
        method ||= delivery_method
        message.delivery_handler = self
        case method
        when NilClass
          raise 'Delivery method cannot be nil'
        when Symbol
          if klass = delivery_methods[method]
            message.delivery_method(klass, (send("#{method}_settings") || {}).merge(options))
          else
            raise "Invalid delivery method #{method.inspect}"
          end
        else
          message.delivery_method(method)
        end
        message.raise_delivery_errors = raise_delivery_errors
      end
    end

    def wrap_delivery_behavior!(*args) # :nodoc:
      self.class.wrap_delivery_behavior(message, *args)
    end
  end
end
