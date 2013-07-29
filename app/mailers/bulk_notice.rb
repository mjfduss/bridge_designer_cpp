class BulkNotice < ApplicationMailer

  def to_team(team, document)
    @team = team
    @document = document
    mail(:to => "#{@team.name} <#{@team.email}>", :subject => document.subject)
  end

  def to_any_address(email, document)
    @email = email
    @document = document
    mail(:to => email, :subject => document.subject)
  end

end
