class JtiCleanupJob < ApplicationJob
  queue_as :default

  def perform
    Jti.expired.delete_all
  end
end
