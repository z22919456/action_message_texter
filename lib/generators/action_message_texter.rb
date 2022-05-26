module Rails
  module Generators
    class ActionMessageTexter < NamedBase
      source_root File.expand_path(__dir__)

      argument :actions, type: :array, default: [], banner: 'method method'

      check_class_collision suffix: 'Texter'

      def create_message_file
        template './templates/texter.rb', File.join('app/texter', "#{file_name}_texter.rb")
      end

      protected

      def file_name
        @_file_name ||= super.gsub(/_texter|Texter/i, '')
      end
    end
  end
end
