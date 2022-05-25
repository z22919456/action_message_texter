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
      deliver_at: nil # who to say the message send on
    }

    class << self
      def default(value)
        self.default_params = default_params.merge(value).freeze if value
        default_params
      end

      # set default params by configuration
      alias default_options= default

      def texter_name
        @texter_name ||= anonymous? ? 'anonymous' : name.underscore
      end
      attr_writer :texter_name

      def deliver_message(message)
        # Notification
        ActiveSupport::Notifications.instrument('deliver.action_message_texter') do |payload|
          payload[:content] = message.content
          payload[:to] = message.to
          payload[:deliver_at] = message.deliver_at || Time.now
          payload[:texter] = name
          yield # Let Message do the delivery actions
        end
      end

      private

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
    def sms(headers = {})
      @_message_was_called = true

      headers = self.class.default_params.merge(headers)

      message.content = render_content(headers)

      message.to = recipient(headers)

      message.deliver_at = headers.delete(:at)

      message.other_options = headers

      # # TODO: set provider dynamic
      wrap_delivery_behavior!(:base)

      # message
    end

    private

    def render_content(headers)
      content = headers.delete(:content) || default_i18n_context
      raise 'Message content cannot be nil' unless content.present?

      content
    end

    def recipient(headers)
      recipient = headers.delete(:to)
      raise 'Message should has at least one recipient' unless recipient.present?

      recipient
    end

    def default_i18n_context(interpolations = {}) # :doc:
      texter_scope = self.class.texter_name.tr('/', '.')
      I18n.t(:subject, **interpolations.merge(scope: [texter_scope, action_name], default: action_name.humanize))
    end

    ActiveSupport.run_load_hooks(:action_message_texter, self)
  end
end
