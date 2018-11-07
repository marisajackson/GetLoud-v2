class EventController < ApplicationController
    def ticketmaster
      query_params = {
          apikey: Rails.application.credentials.ticketmaster[:api_key],
          city: 'Nashville',
          segmentId: Rails.application.credentials.ticketmaster[:music_segment_id],
          startDateTime: '2018-12-01T10:34:00Z',
          endDateTime: '2018-12-31T10:34:00Z',
          size: 200,
      }

      tm_query = "/discovery/v2/events?#{query_params.to_query}"

      while tm_query
        event_response = RestClient.get("https://app.ticketmaster.com#{tm_query}")
        event_response = JSON.parse(event_response.body)
        events = event_response['_embedded']['events']

        tm_query = nil

        if event_response['_links']['next']
          tm_query = "#{event_response['_links']['next']['href']}&apikey=#{Rails.application.credentials.ticketmaster[:api_key]}"
        end

        events.each do |item|
          @event = Event.where(event_api: 'ticketmaster')
                       .where(event_api_id: item['id'])
                       .first

          if !@event
            @event = Event.new
            @event.name = item['name']
            @event.date = item['dates']['start']['dateTime']
            @event.venue = item['_embedded']['venues'][0]['name']
            @event.metro_area = "#{item['_embedded']['venues'][0]['city']['name']}, #{item['_embedded']['venues'][0]['state']['stateCode']}"
            @event.ticket_url = item['url']
            @event.event_api = 'ticketmaster'
            @event.event_api_id = item['id']
            @event.save!
          end

          artists = item['_embedded']['attractions']
          if artists
            artists.each do |artist|
              gl_artist = Artist.find_or_create_by(name: artist['name'])
              event_artist = EventArtist.where(event_id: @event.id)
                           .where(artist_id: gl_artist.id)
                           .first

              if !event_artist
                event_artist = EventArtist.new
                event_artist.event_id = @event.id
                event_artist.artist_id = gl_artist.id
                event_artist.save!
              end
            end
          end
        end
      end


       render :json => event_response
    end
end
