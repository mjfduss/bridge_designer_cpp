require 'spec_helper'

describe "Registration" do

  subject { page }

  describe "complete bridge upload" do
    before {
      files = Dir.glob File.join(::Rails.root, 'vendor', 'gems', 'WPBDC', 'test', 'contest', '*.bdc')
      n = 0
      files.each do |file|
        goto_certification_page(:team_name => "Team #{n += 1}")
        click_button I_CERTIFY
        fill_in_member_completion
        click_button ACCEPT
        fill_in_team_completion
        click_button ACCEPT
        attach_file 'design[bridge]', file
        click_button 'Submit your design'
        click_button 'Log out'
        print "#{n}."
      end
    }
    it { should have_content('Welcome Bridge Designer!')}
    #it { should have_selector('div', :text => "Home Page for Team Beat Air Force!") }
  end

end