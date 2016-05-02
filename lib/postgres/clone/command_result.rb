module Postgres
  module Clone
    class CommandResult
      attr_reader :exit_code, :output

      def initialize(exit_code:, output:)
        @exit_code = exit_code
        @output = output.strip
      end

      def failed?
        !success?
      end

      def success?
        exit_code == 0
      end
    end
  end
end
