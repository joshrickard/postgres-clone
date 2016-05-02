require 'postgres/clone/logger'

module Postgres
  module Clone
    module CommandLine
      include Logger

      def build_command(command, sudo: false, user: nil)
        if sudo
          "sudo#{user.nil? ? '' : " -u #{user}"} #{command}"
        else
          command
        end
      end

      def log_command(host_name, command)
        log_message(Rainbow("[#{host_name}] Executing: #{command}").darkgray)
      end
    end
  end
end
