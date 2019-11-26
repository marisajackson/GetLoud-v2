class UserMailer < ApplicationMailer
  def weekly_update(user, spotify_user)
    # sendEmails  == 1
    if !user.send_emails
      return
    end

    playlist = Playlist.find_by(spotify_user_id: spotify_user.id)
    if(!playlist)
      return
    end

    # no email sent in the last 6 days
    recent_email = EmailHistory.where("sent_at >= ?", 6.days.ago).first()
    if recent_email
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
                  .where("date >= ?", 7.days.from_now)
                  .order('playlist_tracks.created_at')
                  .limit(10)

    # only if this_week or new_additions
    if(@this_week.length == 0 && @new_additions.length == 0)
      return
    end

    @popular = Event.select("events.*, count(playlist_tracks.*) as count")
                  .joins(:artists => :playlist_tracks)
                  .where(metro_area: user.metro_area)
                  .group('events.id, playlist_tracks.artist_id')
                  .order(Arel.sql('COUNT(playlist_tracks.artist_id) DESC'))
                  .having('COUNT(playlist_tracks.artist_id) > 5')
                  .limit(10)

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

    mail(to: 'mhljackson@gmail.com', subject: 'Sample Email')
  end
end
