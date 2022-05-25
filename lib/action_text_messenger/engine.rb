require 'action_text_messenger'

module ActionTextMessenger
  class Engine < ::Rails::Engine
    isolate_namespace ActionTextMessenger
    config.eager_load_namespaces << ActionTextMessenger

    initializer 'action_text_messenger.logger' do
      ActiveSupport.on_load(:action_text_messenger) { self.logger ||= Rails.logger }
    end
  end
end
