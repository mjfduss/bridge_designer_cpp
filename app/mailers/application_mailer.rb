class ApplicationMailer < ActionMailer::Base

  EMAIL_DOMAIN = ActionMailer::Base.default_url_options[:host]
  DEFAULT_EMAIL = "info@#{EMAIL_DOMAIN}"
  NOREPLY_EMAIL = "no-reply@#{EMAIL_DOMAIN}"
  default :from => DEFAULT_EMAIL

end
