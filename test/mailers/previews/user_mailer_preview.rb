# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def weekly_update_preview
    UserMailer.weekly_update()
  end
end
