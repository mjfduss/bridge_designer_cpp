require 'spec_helper'

describe "Registration" do

  subject { page }
  
  describe "at Login/Register page" do
    before { visit root_path }
    it { should have_selector('title', :text => 'West Point Bridge Design Contest') }
    it { should have_selector('div', :text => 'Welcome Bridge Designer!') }
    it { should have_selector('div', :text => 'Contest Login') }
  end

  describe "at Team registration page" do
    before { goto_team_registration_page }
    it_should_have_standard_title
    it { should have_selector('div', :text => 'Team Name:') }
    it { should have_selector('div', :text => 'Contest selection') }
    it { should have_selector('div', :text => 'Team Captain') }
    it_should_have_member_partial
  end

  describe "error messages with empty Team registration page" do
    before {
      goto_team_registration_page
      click_button "Accept and Continue >>"
    }
    it { html.should match /Team name can't be blank/ }
    it_should_have_member_errors
  end

  describe "at Member registration page" do
    before { goto_member_registration_page }
    it_should_have_standard_title
    it { should have_content('Second Team Member') }
    it_should_have_member_partial
  end

  describe "error messages with empty Member registration page" do
    before { 
      goto_member_registration_page 
      click_button "Accept and Continue >>"
    }
    it_should_have_member_errors
  end

  describe "at Certification page with no member" do
    before { goto_certification_page 'u' }
    it_should_have_certification_tags
    it { find('#captain_category').should have_content(US_SCHOOL) }
    it { should_not have_selector('td', :text => "Second Team Member:") }
  end

  describe "at Certification page with member" do
    before { goto_certification_page 'u', 'u' }
    it_should_have_certification_tags
    it { should have_selector('td', :text => "Second Team Member:") }
    it { find('#captain_category').should have_content(US_SCHOOL) }
    it { find('#member_category').should have_content(US_SCHOOL) }
  end

  describe "at Member, school state not selected" do
    before { 
      goto_member_registration_page 
      choose('team_member_category_u')
      click_button "Accept and Continue >>"
    }
    it { html.should match /School state must be selected\./ }
  end

  describe "at Member, state of residence not selected" do
    before { 
      goto_member_registration_page 
      choose('team_member_category_n')
      click_button "Accept and Continue >>"
    }
    it { html.should match /State of residence must be selected\./ }
  end
end
