require 'action_message_texter'

module ActionMessageTexter
  class Engine < ::Rails::Engine
    isolate_namespace ActionMessageTexter
    config.eager_load_namespaces << ActionMessageTexter

    initializer 'action_message_texter.logger' do
      ActiveSupport.on_load(:action_message_texter) { self.logger ||= Rails.logger }
    end
  end
end
