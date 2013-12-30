class GeneralNotice < ApplicationMailer

  def to_address(email, subject, html, text)
    @html = html
    @text = text
    mail(:to => email, :subject => subject)
  end

end
