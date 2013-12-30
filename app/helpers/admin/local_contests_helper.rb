module Admin::LocalContestsHelper

  def email?(s)
    s && s =~ Team::VALID_EMAIL_ADDRESS
  end

end