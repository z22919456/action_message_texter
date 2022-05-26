require 'action_message_texter'

module ActionMessageTexter
  class Engine < ::Rails::Engine
    isolate_namespace ActionMessageTexter
    config.action_message_texter = ActiveSupport::OrderedOptions.new
    # config.eager_load_namespaces << ActionMessageTexter

    # Set default logger for ActionMessageTexter
    initializer 'action_message_texter.logger' do
      ActiveSupport.on_load(:action_message_texter) { self.logger ||= Rails.logger }
    end

    # Set all configuration for ActionMessageTexter
    config.after_initialize do |app|
      ActiveSupport.on_load(:action_message_texter) do
        options = app.config.action_message_texter
        options.each { |k, v| send("#{k}=", v) }
      end
    end
  end
end
