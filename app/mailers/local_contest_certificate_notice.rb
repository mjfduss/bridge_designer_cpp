class LocalContestCertificateNotice < ApplicationMailer

  SUBJECT = "Engineering Encounters Bridge Design Contest: Local contest certificate available!"

  def to_poc(local_contest)
    @local_contest = local_contest
    mail(:to => "#{local_contest.poc_full_name} <#{local_contest.link}>",
         :subject => SUBJECT, :bcc => ARCHIVE_EMAIL) if local_contest.link.include? '@'
  end

end
