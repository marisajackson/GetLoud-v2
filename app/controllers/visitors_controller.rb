class VisitorsController < ApplicationController
  def index
    if user_signed_in?
      if current_user.metro_area && current_user.metro_area != ''
        spotify_user = SpotifyUser.find_by(user_id: current_user.id)

        @events = Event.where(metro_area: current_user.metro_area).includes(:artists => :spotify_users).where(artists: {spotify_users: {user_id: current_user.id}}).order(:date)
        @events.each do |event|
          event.supporting_artists = nil
          supporting_artists = []
          event.artists.each do |artist|
            if !event.name.include? artist.name
              supporting_artists.push(artist.name)
              event.supporting_artists = supporting_artists.join(", ")
            end
          end
        end

        # https://open.spotify.com/user/oreolistens/playlist/3tCx3pnNsPKT6PsFKWygKo?si=VeLQcvdzRmupI_lNW415iA
        playlist = Playlist.find_by(spotify_user_id: spotify_user.id)
        if(playlist)
          @playlist_url = "https://open.spotify.com/user/#{spotify_user.spotify_id}/playlist/#{playlist.spotify_id}"
        end

        # @playlist_url = nil

        render "users/home"
      else
        render "users/setup"
      end
    end
  end

  def sign_up
    @spotify_auth_url = SpotifyService.new(SpotifyUser.first).create_auth_url({})
    render "users/sign-up"
  end

  def logout
    sign_out(current_user)

    render 'index'
  end

  def email
    user = User.find(4)
    spotify_user = SpotifyUser.find(1)

    template_data = UserMailer.weekly_update(user, spotify_user)
    puts "the template data returned============="

    # puts template_data.subject

    if(template_data)
      puts "initializing sendgrid"
      sendgrid = SendgridMailer.new;
      sendgrid.send('marisa@hoplinmedia.com', template_data, 'd-1fa0dae00fea4581b1ad3cab9fc67f9e')
    end

    return render :json => template_data
  end
end