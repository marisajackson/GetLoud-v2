class EmailHistory < ApplicationRecord
  self.table_name = 'email_history'
  belongs_to :user
end
