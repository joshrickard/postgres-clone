require 'net/ssh'
require 'postgres/clone/command_line'
require 'postgres/clone/command_result'
require 'postgres/clone/logger'

module Postgres; module Clone;
  module RemoteCommands
    include CommandLine
    include Logger

    def close_ssh_connections
      (@ssh_connections || {}).values.each(&:close)
    end

    def open_ssh_connection(host_name, user)
      @ssh_connections ||= {}
      @ssh_connections[host_name] ||= begin
        log_message("Opening ssh connection to #{host_name} as #{user}")
        Net::SSH.start(host_name, user)
      end
    end

    def run_remote(host_name, command, user: current_user, sudo: false)
      result_attributes = { exit_code: nil, output: '' }

      ssh = open_ssh_connection(host_name, user)
      ssh.open_channel do |channel|
        channel.request_pty { |_, success| abort('could not obtain pty') unless success }

        actual_command = build_command(command, user: user, sudo: sudo)
        log_message(actual_command, host_name: host_name, color: :gray)

        channel.exec(actual_command) do |_, success|
          abort('could not execute command') unless success

          channel.on_data do |_, data|
            puts data
            case data
            when /^\[sudo\] password for (.+):/i
              password = user_password(host_name, $1)
              log_message("Sending sudo password for #{user}", host_name: host_name, color: :gray)
              channel.send_data("#{password}\n")
            when /(.+)@(.+)'s password:/i
              password = user_password($2, $1)
              log_message("Sending user password for #{$1}", host_name: host_name, color: :gray)
              channel.send_data("#{password}\n")
            when /are you sure you want to continue connecting \(yes\/no\)\?/i
              log_message('ignoring key warning', host_name: host_name, color: :yellow)
              channel.send_data("yes\n")
            else
              result_attributes[:output] += data
            end
          end

          channel.on_extended_data do |_, _, data|
            log_message("stderr: #{data}", host_name: host_name, color: :red)
          end

          channel.on_request('exit-status') do |_, data|
            result_attributes[:exit_code] = data.read_long
          end
        end
      end

      ssh.loop

      CommandResult.new(result_attributes)
    end

    def sudo_remote(host_name, command, user: nil)
      run_remote(host_name, command, user: user, sudo: true)
    end
  end
end; end;
