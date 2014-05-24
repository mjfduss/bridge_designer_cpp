class ApplicationMailer < ActionMailer::Base

  EMAIL_DOMAIN = 'bridgecontest.org'
  DEFAULT_EMAIL = "info@#{EMAIL_DOMAIN}"
  ARCHIVE_EMAIL = "judges@#{EMAIL_DOMAIN}"
  default :from => DEFAULT_EMAIL, :bcc => ARCHIVE_EMAIL

end
