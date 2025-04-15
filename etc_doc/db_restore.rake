namespace :db do
  desc "Restore database from a backup in db/backups/"
  task restore: :environment do
    require 'io/console'

    backup_dir = "/restore"
    Dir.mkdir(backup_dir) unless Dir.exist?(backup_dir)

    dumps = Dir["#{backup_dir}/*.sql"].sort
    if dumps.empty?
      puts "No backup files found in #{backup_dir}"
      exit 1
    end

    puts "\nAvailable backups:"
    dumps.each_with_index do |file, idx|
      puts "#{idx + 1}: #{File.basename(file)}"
    end

    file_to_restore = dumps.last

    puts "\nRestoring: #{File.basename(file_to_restore)}"
    config = ActiveRecord::Base.connection_config

    puts "Dropping and recreating database..."
    system("dropdb -U #{config[:username]} -h #{config[:host] || 'localhost'} #{config[:database]}")
    system("createdb -U #{config[:username]} -h #{config[:host] || 'localhost'} #{config[:database]}")
    system("psql -U #{config[:username]} -h #{config[:host] || 'localhost'} -d #{config[:database]} -f #{file_to_restore}")

    puts "\nRestore completed. Running migrations..."

    Rake::Task["db:migrate"].reenable
    Rake::Task["db:migrate"].invoke

    puts "\nMigrations completed."
  end
end