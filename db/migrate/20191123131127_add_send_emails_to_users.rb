class AddSendEmailsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :send_emails, :boolean, :after => :metro_area, :default => 1
  end
end
