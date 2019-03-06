class AddRelationTypeToSpotifyUserArtists < ActiveRecord::Migration[5.2]
  def change
    add_column :spotify_user_artists, :relation_type, :integer, :after => :artist_id
  end
end
