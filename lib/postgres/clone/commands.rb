require 'etc'
require 'postgres/clone/command_result'
require 'postgres/clone/local_commands'
require 'postgres/clone/logger'
require 'postgres/clone/remote_commands'

module Postgres; module Clone;
  module Commands
    include Logger
    include LocalCommands
    include RemoteCommands

    def copy_file(src_host, dst_host, file_path)
      log_message("Copying #{file_path} from #{src_host} to #{dst_host}", header: '')

      if src_host == dst_host
        log_message(src_host, 'Source and destination host are the same, skipping file copy', color: :yellow, header: '')
        return
      end

      result =
        if local_host?(src_host)
          if file_exists?(dst_host, file_path)
            puts Rainbow("[#{dst_host}] File #{file_path} already exists!").green
            return if %w(yes y).include?(
              ask(Rainbow('Would you like to restore the existing dump (y/n)?').yellow).downcase
            )
            abort Rainbow("[#{dst_host}] File #{file_path} already exists!").red
          else
            run_local("scp #{file_path} #{dst_host}:#{file_path}")
          end
        elsif local_host?(dst_host)
          if file_exists?('localhost', file_path)
            puts Rainbow("[localhost] File #{file_path} already exists!").green
            return if %w(yes y).include?(
              ask(Rainbow('Would you like to restore the existing dump (y/n)?').yellow).downcase
            )
            abort Rainbow("[localhost] File #{file_path} already exists!").red
          else
            run_local("scp #{src_host}:#{file_path} #{file_path}")
          end
        else
          if file_exists?(dst_host, file_path)
            puts Rainbow("[#{dst_host}] File #{file_path} already exists!").green
            return if %w(yes y).include?(
              ask(Rainbow('Would you like to restore the existing dump (y/n)?').yellow).downcase
            )
            abort Rainbow("[#{dst_host}] File #{file_path} already exists!").red
          else
            run_remote(src_host, "scp #{file_path} #{dst_host}:#{file_path}")
          end
        end

      abort Rainbow('The file copy failed, cancelling database clone').red if result.failed?
    end

    def current_user
      # TODO: remote
      Etc.getlogin
    end

    def disk_usage(host_name)
      result =
        if local_host?(host_name)
          run_local(free_disk_space_command)
        else
          run_remote(host_name, free_disk_space_command)
        end

      columns = result.output.split(/\s+/)

      abort Rainbow('Expected at least 5 columns of data from df -H').red unless columns.length >= 5

      { available: columns[3], size: columns[1] }
    end

    def file_exists?(host_name, file_path)
      log_message("Checking file existance: #{file_path}", host_name: host_name)

      result =
        if local_host?(host_name)
          run_local(file_exists_command(file_path))
        else
          run_remote(host_name, file_exists_command(file_path))
        end

      result.success?
    end

    def file_exists_command(file_path)
      "test -e #{file_path}"
    end

    def free_disk_space_command
      'df -H / | grep "/$"'
    end

    def local_host?(host_name)
      host_name == 'localhost'
    end

    def postgres_create_database(host_name, database_name, template: nil)
      log_message("Creating database #{database_name}", host_name: host_name)

      result =
        if local_host?(host_name)
          run_local(
            postgres_create_database_command(database_name, template: template)
          )
        else
          sudo_remote(
            host_name,
            postgres_create_database_command(database_name, template: template),
            user: 'postgres'
          )
        end

      abort Rainbow('Failed to create database').red if result.failed?
    end

    def postgres_create_database_command(database_name, template: nil)
      "psql -c \"create database #{database_name}#{template.nil? ? '' : " with template #{template}"}\""
    end

    def postgres_dump_database(host_name, database_name, file_path)
      log_message("Dumping database #{database_name} to #{file_path}", header: '', host_name: host_name)

      if file_exists?(host_name, file_path)
        puts Rainbow("[#{host_name}] File #{file_path} already exists!").green
        use_existing_file = %w(yes y).include?(
          ask(Rainbow('Would you like to restore the existing dump (y/n)?').yellow).downcase
        )
        return if use_existing_file
        abort Rainbow("Please delete #{host_name}:#{file_path} before continuing").red
      end

      result =
        if local_host?(host_name)
          run_local(
            postgres_dump_database_command(file_path, database_name)
          )
        else
          sudo_remote(
            host_name,
            postgres_dump_database_command(file_path, database_name),
            user: 'postgres'
          )
        end

      if result.failed?
        puts Rainbow('The database dump failed, cleaning up partial dump file').red
        if local_host?(host_name)
          sudo_local("rm #{file_path}")
        else
          sudo_remote(host_name, "rm #{file_path}")
        end
        abort Rainbow('Cancelling database clone').red
      end
    end

    def postgres_dump_database_command(file_path, source_database)
      "pg_dump --file=#{file_path} --no-acl --no-owner --format=custom #{source_database}"
    end

    def postgres_restore_database(host_name, database_name, file_path)
      log_message("Restoring database #{database_name} from #{file_path}", header: '', host_name: host_name)

      abort Rainbow("File #{file_path} does not exist!").red unless file_exists?(host_name, file_path)

      # TODO: check to see if target database exists

      postgres_create_database(host_name, database_name)

      result =
        if local_host?(host_name)
          run_local(
            postgres_restore_database_command(file_path, database_name)
          )
        else
          sudo_remote(
            host_name,
            postgres_restore_database_command(file_path, database_name),
            user: 'postgres'
          )
        end

      abort Rainbow('The database restore failed').red if result.failed?
    end

    def postgres_restore_database_command(file_path, destination_database)
      "pg_restore --dbname=#{destination_database} --jobs=4 -O #{file_path}"
    end

    def print_host_disk_space(host_name)
      log_message('Checking free disk space', header: '', host_name: host_name)

      usage = disk_usage(host_name)

      log_message("#{usage[:available]} free of #{usage[:size]} total", host_name: host_name)
    end

    def user_password(host_name, user)
      @user_passwords ||= {}
      @user_passwords["#{host_name}_#{user}"] ||= begin
        ask(Rainbow("#{user}'s password for #{host_name}? ").yellow, echo: false).tap do |_|
          puts
        end
      end
    end
  end
end; end;
