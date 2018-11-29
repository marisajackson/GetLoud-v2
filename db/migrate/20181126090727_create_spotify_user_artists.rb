class CreateSpotifyUserArtists < ActiveRecord::Migration[5.2]
  def change
    create_table :spotify_user_artists do |t|
      t.belongs_to :spotify_user, index: true
      t.belongs_to :artist, index: true

      t.timestamps null: false
    end
  end
end
