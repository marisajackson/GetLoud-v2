class AddImageUrlToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :image_url, :string, :after => :metro_area
  end
end
