desc 'Weekly update of Spotify User artist\'s and playlist.'
task :spotify_update => :environment do
  puts 'Starting weekly update of Spotify User artist\'s and playlist task at ' + (Time.now).to_formatted_s(:db)
  spotify_users = SpotifyUser.all

  spotify_users.each do |spotify_user|
    SpotifyUserUpdateJob.perform_later spotify_user
  end

  puts 'Finishing weekly update of Spotify User artist\'s and playlist task at ' + (Time.now).to_formatted_s(:db)
end
