class CreatePlaylistTracks < ActiveRecord::Migration[5.2]
  def change
    create_table :playlist_tracks do |t|
      t.belongs_to :playlist, index: true
      t.belongs_to :artist, index: true
      t.string :spotify_track_id

      t.timestamps null: false
    end
  end
end
