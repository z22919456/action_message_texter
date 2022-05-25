module ActionMessageTexter
  class ShortMessage
    attr_accessor :action, :message, :to, :debug, :options

    attr_writer :sms_provider

    # 建立 provider 實體
    def sms_provider(method = nil, settings = {})
      @sms_provider = method.new(settings)
    end

    # observers
    @@delivery_notifications = []

    def self.register_observer(observer)
      @@delivery_notifications << observer unless @@delivery_notifications.include? observer
    end

    def self.unregister_observer(observer)
      @@delivery_notifications.delete(observer)
    end

    def inform_observers
      @@delivery_notification_observers.each do |observer|
        observer.delivered_message(self)
      end
    end

    def deliver
      ActiveSupport::Notifications.instrument('deliver.action_message_texter', { messagage: message, to: to }) do
        @sms_provider.send_message(message, options.merge(to: to))
      end
      inform_observers
    end
  end
end
