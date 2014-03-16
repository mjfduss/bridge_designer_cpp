class LocalContestCertificateNotice < ApplicationMailer

  SUBJECT = "Engineering Encounters Bridge Design Contest: Local contest certificate available!"

  def to_poc(local_contest)
    @local_contest = local_contest
    # TODO This is debugging code!  DELETE ME!
#    mail(:to => "#{local_contest.poc_full_name} <#{local_contest.link}>",
    mail(:to => "#{local_contest.poc_full_name} <#{'gene.ressler@gmail.com'}>",
         :subject => SUBJECT, :bcc => DEFAULT_EMAIL) if local_contest.link.include? '@'
  end

end
