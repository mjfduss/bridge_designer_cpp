class DisqualifiedNotice < ApplicationMailer

  SUBJECT = "West Point Bridge Design Contest: Disqualification notice"

  def to_team(team)
    @team = team
    mail(:to => "#{@team.name} <#{@team.email}>", :subject => SUBJECT, :bcc => DEFAULT_EMAIL)
  end

end
