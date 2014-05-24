class DisqualifiedNotice < ApplicationMailer

  SUBJECT = "Engineering Encounters Bridge Design Contest: Disqualification notice"

  def to_team(team)
    @team = team
    mail(:to => "#{@team.name} <#{@team.email}>", :subject => SUBJECT)
  end

end
