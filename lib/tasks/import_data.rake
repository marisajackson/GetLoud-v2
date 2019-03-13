desc 'Weekly import of event and artist data.'
task :import_data => :environment do
  puts 'Starting weekly import of event and artist data task at ' + (Time.now).to_formatted_s(:db)
  Event::where("date < ?", Time.now).destroy_all

  users = User.select(:metro_area).distinct
  users.each do |user|
    EventImportJob.perform_later user.metro_area
  end

  artists = Artist.includes(:genres).where(genres: { id: nil }).or(Artist.includes(:genres).where(spotify_id: nil))

  artists.each do |artist|
    SpotifyArtistJob.perform_later artist
  end
  puts 'Finishing weekly import of event and artist data task at ' + (Time.now).to_formatted_s(:db)
end
