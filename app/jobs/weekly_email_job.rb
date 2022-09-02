class WeeklyEmailJob < ApplicationJob
  queue_as :default

  def perform(spotify_user)
    user = User.find(spotify_user.user_id)
    logger.info "Starting Job: Weekly Email: #{user.email}"
    template_data = UserMailer.weekly_update(user, spotify_user)

    if(template_data)
      sendgrid = SendgridMailer.new;
      sendgrid.send('marisa@hoplinmedia.com', template_data, 'd-1fa0dae00fea4581b1ad3cab9fc67f9e')
    end

    logger.info "Finishing Job: Weekly Email: #{user.email}"
  end
end
