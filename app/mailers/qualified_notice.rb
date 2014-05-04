class QualifiedNotice < ApplicationMailer

  SUBJECT = "Engineering Encounters Bridge Design Contest: You're qualified!"

  def to_team(team)
    @team = team
    mail(:to => "#{@team.name} <#{@team.email}>", :subject => SUBJECT, :bcc => ARCHIVE_EMAIL)
  end

end
