desc 'Weekly update of Spotify User artist\'s and playlist.'
task :spotify_update, [:spotify_user_id] => :environment do |t, args|
  puts 'Starting weekly update of Spotify User artist\'s and playlist task at ' + (Time.now).to_formatted_s(:db)

  args.with_defaults(:spotify_user_id => nil)

  spotify_user_id = args[:spotify_user_id]

  if spotify_user_id
    puts 'Running for Spotify User ID: ' + spotify_user_id
    spotify_user = SpotifyUser.find(spotify_user_id)
    SpotifyUserUpdateJob.perform_later spotify_user
  else
    spotify_users = SpotifyUser.all

    spotify_users.each do |spotify_user|
      SpotifyUserUpdateJob.perform_later spotify_user
    end
  end

  puts 'Finishing weekly update of Spotify User artist\'s and playlist task at ' + (Time.now).to_formatted_s(:db)
end
