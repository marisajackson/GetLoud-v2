class WeeklyEmailJob < ApplicationJob
  queue_as :default

  def perform(spotify_user)
    user = User.find(spotify_user.user_id)
    logger.info "Starting Job: Weekly Email: #{user.email}"
    UserMailer.weekly_update(user, spotify_user).deliver
    logger.info "Finishing Job: Weekly Email: #{user.email}"
  end
end
