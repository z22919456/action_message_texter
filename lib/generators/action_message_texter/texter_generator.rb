# frozen_string_literal: true

module ActionMessageTexter
  module Generators
    class TexterGenerator < Rails::Generators::NamedBase
      require 'yaml'
      source_root File.expand_path(__dir__)

      argument :actions, type: :array, default: [], banner: 'method method'

      check_class_collision suffix: 'Texter'

      def create_application_texter
        unless File.exist?('app/texter/application_texter.rb')
          template '../templetes/application_texter.rb', File.join('app/texter', 'application_texter.rb')
        end
      end

      def create_texter
        template '../templates/texter.rb', File.join('app/texter', "#{file_name}_texter.rb")
      end

      def create_locale_yml
        @yaml = {}
        default_locale = I18n.default_locale.to_s
        scope_name = "#{file_name}_texter"
        @yaml[default_locale] = {}
        @yaml[default_locale][scope_name] = {}
        actions.each do |action|
          @yaml[default_locale][scope_name][action] = "#{action} message"
        end
        template '../templates/I18n.yml.rb', File.join('config/locales/texter', "#{file_name}_texter.yml")
      end

      protected

      def file_name
        @_file_name ||= super.gsub(/_texter|Texter/i, '')
      end
    end
  end
end
