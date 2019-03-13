class AddMetroAreaToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :metro_area, :string, :after => :email
  end
end
