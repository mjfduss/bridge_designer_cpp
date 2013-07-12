class QualifiedNotice < ApplicationMailer

  SUBJECT = "West Point Bridge Design Contest: You're qualified!"

  def to_team(team)
    @team = team
    mail(:to => "#{@team.name} <#{@team.email}>", :subject => SUBJECT, :bcc => DEFAULT_EMAIL)
  end

end
