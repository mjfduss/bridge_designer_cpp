require 'spec_helper'

describe "Registrations" do

  subject { page }

  describe "Login/Register Page" do
    before { visit new_session_path }

    it { should have_selector('h1', :text => 'Register and Log In') }
  end

end
