# frozen_string_literal: true

require 'active_job'

module ActionMessageTexter
  class DeliveryJob < ActiveJob::Base
    queue_as { ActionMailer::Base.deliver_later_queue_name }

    rescue_from StandardError, with: :handle_exception_with_texter_class

    def perform(_texter, sms_method, delivery_method, *args)
      texter_class.public_send(sms_method, *args).send(delivery_method)
    end

    private

    def texter_class
      if texter = Array(@serialized_arguments).first || Array(arguments).first
        texter.constantize
      end
    end

    def handle_exception_with_texter_class(exception)
      if klass = texter_class
        klass.handle_exception exception
      else
        raise exception
      end
    end
  end
end
