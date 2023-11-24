Balrog::Middleware.setup do |config|
  if Rails.env.test? || Rails.env.development?
    # In test, the password is 'password'.
    config.set_password_hash '$2a$12$7MN4TtIgXW12T9jqdCKap.jeI4xs0rUMdFa1dHN3a0cb7M4nos52C'
    config.set_session_expiry 7.hours
  else
    config.set_password_hash ENV['BALROG_PASSWORD_HASH']
    config.set_session_expiry 30.minutes
  end
end
