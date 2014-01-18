class PasswordResetNotification < ApplicationMailer

  # Send password resets to a collection of teams.  Assumes all resets are for
  # teams with the same email address, so the first is used.
  def to_team(resets)
    @resets = resets
    mail(:to => resets.first.team.email,
         :from => ApplicationMailer::DEFAULT_EMAIL,  # Should be no-reply, but how to register with Postmark?
         :subject => 'Password reset for the Engineering Encounters Bridge Design Contest')
  end
end
