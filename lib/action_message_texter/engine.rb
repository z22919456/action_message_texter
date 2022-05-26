require 'action_message_texter'

module ActionMessageTexter
  class Engine < ::Rails::Engine
    isolate_namespace ActionMessageTexter
    config.eager_load_namespaces << ActionMessageTexter

    initializer 'action_message_texter.logger' do
      ActiveSupport.on_load(:action_message_texter) { self.logger ||= Rails.logger }
    end

    config.after_initialize do |app|
      ActiveSupport.on_load(:action_message_txter) do
        options = app.config.action_short_message
        options.each { |k, v| send("#{k}=", v) }
      end
    end
  end
end
