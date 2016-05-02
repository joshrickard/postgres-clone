require 'postgres/clone/command_line'
require 'postgres/clone/command_result'
require 'postgres/clone/logger'

module Postgres; module Clone;
  module LocalCommands
    include CommandLine

    def run_local(command, sudo: false, user: nil)
      actual_command = build_command(command, sudo: sudo, user: user)
      log_command('localhost', actual_command)

      output = `#{actual_command}`

      CommandResult.new(exit_code: $?.exitstatus, output: output)
    end

    def sudo_local(command, user: nil)
      run_local(command, sudo: true, user: user)
    end
  end
end; end;
