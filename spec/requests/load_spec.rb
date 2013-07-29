require 'spec_helper'

describe "Registration" do

  subject { page }

  describe "complete bridge upload" do
    before do
      Capybara.run_server = false
      Capybara.app_host = 'http://bridgecontest.herokuapp.com'
    end
    it 'makes a new account and submits a design many times', :js => true do
      files = Dir.glob File.join(::Rails.root, 'vendor', 'gems', 'WPBDC', 'test', 'contest', '*.bdc')
      n = 0
      files.each do |file|
        n += 1
        next unless n > 5368
        goto_certification_page(:team_name => "Team #{n}")
        click_button I_CERTIFY
        fill_in_member_completion
        click_button ACCEPT
        fill_in_team_completion
        click_button ACCEPT
        attach_file 'design[bridge]', file
        click_button 'Submit your design'
        click_button 'Log out'
        should have_content('Welcome Bridge Designer!')
        print "#{n}."
      end
    end
    #it { should have_selector('div', :text => "Home Page for Team Beat Air Force!") }
  end

end