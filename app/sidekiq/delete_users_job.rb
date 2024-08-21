class DeleteUsersJob
  include Sidekiq::Job

  def perform
    inactive_threshold = Settings.minutes_expired.minutes.ago

    User.inactive_unconfirmed(inactive_threshold).delete_all
  end
end
