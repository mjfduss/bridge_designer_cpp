module VerificationsHelper

  def partial_for(team, member)
    case team.category
      when 'm', 'h'
        member.coppa? ? 'coppa_eligible_verification' : 'eligible_verification'
      when 'i'
        'ineligible_verification'
    end
  end

end