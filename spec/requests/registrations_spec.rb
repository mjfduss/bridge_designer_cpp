require 'spec_helper'

describe "Registrations" do

  subject { page }

  describe "Login/Register Page" do
    before { visit new_session_path }

    it { should have_selector('div', :text => 'Welcome Bridge Designer!') }
    it { should have_selector('div', :text => 'Contest Login') }
  end

end
