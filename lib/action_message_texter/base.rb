module ActionMessageTexter
  class Base < AbstractController::Base
    include Rescuable
    include DeliveryMethods

    include AbstractController::Logger
    include AbstractController::Translation
    include AbstractController::Callbacks
    include AbstractController::Caching

    # configure
    class_attribute :default_params, default: {
      to: nil, # who the message is destined for
      date: nil # who to say the message send on
    }
    attr_accessor :default_options

    class << self
      def default(value)
        self.default_params = default_params.merge(value).freeze if value
        default_params
      end

      # set default params by configuration
      alias default_options= default

      def deliver_message(message)
        # Notification
        ActiveSupport::Notifications.instrument('deliver.action_message_texter') do |payload|
          set_payload_for_message(payload, message)
          yield # Let Message do the delivery actions
        end
      end

      private

      # get payload from message to Notifications
      def set_payload_for_message(payload, message)
        payload[:message] = message.content
        # TODO: Get Payload from message
      end

      # connect to MessageDelivery through method_missing
      def method_missing(method_name, *args)
        if action_methods.include?(method_name.to_s)
          ActionMessageTexter::MessageDelivery.new(self, method_name, *args)
        else
          super
        end
      end
    end

    attr_internal :message

    def initialize
      super()
      @_message_was_called = false
      @_message = Message.new
    end

    def process(method_name, *args)
      payload = {
        messenger: self.class.name,
        action: method_name,
        args: args
      }

      # Notification
      ActiveSupport::Notifications.instrument('process.action_message_texter', payload) do
        super
        @_message = NullMessage.new unless @_message_was_called
      end
    end

    class NullMessage
    end

    # return Message instance
    def sms(_content = nil, headers = {})
      # TODO: prepare message and return
      @_message_was_called = true

      headers = self.class.default.merge(headers)

      wrap_delivery_behavior!(:base)

      message.content = content
    end

    private

    def default_i18n_subject(interpolations = {}); end

    ActiveSupport.run_load_hooks(:action_message_texter, self)
  end
end
