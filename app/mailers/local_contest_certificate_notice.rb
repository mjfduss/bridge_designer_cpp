class LocalContestCertificateNotice < ApplicationMailer

  SUBJECT = "Engineering Encounters Bridge Design Contest: Local contest certificate available!"

  def to_poc(local_contest)
    @local_contest = local_contest
    # TODO This is debugging code!  DELETE ME!
    to = Rails.env.development? ? 'gene.ressler@gmail.com' : local_contest.link
    mail(:to => "#{local_contest.poc_full_name} <#{to}>",
         :subject => SUBJECT, :bcc => DEFAULT_EMAIL) if local_contest.link.include? '@'
  end

end
