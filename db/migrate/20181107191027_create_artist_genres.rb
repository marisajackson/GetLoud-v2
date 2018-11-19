class CreateArtistGenres < ActiveRecord::Migration[5.2]
  def change
    create_table :artist_genres do |t|
      t.belongs_to :genre, index: true
      t.belongs_to :artist, index: true

      t.timestamps null: false
    end
  end
end
