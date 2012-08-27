require 'spec_helper'
include ActionView::Helpers::FormOptionsHelper

describe "Registration" do

  subject { page }
  
  describe "at Login/Register page" do
    before { visit root_path }
    it { should have_selector('title', :text => 'West Point Bridge Design Contest') }
    it { should have_selector('div', :text => 'Welcome Bridge Designer!') }
    it { should have_selector('div', :text => 'Contest Login') }
  end

  describe "at first registration page" do
    before {
      visit root_path
      click_button "Start the Registration Wizard >>"
    }
    it { should have_selector('title', :text => 'West Point Bridge Design Contest') }
    it { should have_selector('div', :text => 'Team Name:') }
    it { should have_selector('div', :text => 'Contest selection') }
    it { should have_selector('div', :text => 'Team Captain') }
    it { should have_selector('td', :text => 'First Name') }
    it { should have_selector('td', :text => 'MI') }
    it { should have_selector('td', :text => 'Last Name') }
    it { should have_selector('div', :text => 'My school is located in:') }    
    it { should have_selector('div', :text => 'My permanent residence is in:') }
  end

  describe "errors with empty first registration page" do
    before {
      visit root_path
      click_button "Start the Registration Wizard >>"
      click_button "Accept and Continue >>"
      click_button "Accept and Continue >>"
    }
    it { html.should match /Reason for error appears here!/ }
    it { html.should match /Team name can't be blank/ }
    it { html.should match /First name can't be blank/ }
    it { html.should match /Last name can't be blank/ }
    it { html.should match /Category must be selected with one of the buttons below/ }
  end

end
