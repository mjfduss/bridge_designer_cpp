class ApplicationMailer < ActionMailer::Base

  EMAIL_DOMAIN = 'bridgecontest.org'
  DEFAULT_EMAIL = "info@#{EMAIL_DOMAIN}"
  NOREPLY_EMAIL = "no-reply@#{EMAIL_DOMAIN}"
  default :from => DEFAULT_EMAIL

end
