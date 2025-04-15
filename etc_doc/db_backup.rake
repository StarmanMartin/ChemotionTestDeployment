# lib/tasks/db_backup.rake

namespace :db do
  desc "Backup database"
  task backup: :environment do
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    backup_file = "/backup/backup_#{timestamp}.sql"
    config = ActiveRecord::Base.connection_config

    cmd = case config[:adapter]
    when "postgresql"
      "PGPASSWORD='#{config[:password]}' pg_dump -U #{config[:username]} -h #{config[:host] || 'localhost'} #{config[:database]} > #{backup_file}"
    when "mysql2"
      "mysqldump -u #{config[:username]} -p#{config[:password]} #{config[:database]} > #{backup_file}"
    else
      raise "Unsupported adapter: #{config[:adapter]}"
    end

    puts "Running: #{cmd}"
    system(cmd) or abort("Backup failed")
    puts "Backup saved to #{backup_file}"
  end
end