require 'thor'

require 'postgres/clone/commands'

module Postgres; module Clone;
  class Executable < Thor
    include Commands

    option :src_host, required: true
    option :src_db, required: true
    option :dst_host, required: true
    option :dst_db
    option :file_path
    option :verbose, default: true
    desc 'clone_database', 'Clones a Postgres database from one host to another'
    def clone_database
      print_hosts_disk_space

      if options[:src_host] == options[:dst_host]
        create_database_using_template
      else
        create_database_using_restore
      end

      print_hosts_disk_space

      close_ssh_connections
    end

    default_task :clone_database

    private

    def create_database_using_restore
      file_path = options[:file_path] || "/tmp/#{file_name}"

      postgres_dump_database(options[:src_host], options[:src_db], file_path)

      copy_file(options[:src_host], options[:dst_host], file_path)

      postgres_restore_database(
        options[:dst_host],
        options[:dst_db] || file_name,
        file_path
      )

      log_message('Finished restoring database!', header: '', color: :green)
    end

    def create_database_using_template
      postgres_create_database(
        options[:src_host],
        options[:dst_db] || file_name,
        template: options[:src_db]
      )

      log_message('Finished creating database!', header: '', color: :green)
    end

    def file_name
      @file_name ||= begin
        if options[:file_path].nil?
          "#{options[:src_db]}_#{Time.now.strftime('%Y%m%d')}"
        else
          File.basename(options[:file_path])
        end
      end
    end

    def print_hosts_disk_space
      [options[:src_host], options[:dst_host]].uniq.each do |host_name|
        print_host_disk_space(host_name)
      end
    end
  end
end; end;
