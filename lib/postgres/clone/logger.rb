require 'rainbow'

module Postgres
  module Clone
    module Logger
      DEFAULT_COLOR = :blue

      def log_message(message, color: DEFAULT_COLOR, header: nil, host_name: nil)
        puts header unless header.nil?
        puts Rainbow("#{host_name.nil? ? '' : "[#{host_name}] "}#{message}").color(color)
      end
    end
  end
end
