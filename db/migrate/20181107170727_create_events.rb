class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :name
      t.datetime :date
      t.string :venue
      t.string :metro_area

      t.string :ticket_url
      t.string :event_api
      t.string :event_api_id

      t.timestamps null: false
    end
  end
end
