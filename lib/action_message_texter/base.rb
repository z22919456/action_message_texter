# frozen_string_literal: true

module ActionMessageTexter
  #
  # 所有Texter的父類別
  #
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
      ##
      # 註冊觀察者Observer
      #
      # +Observer+ 需要包含一個Class Method +delivered_message(message)+
      # 此方法會在訊息傳送後被呼叫 並取得 +message+ instance
      # @params [Class|Symbel|String] observer
      def register_observer(observer)
        Message.register_observer(observer_class_for(observer))
      end

      ##
      # 移除已被註冊的 Observer
      # @params [Class|Symbel|String] observer
      def unregister_observer(observer)
        Message.unregister_observer(observer_class_for(observer))
      end

      ##
      # 註冊攔截器Interceptor
      #
      # +Interceptor+ 需要包含一個Class Method +delivering_message(message)+
      # 此Interceptor被註冊後 將於簡訊寄出前觸發delivering_message並取得 +message+ instance
      #  @params [Class|Symbel|String] interceptor
      def register_interceptor(interceptor)
        Message.register_interceptor(observer_class_for(interceptor))
      end

      ##
      # 移除已被註冊的 Interceptor
      # @params [Class|Symbel|String] observer
      def unregister_interceptor(interceptor)
        Message.unregister_observer(observer_class_for(interceptor))
      end

      ##
      # 可在 +Texter+ 中更改設定
      #
      # @param [Hash] value
      def default(value)
        self.default_params = default_params.merge(value).freeze if value
        default_params
      end

      ##
      # 提供初始化時的 Configruation 使用
      alias default_options= default

      def texter_name
        @texter_name ||= anonymous? ? 'anonymous' : name.underscore
      end
      attr_writer :texter_name

      ##
      # 寄送訊息 發出Log Notification
      def deliver_message(message)
        ActiveSupport::Notifications.instrument('deliver.action_message_texter') do |payload|
          payload[:content] = message.content
          payload[:to] = message.to
          payload[:deliver_at] = message.deliver_at || Time.now
          payload[:texter] = name
          yield # Let Message do the delivery actions
        end
      end

      private

      def method_missing(method_name, *args)
        if action_methods.include?(method_name.to_s)
          ActionMessageTexter::MessageDelivery.new(self, method_name, *args)
        else
          super
        end
      end

      def observer_class_for(value)
        case value
        when String, Symbol
          value.to_s.camelize.constantize
        else
          value
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
    def text(headers = {})
      @_message_was_called = true

      headers = self.class.default_params.merge(headers)

      message.content = render_content(headers)

      message.to = recipient(headers)

      message.deliver_at = headers.delete(:at)

      message.other_options = headers

      wrap_delivery_behavior!(self.class.delivery_method)

      message
    end

    private

    def render_content(headers)
      content = headers.delete(:content) || default_i18n_context(instance_values.reject do |key, _value|
                                                                   key.start_with?('_')
                                                                 end)
      unless content.present?
        raise 'Message content cannot be nil, add content to sms method, or add I18n to generated message content'
      end

      content
    end

    def recipient(headers)
      recipient = headers.delete(:to)
      raise 'Message should has at least one recipient' unless recipient.present?

      recipient
    end

    def default_i18n_context(interpolations = {})
      texter_scope = self.class.texter_name.tr('/', '.')
      I18n.t(action_name, **interpolations.symbolize_keys.merge(scope: [texter_scope]), default: nil)
    end

    ActiveSupport.run_load_hooks(:action_message_texter, self)
  end
end
