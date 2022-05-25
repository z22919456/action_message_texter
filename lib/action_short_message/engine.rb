require 'action_short_message'

module ActionShortMessage
  class Engine < ::Rails::Engine
    isolate_namespace ActionShortMessage
    config.eager_load_namespaces << ActionShortMessage

    initializer 'action_short_message.logger' do
      ActiveSupport.on_load(:action_short_message) { self.logger ||= Rails.logger }
    end
  end
end
