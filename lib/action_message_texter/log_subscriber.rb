# frozen_string_literal: true

module ActionMessageTexter
  class LogSubscriber < ActiveSupport::LogSubscriber
    # delivery log
    def deliver(event)
      info do
        message = event.payload[:content]
        to = event.payload[:to]
        deliver_at = event.payload[:deliver_at]
        texter = event.payload[:texter]
        "#{texter}: Delivered message [#{message}] to #{to} at #{deliver_at}"
      end
    end

    # process message log
    def process(event)
      debug do
        messenger = event.payload[:messenger]
        action = event.payload[:action]
        "#{messenger}##{action}: processed short Message in #{event.duration.round(1)}ms"
      end
    end

    def logger
      ActionMessageTexter::Base.logger
    end
  end
end

ActionMessageTexter::LogSubscriber.attach_to :action_message_texter
