desc 'Weekly import of event and artist data.'
task :weekly_update do
  puts 'Checking weekly update task for day: ' + Date.today.wday.to_s
  if Date.today.wday == 3
    puts 'Performing weekly update...'
    Rake::Task["import_data"].invoke
    Rake::Task["spotify_update"].invoke
  end
  puts 'Completing weekly task update.'
end
