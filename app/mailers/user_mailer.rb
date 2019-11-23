class UserMailer < ApplicationMailer
  def weekly_update(user, spotify_user)
    # sendEmails  == 1
    # this_week or new_additions
    # updated playlist in last 48 hours
    # no email sent in the last 6 days
    @city = user.metro_area;
    @spotify_auth_url = SpotifyService.new(spotify_user).create_auth_url
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

    @popular = Event.select("events.*, count(playlist_tracks.*) as count")
                  .joins(:artists => :playlist_tracks)
                  .where(metro_area: user.metro_area)
                  .group('events.id, playlist_tracks.artist_id')
                  .order(Arel.sql('COUNT(playlist_tracks.artist_id) DESC'))
                  .limit(10)

    # make_bootstrap_
    mail(to: 'mhljackson@gmail.com', subject: 'Sample Email')
  end
end
