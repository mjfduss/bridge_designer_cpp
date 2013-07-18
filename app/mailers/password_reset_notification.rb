class PasswordResetNotification < ApplicationMailer

  # Send password resets to a collection of teams.  Assumes all resets are for
  # teams with the same email address, so the first is used.
  def to_team(resets)
    @resets = resets
    mail(:to => resets.first.team.email,
         :from => ApplicationMailer::NOREPLY_EMAIL,
         :subject => 'Password reset for the West Point Bridge Design Contest')
  end
end
