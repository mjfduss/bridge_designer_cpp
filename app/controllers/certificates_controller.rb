class CertificatesController < ApplicationController
  def show
    certificate = Certificate.find_by_id_and_team_id(params[:id], session[:team_id])
    # Must be the logged in team and the team must not be rejected
    if certificate && certificate.team.status != 'r'
      @team = certificate.team
      @standing = certificate.standing
      @basis = certificate.basis
      @group_info = certificate.group_info # Array of Certificate::PerGroupInfo
      @awarded_on = certificate.awarded_on
      @local_contest = certificate.local_contest
      @semifinalist = certificate.team.semifinalist? && !@local_contest
    else
      redirect_to :controller => :homes, :action => :edit unless certificate
    end
  end
end
