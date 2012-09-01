module CertificationsHelper

  def eligibility(captain, member)
    return captain.category == 'o' ? :ineligible : :eligible if member.nil?
    return captain.category == 'o' || member.category == 'o' ? :ineligible : :eligible
  end

end
