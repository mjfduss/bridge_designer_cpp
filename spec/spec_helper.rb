# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Avoids having to use FactoryGirl prefix
  config.include FactoryGirl::Syntax::Methods
end

def goto_team_registration_page(args)
  visit root_path
  click_button "Start the Registration Wizard >>"
end

def fill_in_member_partial(args = {})
  fill_in("first_name", :with => 'Jane')
  fill_in("last_name", :with => 'Smith')
  choose("category_#{args[:category] || 'u'}")
  select('Pennsylvania', :from => "school_state")
end

def fill_in_member_completion(args={})
  select("13", :from => "member_age")
  select("7", :from => "member_grade")
  fill_in("member_street", :with => "107A Washington Road")
  fill_in("member_phone", :with => "845-446-9826")
  fill_in("member_city", :with => "West Point")
  fill_in("member_state", :with => "NY")
  fill_in("member_zip", :with => "10996")
  fill_in("member_country", :with => "US")
  fill_in("member_school", :with => "Northamton Senior High")
  fill_in("member_school_city", :with => "Northampton")
end

def fill_in_team_completion(args={})
  fill_in('team_email', :with => 'gene.ressler@gmail.com')
  fill_in('team_password', :with => 'foobarbaz')
  fill_in('team_password_confirmation', :with => 'foobarbaz')
end

def goto_member_registration_page(args={})
  goto_team_registration_page(args)
  fill_in('team_name', :with => args[:team_name] || 'Beat Air Force!')
  fill_in_member_partial(args.merge(:category => args[:captain_category]))
  click_button 'Accept and Continue >>'
end

def goto_certification_page(args)
  goto_member_registration_page(args)
  unless args[:member_category]
    click_button "Continue >>"
  else
    click_button "Accept and Continue >>"
    fill_in_member_partial(args.merge[:category => args[:member_category]])
    click_button "Accept and Continue >>"
  end
end

def it_should_have_standard_title
  it { should have_selector('title', :text => 'Engineering Encounters Bridge Design Contest') }
end

def it_should_have_member_partial
  it { should have_selector('td', :text => 'First Name') }
  it { should have_selector('td', :text => 'MI') }
  it { should have_selector('td', :text => 'Last Name') }
  it { should have_selector('div', :text => 'My school is located in:') }
  it { should have_selector('div', :text => 'My permanent residence is in:') }
end

def it_should_have_member_errors
  it { html.should match /Reason for error appears here!/ }
  it { html.should match /First name can't be blank/ }
  it { html.should match /Last name can't be blank/ }
  it { html.should match /Category must be selected with one of the buttons below/ }
end

def it_should_have_certification_tags
  it { should have_selector('div', :text => "Certify Your Team's Eligiblity") }
  it { should have_selector('td', :text => "Team Name:") }
  it { should have_selector('td', :text => "Team Captain:") }
  it { should have_selector('td', :text => "Category:") }
  it { should have_selector('td', :text => "Competing in:") }
  it { should have_selector('td', :text => "Team eligibility:") }
end

def it_should_have_member_completion_errors
  it { html.should match "Age must be selected" }
  it { html.should match "Grade must be selected" }
  it { html.should match "Street can't be blank" }
  it { html.should match "Phone can't be blank" }
  it { html.should match "City can't be blank" }
  it { html.should match "State can't be blank" }
  it { html.should match "Zip can't be blank" }
  it { html.should match "School can't be blank" }
  it { html.should match "School city can't be blank" }
end

def goto_captain_completion_page(args={})
  goto_certification_page(args)
  click_button I_CERTIFY
end

def goto_member_completion_page(args={})
  goto_certification_page(:captain_category => 'n', :member_category => 'n')
  puts html.inspect
  click_button I_CERTIFY
  fill_in_member_completion(args)
  click_button "Accept and Continue >>"
end

US_SCHOOL = 'Student, age 13 through grade 12, currently enrolled in a U.S. ' +
  'school or legally home-schooled. Eligible for national recognition.'

NON_US_SCHOOL = 'U.S. citizen, age 13 through grade 12 (or equivalent), currently ' +
  'attending a school outside the U.S. Eligible for national recognition.'

OPEN = 'Open Competitor. Not eligible for national recognition.'

ELIGIBLE = 'Your team is eligible to compete for national recognition by submitting designs.'

INELIGIBLE = 'At least one of your team members is not eligible for ' +
  'national recognition. Therefore the team is not eligible. We encourage you ' +
  'to submit designs in Open Competition!'

IN_US = 'US/PR Student Competition.'

IN_OPEN = 'Open Competition.'

I_CERTIFY = 'I Certify the Information Above is True and Correct >>'

GO_BACK = 'Go Back to Make Changes'

ACCEPT = 'Accept and Continue >>'
