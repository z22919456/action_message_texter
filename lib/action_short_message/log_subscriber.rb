module ActionShortMessage
  class LogSubscriber < ActiveSupport::LogSubscriber
    # delivery log
    def deliver(_event)
      info do
        # TODO: Add Log
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
      ActionShortMessage::Base.logger || Rails.logger
    end
  end
end

ActionShortMessage::LogSubscriber.attach_to :action_short_message
