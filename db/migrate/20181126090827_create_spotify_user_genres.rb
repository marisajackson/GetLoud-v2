class CreateSpotifyUserGenres < ActiveRecord::Migration[5.2]
  def change
    create_table :spotify_user_genres do |t|
      t.belongs_to :spotify_user, index: true
      t.belongs_to :genre, index: true

      t.timestamps null: false
    end
  end
end
