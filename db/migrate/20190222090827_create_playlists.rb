class CreatePlaylists < ActiveRecord::Migration[5.2]
  def change
    create_table :playlists do |t|
      t.belongs_to :spotify_user, index: true
      t.string :spotify_id
      t.datetime :last_updated_at

      t.timestamps null: false
    end
  end
end
