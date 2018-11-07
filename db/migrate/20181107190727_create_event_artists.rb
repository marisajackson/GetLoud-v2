class CreateEventArtists < ActiveRecord::Migration[5.2]
  def change
    create_table :event_artists do |t|
      t.belongs_to :event, index: true
      t.belongs_to :artist, index: true

      t.timestamps null: false
    end
  end
end
