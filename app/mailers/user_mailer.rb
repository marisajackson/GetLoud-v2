class UserMailer < ApplicationMailer
  def weekly_update(user, spotify_user, force = false)
    # sendEmails  == 1
    if !user.send_emails && !force
      return
    end

    playlist = Playlist.find_by(spotify_user_id: spotify_user.id)
    if(!playlist)
      return
    end

    # no email sent in the last 6 days
    recent_email = EmailHistory.where("sent_at >= ?", 6.days.ago)
                                .where(user_id: user.id)
                                .first()
    if recent_email && !force
      return
    end

    @city = user.metro_area;
    @playlist_url = "https://open.spotify.com/user/#{spotify_user.spotify_id}/playlist/#{playlist.spotify_id}"
    @this_week = Event.where(metro_area: user.metro_area)
                  .includes(:artists => :spotify_users)
                  .where(artists: {spotify_users: {user_id: user.id}})
                  .where("date <= ?", 7.days.from_now)
                  .order(:date)


    @new_additions = Event.where(metro_area: user.metro_area)
                  .includes(:artists => :spotify_users)
                  .includes(:artists => :playlist_tracks)
                  .where(artists: {spotify_users: {user_id: user.id}})
                  .where('events.created_at <= ?', 2.days.ago)
                  .order('playlist_tracks.created_at')
                  .limit(6)

    # only if this_week or new_additions
    if(@this_week.length == 0 && @new_additions.length == 0) && !force
      return
    end

    @this_week.each do |event|
      event.supporting_artists = nil
      supporting_artists = []
      event.artists.each do |artist|
        if !event.name.include? artist.name
          supporting_artists.push(artist.name)
          event.supporting_artists = supporting_artists.join(", ")
        end
      end
    end

    @new_additions.each do |event|
      event.supporting_artists = nil
      supporting_artists = []
      event.artists.each do |artist|
        eventName = event.name.downcase
        artistName = artist.name.downcase
        if !eventName.include? artistName
          supporting_artists.push(artist.name)
          event.supporting_artists = supporting_artists.join(", ")
        end
      end
    end


    @popular = Event.select("events.*, count(playlist_tracks.*) as count")
                  .joins(:artists => :playlist_tracks)
                  .where(metro_area: user.metro_area)
                  .group('events.id, playlist_tracks.artist_id')
                  .order(Arel.sql('COUNT(playlist_tracks.artist_id) DESC'))
                  .having('COUNT(playlist_tracks.artist_id) > 5')
                  .limit(6)

    email_history = EmailHistory.new
    email_history.user_id = user.id
    email_history.sent_at = Time.now
    email_history.details = {
      playlist_url: @playlist_url,
      this_week_count: @this_week.length,
      new_additions_count: @new_additions.length,
      popular_count: @popular.length
    }
    email_history.save!

    artistNames = [];
    if(@new_additions)
      subject = 'Just Announced: '
      artists = Artist.select('artists.name')
              .joins(:spotify_users)
              .joins(:events)
              .joins(:playlist_tracks => :playlist)
              .where(events: {metro_area: user.metro_area})
              .where('events.created_at <= ?', 2.days.ago)
              .where(playlist_tracks: {playlists: {spotify_user_id: spotify_user.id}})
              .where(spotify_users: {user_id: user.id})
              .group('artists.name')
              .limit(3)

      artists.each_with_index do |artist, i|
        artistNames.push(artist.name);
      end
    else
      subject = 'This Week: '

      artists = Artist.includes(:spotify_users)
              .includes(:events)
              .where(events: {metro_area: user.metro_area})
              .where("date <= ?", 7.days.from_now)
              .where(spotify_users: {user_id: current_user.id})
              .limit(3)

      artists.each_with_index do |artist, i|
        artistNames.push(artist.name);
      end
    end

    artistNames = artistNames.join(', ');

    subject = subject + artistNames;

    mail(to: user.email, subject: subject)
  end
end
