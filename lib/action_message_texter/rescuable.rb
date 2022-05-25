# frozen_string_literal: true

module ActionMessageTexter
  module Rescuable
    extend ActiveSupport::Concern
    include ActiveSupport::Rescuable

    class_methods do
      def handle_exception(exception)
        rescue_with_handler(exception) || raise(exception)
      end
    end

    def handle_exceptions
      yield
    rescue StandardError => e
      rescue_with_handler(e) || raise
    end

    private

    def process(*)
      handle_exceptions do
        super
      end
    end
  end
end
